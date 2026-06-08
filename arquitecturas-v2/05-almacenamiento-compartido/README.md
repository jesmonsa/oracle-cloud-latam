# 05 - Almacenamiento Compartido (File Storage Service NFS)

## Descripción General

Arquitectura que expande la seguridad y aislamiento de la arquitectura 04 al agregar **File Storage Service (FSS)** — un sistema de archivos NFS empresarial gestionado por OCI. FSS proporciona un punto de montaje compartido entre los webservers, permitiendo sincronización de contenido en tiempo real y estado compartido de aplicaciones.

Esta arquitectura es esencial para aplicaciones web que requieren:
- Uploads/downloads compartidos entre múltiples instancias
- Sesiones persistentes sincronizadas
- Contenido estático compartido (imágenes, assets)
- Datos compartidos entre aplicaciones (caché, reportes)

### Características Principales

- **File Storage Service (FSS)**: NFS 3.0 gestionado por OCI en subnet privada
- **Mount Target**: IP privada en AD1 para montar NFS desde webservers
- **Cloud-init automático**: Montaje NFS sin intervención manual
- **NSG NFS**: Políticas de firewall específicas (puertos 111, 2048-2050)
- **Sincronización en tiempo real**: Cambios inmediatos reflejados en ambos webservers
- **Herencia de seguridad**: Mantiene bastion, nat gateway, webservers privados de arquitectura 04

---

## Diagrama de Arquitectura

```
                            Internet
                               │
                    ┌──────────┴──────────┐
                    ▼                     ▼
        ┌─────────────────────┐  ┌──────────────────────┐
        │  Load Balancer      │  │  Bastion Service     │
        │  (Público)          │  │  SSH via FSS/DB+     │
        │  HTTP: 80/443       │  │  Tuneles seguros     │
        │  10.0.10.0/24       │  │                      │
        └──────────┬──────────┘  └──────────┬───────────┘
                   │                        │
        ───────────┼───── VCN 10.0.0.0/16 ──┼─────────────
                   │     (Privada)          │
        ┌──────────┼─────────────────────────┼──────────┐
        │          │                         │          │
    ┌───┴──┐   ┌───┴──┐                  ┌──┴─────────┐│
    │ WS1  │   │ WS2  │                  │ Bastion    ││
    │ AD1  │   │ AD2  │                  │ Target     ││
    │10.0.1│   │10.0.2│                  │            ││
    └───┬──┘   └───┬──┘                  └──┬────────┘│
        │          │                        │         │
        │  ┌──────────────────────┐         │         │
        └─→│ NFS: /mnt/shared     │←────────┘         │
           │ (Mount Target)       │                   │
           │ FSS en AD1           │                   │
           │ 10.0.1.50            │                   │
           └──────────┬───────────┘                   │
                      │                               │
              ┌───────┴────────┐                      │
              ▼                ▼                      │
          NAT GW          Service GW                 │
        (outbound)      (OCI services)  ← ─ ─ ─ ─ ─ ┘
```

---

## Evolución desde Arquitectura 04

| Aspecto | 04 - Bastion Privado | 05 - Almacenamiento Compartido |
|--------|----------------------|--------------------------------|
| **Almacenamiento** | Solo volumen boot (local a instancia) | + FSS NFS compartido entre VMs |
| **Contenido Web** | Independiente por servidor | Sincronizado via NFS (/mnt/shared) |
| **NSG NFS** | No requerido | Sí (UDP/TCP puertos 111, 2048-2050) |
| **Punto Montaje** | N/A | /mnt/shared → Apache doc-root |
| **Escalabilidad** | Limitada (datos duplicados) | Alta (múltiples instancias, 1 FS) |
| **RPO/RTO** | Alto (sincronizar manual) | Bajo (sincronización NFS automática) |
| **Disponibilidad de datos** | Por instancia | Compartida (AD-redundante) |
| **Cumplimiento** | SOC2, ISO27001 base | + Data residency, backup compliance |

---

## Recursos Creados

| Recurso | Descripción | Tipo OCI |
|---------|-------------|----------|
| **VCN** | Red virtual 10.0.0.0/16 (heredada de 04) | Networking |
| **Subnets (3)** | LB pública, WS1 privada AD1, WS2 privada AD2 | Networking |
| **Internet Gateway** | Acceso público para LB | Networking |
| **NAT Gateway** | Outbound para WS1, WS2 (heredado) | Networking |
| **Service Gateway** | Acceso a OCI services sin salir VCN (heredado) | Networking |
| **Load Balancer Flexible** | LB público 10 Mbps | Networking |
| **VM.Standard.E4.Flex** | 2 webservers, 1 OCPU, 8GB cada uno | Compute |
| **Bastion Service** | SSH tunneling seguro | Security |
| **File Storage Service** | NFS 3.0 compartido, primeros 10GB gratuitos | Storage |
| **Mount Target** | IP privada 10.0.1.50 para montar FSS | Storage |
| **Network Security Groups (4)** | NSG LB, NSG WS, NSG Bastion, NSG NFS | Security |

---

## Tablas de Configuración

### Shapes Compatibles (Compute)

| Shape | vCPUs | Memoria | I/O NFS | Casos de Uso | Costo |
|-------|-------|---------|---------|--------------|-------|
| **E4.Flex** | 1-4 | 8-64 GB | Bueno | Desarrollo, NFS compartido ligero | ✓ Always Free (1 OCPU/8GB) |
| **E5.Flex** | 1-4 | 8-64 GB | Mejor | Producción, aplicaciones web | ✗ Pagado |
| **A1.Flex ARM** | 1-4 | 6-24 GB | Bueno | ARM optimizado, bajo costo | ✗ Pagado |
| **X9.Flex** | 2-64 | 32-1024 | Óptimo | Alto throughput NFS, databases | ✗ Muy pagado |

**Recomendación**: E4.Flex para Always Free. E5.Flex si requiere mejor rendimiento NFS.

### Variables Principales

| Variable | Descripción | Valor por Defecto | Tipo |
|----------|-------------|-------------------|------|
| `compartment_ocid` | OCID del compartment | (requerido) | String |
| `region` | Región OCI | (requerido) | String |
| `vcn_cidr` | CIDR de la VCN | `10.0.0.0/16` | String |
| `nfs_ruta_exportacion` | Ruta exportada por FSS | `/shared` | String |
| `nfs_punto_montaje` | Punto montaje en webservers | `/mnt/shared` | String |
| `nfs_tamanio_limite_gb` | Capacidad máxima FSS | `10` | Number |
| `bastion_cidr_permitidos` | CIDRs para acceso Bastion | `["0.0.0.0/0"]` | List |
| `bastion_ttl_segundos` | TTL sesiones SSH | `3600` | Number |
| `shape_ws` | Shape webservers | `VM.Standard.E4.Flex` | String |
| `webserver_ocpus` | OCPUs por WS | `1` | Number |
| `webserver_memory_gb` | Memoria en GB por WS | `8` | Number |

---

## Estimación de Costos

### Modelo Always Free Tier

```
Recurso                          | Cantidad | Costo Unitario  | Costo Total
───────────────────────────────────────────────────────────────────────
VCN + Subnets + IGW + NAT        | -        | Gratuito        | $0
Service Gateway                  | 1        | Gratuito        | $0
Load Balancer Flexible 10 Mbps  | 1        | Gratuito*       | $0
VM.Standard.E4.Flex 1 OCPU/8GB  | 2        | Gratuito*       | $0
Bastion Service                  | 1        | Gratuito        | $0
File Storage Service 10 GB       | 1        | Gratuito*       | $0
Mount Target NFS                 | 1        | Gratuito        | $0
Network Security Groups          | 4        | Gratuito        | $0
───────────────────────────────────────────────────────────────────────
TOTAL ESTIMADO (Always Free):    | -        | -               | $0 USD/mes
```

**Notas de Costo:**

- `*` Componentes dentro del Always Free tier (con límites)
- **FSS**: Primeros 10 GB gratuitos, después ~$0.18/GB-mes (~$180/mes a capacidad completa)
- **Dataless**: Si usas FSS con <10 GB: $0
- **NAT/LB**: Datos salientes varían (~$0.05/GB)
- **Escalada típica**: Con NFS compartido de 50 GB: ~$7.20/mes adicional por storage

**Estimación Realista (pequeño equipo):**
```
Almacenamiento NFS compartido: 10-50 GB
Tráfico saliente NFS: ~1-5 GB/mes
Costo mensual estimado: $0 - $5 USD (dentro Always Free + mínimo uso)
```

---

## Requisitos Previos

### Acceso OCI

- [ ] Cuenta OCI con Always Free tier activo
- [ ] Usuario con permisos: `MANAGE_VCN`, `MANAGE_INSTANCES`, `MANAGE_LOAD_BALANCER`, `MANAGE_BASTION`, **`MANAGE_FILE_SYSTEMS`**
- [ ] OCID compartment documentado

### Herramientas Locales

- [ ] **Terraform** 1.0+: `terraform --version`
- [ ] **OCI CLI** 2.0+: `oci --version`
- [ ] **SSH Keys** en ~/.ssh/:
  ```bash
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/oci_webserver -N ""
  ```

### Credenciales y Permisos

```bash
# Validar acceso OCI
oci iam compartment list

# Validar permisos FSS
oci fs file-system list --compartment-id $COMPARTMENT_OCID
# Debe retornar lista vacía o existentes, NO error de permisos
```

### Validar Disponibilidad de FSS en Región

```bash
# No todos los datos centers tienen FSS disponible
oci fs file-system list --compartment-id $COMPARTMENT_OCID \
  --availability-domain $AD1_NAME \
  --region $REGION
```

---

## Despliegue Rápido

### 1. Clonar Repositorio

```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas-v2/05-almacenamiento-compartido
```

### 2. Configurar Variables

```bash
cp terraform.tfvars.example terraform.tfvars

cat > terraform.tfvars << 'EOF'
compartment_ocid            = "ocid1.compartment.oc1..aaaaaaaa..."
region                      = "eu-madrid-1"
vcn_cidr                    = "10.0.0.0/16"
nfs_ruta_exportacion        = "/shared"
nfs_punto_montaje           = "/mnt/shared"
nfs_tamanio_limite_gb       = 10
bastion_cidr_permitidos     = ["203.0.113.0/24"]
shape_ws                    = "VM.Standard.E4.Flex"
webserver_ocpus             = 1
webserver_memory_gb         = 8
EOF
```

### 3. Inicializar Terraform

```bash
terraform init
terraform validate
terraform plan -out=tfplan
```

### 4. Revisar Plan

```bash
# Verificar recursos FSS en el plan
terraform show tfplan | grep -E "file_system|mount_target|nfs"

# Verificar NSG rules NFS (puertos 111, 2048-2050)
terraform show tfplan | grep -A3 "nfs"
```

### 5. Desplegar

```bash
terraform apply tfplan
# Esperar 10-15 minutos (FSS más lento que compute)

# Obtener outputs
terraform output -json > outputs.json
```

### 6. Capturar Variables de Salida

```bash
LB_IP=$(terraform output -raw load_balancer_ip)
FSS_ID=$(terraform output -raw file_system_id)
MOUNT_TARGET_IP=$(terraform output -raw mount_target_ip)
WS1_ID=$(terraform output -raw -json instance_ids | jq -r '.[0]')
BASTION_ID=$(terraform output -raw bastion_id)
```

---

## Verificación post-despliegue

### Verificar FSS creado

```bash
# Listar FSS en compartment
oci fs file-system list --compartment-id $COMPARTMENT_OCID

# Obtener detalles FSS
oci fs file-system get --file-system-id $FSS_ID
# Verifica: lifecycle-state = ACTIVE, metered-bytes = 0 (inicial)

# Listar Mount Target
oci fs mount-target list --compartment-id $COMPARTMENT_OCID \
  --file-system-id $FSS_ID
# Verifica: private-ip-addresses = [$MOUNT_TARGET_IP]
```

### Probar montaje NFS en webservers

```bash
# Crear sesión SSH
SESSION=$(oci bastion session create-managed-ssh \
  --bastion-id $BASTION_ID \
  --target-resource-id $WS1_ID \
  --target-os-username opc \
  --ssh-public-key-file ~/.ssh/oci_webserver.pub \
  --session-ttl-in-seconds 7200 \
  --wait-for-state ACTIVE \
  --query 'data.id' \
  --raw-output)

# Obtener comando SSH
oci bastion session get --session-id $SESSION \
  --query 'data."ssh-metadata"."command"' \
  --raw-output > /tmp/ssh_cmd.sh

# Ejecutar comandos en WS1
chmod +x /tmp/ssh_cmd.sh
bash /tmp/ssh_cmd.sh << 'EOF'
# Verificar montaje NFS activo
mount | grep nfs
# Esperado: 10.0.1.50:/shared on /mnt/shared type nfs (rw,...)

# Listar archivos en NFS
ls -la /mnt/shared
# Esperado: archivo inicial (index.html compartido)

# Verificar permisos
touch /mnt/shared/test_ws1.txt
ls -la /mnt/shared/test_ws1.txt

exit
EOF
```

### Verificar sincronización entre webservers

```bash
# WS1: crear archivo
bash /tmp/ssh_cmd.sh << 'EOF'
echo "Contenido desde WS1" > /mnt/shared/sincro_test.txt
exit
EOF

# WS2: verificar que existe
WS2_ID=$(terraform output -raw -json instance_ids | jq -r '.[1]')

SESSION2=$(oci bastion session create-managed-ssh \
  --bastion-id $BASTION_ID \
  --target-resource-id $WS2_ID \
  --target-os-username opc \
  --ssh-public-key-file ~/.ssh/oci_webserver.pub \
  --session-ttl-in-seconds 7200 \
  --wait-for-state ACTIVE \
  --query 'data.id' \
  --raw-output)

oci bastion session get --session-id $SESSION2 \
  --query 'data."ssh-metadata"."command"' \
  --raw-output > /tmp/ssh_cmd2.sh

bash /tmp/ssh_cmd2.sh << 'EOF'
cat /mnt/shared/sincro_test.txt
# Esperado: "Contenido desde WS1"
exit
EOF
```

### Probar acceso HTTP a contenido compartido

```bash
# Crear contenido compartido en WS1
bash /tmp/ssh_cmd.sh << 'EOF'
sudo mkdir -p /var/www/html/shared
sudo cp /mnt/shared/*.html /var/www/html/shared/ 2>/dev/null || true
sudo echo "<h1>Contenido Compartido via NFS</h1>" | sudo tee /var/www/html/shared/index.html
sudo chown -R apache:apache /var/www/html/shared
exit
EOF

# Acceder via Load Balancer desde local
curl -i http://$LB_IP/shared/index.html
# Esperado: HTTP 200 con "<h1>Contenido Compartido..."

# Cada curl probablemente llegará a WS1 o WS2 (round-robin)
# Pero ambas servirán el mismo contenido (sincronizado via NFS)
for i in {1..5}; do
  echo "Request $i:"
  curl -s http://$LB_IP/shared/index.html | head -1
done
```

### Monitorear espacio FSS

```bash
# Ver bytes usados en FSS
oci fs file-system get --file-system-id $FSS_ID \
  --query 'data.metered-bytes' --raw-output
# Esperado: bytes de los archivos creados

# Calcular % de utilización vs límite (10 GB default)
USED=$(oci fs file-system get --file-system-id $FSS_ID \
  --query 'data.metered-bytes' --raw-output)
LIMIT=$((10 * 1024 * 1024 * 1024))
PERCENT=$((USED * 100 / LIMIT))
echo "Uso FSS: $PERCENT% ($USED bytes / $LIMIT bytes)"
```

---

## Limpieza Completa

### Destruir recursos en orden

```bash
# NOTA: FSS debe estar "sin sesiones" para destruir
# Desconectar todos los montajes primero

# Desmontar NFS desde cada webserver (si requiere)
bash /tmp/ssh_cmd.sh << 'EOF'
sudo umount /mnt/shared 2>/dev/null || true
exit
EOF

# Destroy Terraform (incluye FSS)
terraform plan -destroy
terraform destroy

# Confirmar 'yes' cuando se pide
```

### Validar limpieza

```bash
# Verificar FSS eliminada
oci fs file-system list --compartment-id $COMPARTMENT_OCID | jq '.data | length'
# Esperado: 0

# Verificar instancias eliminadas
oci compute instance list --compartment-id $COMPARTMENT_OCID | jq '.data | length'
# Esperado: 0
```

---

## Troubleshooting

### Problema: "Mount target creation failed - availability domain"

**Síntoma**: Terraform falla en `oci_file_storage_mount_target` con error de AD

**Causa**: FSS no está disponible en AD seleccionada (algunos datacenters no tienen FSS)

**Solución**:
```bash
# Listar ADs con FSS disponible
oci fs availability-domain list --compartment-id $COMPARTMENT_OCID

# Si resultado vacío, FSS no está en región
# Cambiar region en terraform.tfvars a otra con FSS (ej: us-phoenix-1)

# Alternativamente, cambiar AD específico:
terraform apply -var="availability_domain_1=AD-2" # si está disponible
```

### Problema: "NFS mount fails: mount.nfs: Connection refused"

**Síntoma**: Comando `mount` dentro de webserver falla con connection refused

**Causa**: NSG no permite tráfico NFS (puertos 111, 2048-2050, 2049)

**Solución**:
```bash
# Verificar NSG NFS rules
oci network security-group rules list \
  --security-group-id $(terraform output -raw ws_nsg_id) | \
  grep -E "(111|2048|2049|2050)"

# Debe mostrar rules INGRESS para esos puertos desde FSS subnet
# Si no existe, reaplica Terraform:
terraform apply -var="force_nsgrule_update=true"
```

### Problema: "File system stuck in PROVISIONING state"

**Síntoma**: `terraform apply` cuelga esperando FSS, o FSS estado = PROVISIONING

**Causa**: FSS tarda más que timeout de Terraform (~20 min en raros casos)

**Solución**:
```bash
# Aumentar timeout en terraform.tf:
# En recurso oci_file_storage_file_system, agregar:
# timeouts {
#   create = "60m"  # default 40m
# }

# O verificar estado manual:
oci fs file-system get --file-system-id $FSS_ID --query 'data.lifecycle-state'

# Si ACTIVE: terraform apply nuevamente (recuperará estado)
# Si PROVISIONING: esperar 30 min más
# Si FAILED: eliminar y reintentar
oci fs file-system delete --file-system-id $FSS_ID --force
rm terraform.tfstate* # Force recreate
terraform apply
```

### Problema: "Permission denied writing to /mnt/shared"

**Síntoma**: Dentro webserver: `touch /mnt/shared/file.txt` → Permission denied

**Causa**: Usuario `opc` no tiene permisos de escritura en NFS

**Solución**:
```bash
# Dentro webserver (via Bastion):
bash /tmp/ssh_cmd.sh << 'EOF'
# Ver propietario actual
ls -ld /mnt/shared
# Típicamente: root:root 755

# Cambiar permisos (si eres root o sudo):
sudo chmod 777 /mnt/shared

# O agregar grupo:
sudo chown root:users /mnt/shared
sudo chmod 775 /mnt/shared
sudo usermod -a -G users opc

# Verificar:
touch /mnt/shared/test.txt
exit
EOF
```

---

## Siguiente Nivel: Arquitectura 06

Esta arquitectura es la base para **Base de Datos (Oracle DB System)**, donde se agrega:
- **Oracle Database System** en subnet privada dedicada
- **NSG Database** (puerto 1521 SQL*Net)
- Conexión desde webservers a BD
- Persistent data layer con backup automático
- Multi-instance application + shared storage + database tier

👉 **Siguiente paso**: [`../06-base-de-datos/README.md`](../06-base-de-datos/README.md)

---

## Deploy Button

[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-05-almacenamiento-compartido.zip)

---

## Soporte y Documentación

- [OCI File Storage Service - Guía Completa](https://docs.oracle.com/en-us/iaas/Content/File/home.htm)
- [NFS Mount Target - Configuración](https://docs.oracle.com/en-us/iaas/Content/File/Tasks/creatingmounttargets.htm)
- [Performance Tuning NFS en OCI](https://docs.oracle.com/en-us/iaas/Content/File/Tasks/tuningnfs.htm)
- [Terraform OCI FSS Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/file_storage_file_system)
