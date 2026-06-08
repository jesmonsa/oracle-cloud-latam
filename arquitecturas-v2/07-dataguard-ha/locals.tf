# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Locals - Valores calculados y tags                                         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"

  tags_comunes = {
    Proyecto      = var.proyecto
    Ambiente      = var.ambiente
    Propietario   = var.propietario
    Arquitectura  = "07-dataguard-ha"
    Gestionado    = "terraform"
    FechaCreacion = formatdate("YYYY-MM-DD", timestamp())
  }

  es_multi_ad = length(data.oci_identity_availability_domains.ad.availability_domains) > 1

  ad_instancia_1 = data.oci_identity_availability_domains.ad.availability_domains[0].name
  ad_instancia_2 = local.es_multi_ad ? data.oci_identity_availability_domains.ad.availability_domains[1].name : data.oci_identity_availability_domains.ad.availability_domains[0].name

  fd_instancia_1 = "FAULT-DOMAIN-1"
  fd_instancia_2 = local.es_multi_ad ? "FAULT-DOMAIN-1" : "FAULT-DOMAIN-2"

  backend_private_ips = [
    module.webserver_ad1.ips_privadas[0],
    module.webserver_ad2.ips_privadas[0]
  ]

  # Script extra para montar NFS en los webservers
  # Se ejecuta después del userdata base (Apache ya instalado)
  # Estrategia: montar NFS directamente en /var/www/html/shared (sin symlinks)
  # Esto evita problemas de SELinux con paths fuera del document root
  nfs_mount_script = <<-SCRIPT

# ╔══════════════════════════════════════════════════════════════╗
# ║  NFS Mount - File Storage Service v2                        ║
# ║  Monta directamente en /var/www/html/shared (sin symlinks) ║
# ╚══════════════════════════════════════════════════════════════╝
echo "[$(date)] === Configurando NFS mount ==="

# Paso 1: SELinux - permitir Apache acceder NFS (ANTES de montar)
# -P = persistente, toma ~60s pero es necesario
echo "[$(date)] Configurando SELinux para NFS..."
setsebool -P httpd_use_nfs 1 2>/dev/null || true
echo "[$(date)] SELinux httpd_use_nfs habilitado"

# Paso 2: Instalar nfs-utils
if ! rpm -q nfs-utils &>/dev/null; then
  retry 3 15 yum install -y nfs-utils || ERRORS=$((ERRORS + 1))
fi

# Paso 3: Crear punto de montaje DENTRO del document root de Apache
# Esto elimina la necesidad de symlinks y problemas de SELinux con paths externos
NFS_MOUNT_DIR="/var/www/html/shared"
mkdir -p $NFS_MOUNT_DIR

# Paso 4: Montar NFS con reintentos
NFS_IP="${module.filesystem.ip_montaje}"
NFS_PATH="${var.nfs_ruta_exportacion}"
NFS_MOUNT_OK=false

for intento in 1 2 3 4 5 6; do
  echo "[$(date)] Intento NFS $intento/6: montando $NFS_IP:$NFS_PATH en $NFS_MOUNT_DIR"
  if mount -t nfs -o rw,noatime $NFS_IP:$NFS_PATH $NFS_MOUNT_DIR 2>&1; then
    NFS_MOUNT_OK=true
    echo "[$(date)] NFS montado exitosamente en $NFS_MOUNT_DIR"
    break
  fi
  echo "[$(date)] Mount falló, reintentando en 10s..."
  sleep 10
done

if [ "$NFS_MOUNT_OK" = true ]; then
  # Paso 5: fstab para montaje automático al reiniciar
  if ! grep -q "$NFS_IP" /etc/fstab; then
    echo "$NFS_IP:$NFS_PATH $NFS_MOUNT_DIR nfs defaults,nofail,_netdev,noatime 0 0" >> /etc/fstab
    echo "[$(date)] Entrada fstab agregada"
  fi

  # Paso 6: Crear página de prueba compartida (solo si no existe)
  if [ ! -f $NFS_MOUNT_DIR/shared.html ]; then
    echo '<!DOCTYPE html>
<html><head><title>Contenido Compartido NFS</title>
<style>
body { font-family: Arial, sans-serif; margin: 40px; background: #f0f4f8; }
.card { background: white; border-radius: 8px; padding: 30px; max-width: 600px; margin: 0 auto; box-shadow: 0 2px 8px rgba(0,0,0,.1); }
h1 { color: #1a5276; } h2 { color: #2980b9; }
.nfs { background: #eaf2f8; padding: 15px; border-radius: 6px; margin: 10px 0; }
.ok { color: #27ae60; font-weight: bold; }
</style></head><body>
<div class="card">
<h1>Contenido Compartido NFS</h1>
<div class="nfs">
<h2>File Storage Service - OCI</h2>
<p class="ok">Este archivo esta almacenado en el filesystem NFS compartido.</p>
<p>Ambos webservers ven exactamente el mismo contenido.</p>
<p>Cualquier cambio aqui se refleja instantaneamente en todos los servidores.</p>
<p>Arquitectura 07 - oracle-cloud-latam</p>
</div></div></body></html>' > $NFS_MOUNT_DIR/shared.html
    echo "[$(date)] Pagina compartida NFS creada en $NFS_MOUNT_DIR/shared.html"
  fi

  # Paso 7: Verificar que Apache puede servir el archivo
  HTTP_CODE=$(curl -s -o /dev/null -w "%%{http_code}" http://localhost/shared/shared.html 2>/dev/null || echo "000")
  if [ "$HTTP_CODE" = "200" ]; then
    echo "[$(date)] Verificacion OK: Apache sirve contenido NFS correctamente"
  else
    echo "[$(date)] HTTP $HTTP_CODE - reiniciando Apache..."
    systemctl restart httpd 2>/dev/null || true
    sleep 3
    HTTP_CODE2=$(curl -s -o /dev/null -w "%%{http_code}" http://localhost/shared/shared.html 2>/dev/null || echo "000")
    echo "[$(date)] Despues de restart: HTTP $HTTP_CODE2"
  fi

  echo "[$(date)] NFS mount completado: $NFS_IP:$NFS_PATH -> $NFS_MOUNT_DIR"
  df -h $NFS_MOUNT_DIR
else
  echo "[$(date)] ERROR: No se pudo montar NFS despues de 6 intentos"
  ERRORS=$((ERRORS + 1))
fi
SCRIPT
}
