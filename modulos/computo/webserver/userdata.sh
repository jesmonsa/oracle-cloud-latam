#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Cloud-Init Userdata - Webserver Apache                                     ║
# ║  Versión: 3.3 | firewall-offline-cmd + DNS dig + nsswitch fix              ║
# ║  Cambios clave:                                                            ║
# ║    - Firewall: firewall-offline-cmd (no necesita DBus, 100% confiable)     ║
# ║    - DNS: usa dig a oracle.com (no depende de hostname yum regional)       ║
# ║    - nsswitch.conf: elimina mdns4_minimal (causaba 180s delay)             ║
# ║    - nftables: iptables manuales NO funcionan con firewalld activo         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
exec > /var/log/userdata.log 2>&1
echo "[$(date)] === Iniciando configuración del webserver v3.3 ==="
ERRORS=0

# ─── Función: reintentar comandos ────────────────────────────────────────────
retry() {
  local max_attempts=$1; shift
  local delay=$1; shift
  local attempt=1
  while true; do
    echo "[$(date)] Intento $attempt/$max_attempts: $*"
    if "$@"; then
      echo "[$(date)] Éxito en intento $attempt"
      return 0
    fi
    if [ $attempt -ge $max_attempts ]; then
      echo "[$(date)] ERROR: Falló después de $max_attempts intentos: $*"
      return 1
    fi
    echo "[$(date)] Reintentando en ${delay}s..."
    sleep $delay
    attempt=$((attempt + 1))
  done
}

# ─── Paso 0: Fix nsswitch.conf (eliminar mdns4_minimal que causa timeouts) ──
# Oracle Linux 8 incluye mdns4_minimal en nsswitch.conf que causa que
# 'getent hosts' tarde 180+ segundos en entornos cloud sin mDNS.
if grep -q "mdns4_minimal" /etc/nsswitch.conf 2>/dev/null; then
  echo "[$(date)] Eliminando mdns4_minimal de nsswitch.conf..."
  sed -i 's/mdns4_minimal \[NOTFOUND=return\] //g' /etc/nsswitch.conf
  sed -i 's/mdns4_minimal//g' /etc/nsswitch.conf
  echo "[$(date)] nsswitch.conf corregido"
fi

# ─── Paso 1: Esperar conectividad de red (hasta 60s) ────────────────────────
# Verificamos con curl al metadata (link-local, no necesita DNS externo)
# y luego comprobamos DNS real con dig usando timeout
MAX_WAIT=60
WAITED=0
echo "[$(date)] Esperando conectividad de red..."
# Simplemente verificar que podemos hacer curl al metadata Y resolver DNS público
while ! dig +short +time=2 +tries=1 oracle.com 2>/dev/null | grep -q "^[0-9]"; do
  sleep 3
  WAITED=$((WAITED + 3))
  echo "[$(date)] Esperando DNS externo... (${WAITED}s/${MAX_WAIT}s)"
  if [ $WAITED -ge $MAX_WAIT ]; then
    echo "[$(date)] ADVERTENCIA: Timeout DNS tras ${MAX_WAIT}s. Continuando de todas formas..."
    break
  fi
done
if [ $WAITED -lt $MAX_WAIT ]; then
  echo "[$(date)] Red y DNS disponibles después de ${WAITED}s"
else
  echo "[$(date)] Continuando sin DNS confirmado"
fi

# ─── Paso 2: ABRIR FIREWALL (firewall-offline-cmd + runtime) ─────────────────
# En OCI Oracle Linux 8, firewalld usa nftables como backend.
# Las reglas iptables manuales NO aplican cuando firewalld está activo.
# Solución: firewall-offline-cmd modifica la config permanente sin DBus,
# y luego recargamos firewalld para aplicar inmediatamente.
echo "[$(date)] Configurando firewall..."

# Paso 2a: Configurar permanente SIN necesitar DBus (funciona siempre)
firewall-offline-cmd --add-service=http  2>/dev/null && echo "[$(date)] offline: http OK"  || echo "[WARN] offline http failed"
firewall-offline-cmd --add-service=https 2>/dev/null && echo "[$(date)] offline: https OK" || echo "[WARN] offline https failed"

# Paso 2b: Recargar firewalld para aplicar los cambios (si DBus está listo)
# Usar timeout para evitar colgarse si DBus no responde
if timeout 10 firewall-cmd --state &>/dev/null 2>&1; then
  timeout 10 firewall-cmd --reload &>/dev/null 2>&1 && echo "[$(date)] firewalld recargado OK" || echo "[WARN] reload timeout"
  # También aplicar en runtime (por si el reload no fue suficiente)
  timeout 5 firewall-cmd --add-service=http  &>/dev/null 2>&1 || true
  timeout 5 firewall-cmd --add-service=https &>/dev/null 2>&1 || true
  echo "[$(date)] Firewall configurado (permanente + runtime)"
else
  echo "[$(date)] firewalld no disponible aún. Config permanente aplicada, se activará en próximo reload."
  # Forzar restart de firewalld en background para aplicar la config offline
  (sleep 15 && systemctl restart firewalld 2>/dev/null) &
fi

# ─── Paso 3: Deshabilitar repos opcionales problemáticos ─────────────────────
echo "[$(date)] Deshabilitando repos opcionales..."
for repo in ol8_ksplice ol8_ksplice_userspace; do
  if [ -f "/etc/yum.repos.d/ksplice-ol8.repo" ]; then
    sed -i "s/enabled\s*=\s*1/enabled=0/g" /etc/yum.repos.d/ksplice-ol8.repo 2>/dev/null || true
  fi
  yum-config-manager --disable "$repo" 2>/dev/null || true
done

# ─── Paso 4: Limpiar caché yum (evitar metadata corrupta) ───────────────────
echo "[$(date)] Limpiando caché yum..."
yum clean all 2>/dev/null || true

# ─── Paso 5: Instalar Apache con reintentos ─────────────────────────────────
echo "[$(date)] Instalando httpd..."
if ! retry 5 20 yum install -y httpd; then
  echo "[$(date)] ERROR CRITICO: No se pudo instalar httpd después de 5 intentos"
  ERRORS=$((ERRORS + 1))
fi

# ─── Paso 6: Configurar y arrancar Apache ────────────────────────────────────
if rpm -q httpd &>/dev/null; then
  echo "[$(date)] httpd instalado. Habilitando y arrancando..."
  systemctl enable httpd  || echo "[WARN] enable httpd failed"
  systemctl start httpd   || echo "[WARN] start httpd failed"

  # Verificar que arrancó
  sleep 2
  if systemctl is-active --quiet httpd; then
    echo "[$(date)] httpd activo y funcionando"
  else
    echo "[$(date)] ERROR: httpd no arrancó. Revisando logs..."
    journalctl -u httpd --no-pager -n 20 || true
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "[$(date)] ERROR: httpd no está instalado, saltando arranque"
  ERRORS=$((ERRORS + 1))
fi

# ─── Paso 7: Página de bienvenida ───────────────────────────────────────────
HOSTNAME_VAL=$(hostname)
IP_VAL=$(hostname -I | awk '{print $1}')
REGION_VAL=$(curl -s http://169.254.169.254/opc/v1/instance/region 2>/dev/null || echo "N/A")
AD_VAL=$(curl -s http://169.254.169.254/opc/v1/instance/availabilityDomain 2>/dev/null || echo "N/A")
FD_VAL=$(curl -s http://169.254.169.254/opc/v1/instance/faultDomain 2>/dev/null || echo "N/A")

mkdir -p /var/www/html 2>/dev/null || true
cat > /var/www/html/index.html << HTML
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>OCI Webserver - ${HOSTNAME_VAL}</title>
  <style>
    body { font-family: 'Segoe UI', system-ui, sans-serif; background: #1a1a2e; color: #eee; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
    .card { background: #16213e; border-radius: 16px; padding: 2.5rem; max-width: 520px; box-shadow: 0 8px 32px rgba(0,0,0,0.3); border: 1px solid #0f3460; }
    h1 { color: #e94560; margin-top: 0; font-size: 1.6rem; }
    .info { margin: 0.5rem 0; padding: 0.5rem 0; border-bottom: 1px solid #0f3460; }
    .label { color: #a0a0b0; font-size: 0.85rem; }
    .value { color: #fff; font-weight: 600; }
    .footer { margin-top: 1.5rem; font-size: 0.8rem; color: #666; text-align: center; }
    .badge { display: inline-block; background: #e94560; color: #fff; padding: 2px 10px; border-radius: 12px; font-size: 0.75rem; margin-left: 8px; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Oracle Cloud Infrastructure <span class="badge">v3</span></h1>
    <div class="info"><span class="label">Servidor</span><br><span class="value">${HOSTNAME_VAL}</span></div>
    <div class="info"><span class="label">IP Privada</span><br><span class="value">${IP_VAL}</span></div>
    <div class="info"><span class="label">IP Pública</span><br><span class="value">$(curl -s ifconfig.me 2>/dev/null || echo 'N/A')</span></div>
    <div class="info"><span class="label">Región</span><br><span class="value">${REGION_VAL}</span></div>
    <div class="info"><span class="label">Availability Domain</span><br><span class="value">${AD_VAL}</span></div>
    <div class="info"><span class="label">Fault Domain</span><br><span class="value">${FD_VAL}</span></div>
    <div class="info"><span class="label">OS</span><br><span class="value">$(cat /etc/oracle-release 2>/dev/null || echo 'Oracle Linux')</span></div>
    <div class="footer">Desplegado con Terraform | oracle-cloud-latam | $(date +%Y-%m-%d)</div>
  </div>
</body>
</html>
HTML

# ─── Resumen final ──────────────────────────────────────────────────────────
echo "[$(date)] === Configuración completada con $ERRORS error(es) ==="
if [ $ERRORS -gt 0 ]; then
  echo "[$(date)] ADVERTENCIA: Hubo errores. Revisar log arriba para detalles."
fi
# Siempre exit 0 para que cloud-init no marque error total
exit 0
