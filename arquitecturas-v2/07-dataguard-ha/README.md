# Arquitectura 07 — DataGuard HA (Alta Disponibilidad de Base de Datos)

[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-07-dataguard-ha.zip)

## Descripción General

Esta arquitectura implementa una solución de **alta disponibilidad empresarial para bases de datos Oracle** utilizando **Oracle Data Guard**. Extiende la Arquitectura 06 añadiendo un DB System Standby automático en un segundo Availability Domain (AD2) que replica en tiempo real desde el primario en AD1. Diseñada para minimizar pérdidas de datos (RPO) y maximizar tiempo de actividad (RTO) con failover automático opcional.

### Caso de uso

- Aplicaciones críticas que requieren continuidad operacional 24/7
- Regulaciones que exigen recuperación ante desastres (DR) en la misma región
- Bases de datos con miles de transacciones por segundo que no pueden tolerar downtime

### Características principales

- **DataGuard automático**: Replicación asincrónica (MAXIMUM_PERFORMANCE) entre dos ADs
- **Webservers distribuidos**: Round-robin en AD1 y AD2 detrás de Load Balancer Flexible
- **Almacenamiento compartido NFS**: `/var/www/html/shared` sincronizado entre webservers
- **Bastion Service**: Acceso SSH seguro sin IPs públicas
- **Tres modos de protección**: Seleccionables según RTO/RPO requerido
- **Fast-Start Failover**: Conmutación automática de DB en caso de fallo del primario

## Arquitectura Técnica

```
                       ┌──────────────────┐
                       │    Internet      │
                       └────────┬─────────┘
                                │
                       ┌────────▼─────────┐
                       │  Load Balancer   │
                       │   Flexible       │
                       │  (10.0.10.0/24)  │
                       └────────┬─────────┘
                         ┌──────┴──────┐
                    ┌────▼──────┐  ┌──▼─────────┐
                    │ Webserver  │  │ Webserver   │
                    │ AD1        │  │ AD2         │
                    │ Apache+NFS │  │ Apache+NFS  │
                    │ (10.0.1.0) │  │ (10.0.2.0)  │
                    └────┬───────┘  └──┬──────────┘
                         │             │
                    ┌────▼─────────────▼────┐
                    │   NFS File Storage    │
                    │ /var/www/html/shared  │
                    │   (Mount Target AD1)  │
                    └───────────────────────┘
                         │             │
           ┌─────────────▼──┐    ┌────▼──────────┐
           │ DB Primario    │◄──►│ DB Standby      │
           │ Oracle 19c     │ DG │ Oracle 19c      │
           │ AD1            │    │ AD2             │
           │ (10.0.3.0/24)  │    │ (10.0.4.0/24)   │
           └────────────────┘    └─────────────────┘
           
         DataGuard: MAXIMUM_PERFORMANCE / ASYNC
         RPO > 0 | RTO ~ 5-10 min (manual)
```

## Recursos Desplegados

| Recurso | Descripción | Tipo OCI |
|---------|-------------|----------|
| VCN | Red virtual con 4 subnets privadas + 1 pública | Virtual Cloud Network |
| IGW | Puerta de Internet para tráfico público | Internet Gateway |
| NAT Gateway | NAT para tráfico privado saliente | NAT Gateway |
| Service Gateway | Acceso privado a servicios (Object Storage, DB) | Service Gateway |
| Subnet Pública LB | Aloja Load Balancer Flexible | Subnet 10.0.10.0/24 |
| Subnet Privada AD1 Web | Aloja webserver AD1 + Mount Target NFS | Subnet 10.0.1.0/24 |
| Subnet Privada AD2 Web | Aloja webserver AD2 | Subnet 10.0.2.0/24 |
| Subnet Privada AD1 DB | Aloja DB System Primario | Subnet 10.0.3.0/24 |
| Subnet Privada AD2 DB | Aloja DB System Standby (DataGuard) | Subnet 10.0.4.0/24 |
| Webserver AD1 | Compute flex 1 OCPU 8GB + Apache + NFS client | Instance 10.0.1.10 |
| Webserver AD2 | Compute flex 1 OCPU 8GB + Apache + NFS client | Instance 10.0.2.10 |
| NFS File Storage | Almacenamiento compartido entre webservers | File Storage Service |
| DB Primario | Oracle Database 19c Enterprise Edition - AD1 | DB System |
| DB Standby | Oracle Database 19c Enterprise Edition - AD2 (DataGuard) | DB System |
| Load Balancer | Load Balancer Flexible 10 Mbps - Round Robin | Load Balancer |
| Bastion | Bastion Service para SSH seguro | Bastion Service |
| NSGs | 6 Security Groups (Web, SSH, NFS, DB, Bastion, Egress) | Network Security Group |

## Shapes de Instancia Soportados

| Shape | OCPU | Memoria | Ventajas | Caso de uso |
|-------|------|---------|----------|------------|
| E4 Flex | 0.5-8 | 0.5-64 GB | Flexible, Graviton3 | Desarrollo, testing |
| E5 Flex | 0.5-8 | 0.5-64 GB | Última generación ARM | Producción con presupuesto optimizado |
| A1 Flex ARM | 0.5-80 | 0.5-480 GB | Máxima densidad de cómputo | Workloads ARM-nativas, big data |
| X9 | 0.5-128 | 0.5-512 GB | Máxima performance x86 | Bases de datos OLTP/DataWarehousing |

## Variables Principales

| Variable | Tipo | Descripción | Rango/Ejemplo |
|----------|------|-------------|---------------|
| `region` | string | Región OCI | `us-phoenix-1`, `us-ashburn-1`, `sa-santiago-1` |
| `availability_domains` | list(string) | ADs para desplegar (mín. 2) | `["AD1", "AD2", "AD3"]` |
| `vcn_cidr` | string | CIDR de la VCN | `10.0.0.0/16` |
| `dataguard_protection_mode` | string | Modo de protección DataGuard | `MAXIMUM_PERFORMANCE` \| `MAXIMUM_AVAILABILITY` \| `MAXIMUM_PROTECTION` |
| `dataguard_transport_type` | string | Tipo de transporte replicación | `ASYNC` \| `SYNC` |
| `db_admin_password` | string (sensitive) | Contraseña DBA (SYS/SYSTEM) | Mín. 12 caracteres, mayúscula, número, especial |
| `db_version` | string | Versión de Oracle | `19c`, `21c` |
| `db_edition` | string | Edición de Oracle | `ENTERPRISE_EDITION` (requerida para DataGuard) |
| `webserver_shape` | string | Shape para webservers | `VM.Standard.E4.Flex`, `VM.Standard.A1.Flex` |
| `webserver_ocpu` | number | OCPUs para webserver | 1, 2, 4 |
| `webserver_memory` | number | Memoria GB para webserver | 8, 16, 32 |
| `enable_fast_start_failover` | bool | Activa failover automático | `true` \| `false` |

## Estimación de Costos

### Componentes con costo (sin Always Free)

| Componente | Unidad | Estimado/mes USD | Notas |
|------------|--------|------------------|-------|
| 2x DB System Enterprise 19c | por OCPUs | $650-1,500 | Depende de shape + storage |
| 2x Webserver E4/E5 Flex | por OCPU-hora | $20-40 | Compute flexible |
| NFS File Storage | por GB | $0.10 | 100 GB = $10/mes aprox. |
| Load Balancer Flexible | por hora | $10-15 | 10 Mbps |
| Egress de datos | por GB | $0.01 | Solo si replica cross-region |
| **Total estimado** | — | **$700-1,700** | Rango base sin extras |

### Always Free Tier (si aplica)

| Recurso | Límite Always Free | Impacto |
|---------|-------------------|--------|
| Compute (2 x E2.1 micro) | Sí, pero DataGuard necesita E4+ | No reclaimable |
| Load Balancer | No, requiere pago | $10-15/mes fijo |
| DB System | Sí, pero solo 1x (DataGuard = 2x) | $650+/mes adicional |
| NFS File Storage | No, requiere pago | ~$10/mes |

**Recomendación**: Esta arquitectura es de **producción pagada**. Always Free cubre máximo VCN + 1 webserver pequeño. Para DataGuard HA completo, presupuestar ~$900-1,500/mes.

## Diferencias clave respecto a Arquitectura 06

| Aspecto | Arquitectura 06 | Arquitectura 07 |
|--------|-----------------|------------------|
| DB Systems | 1 primario (AD1) | 2: Primario (AD1) + Standby (AD2) |
| Replicación BD | N/A | DataGuard automático async/sync |
| Subnets DB | 1 (10.0.3.0/24) | 2 (10.0.3.0/24 + 10.0.4.0/24) |
| RTO | Manual recovery > 30 min | Automático con FSFO < 5 min |
| RPO | Desconocido (backup alone) | Configurable: 0 a >0 según modo |
| Costo BD | ~$350/mes | ~$700/mes (doble DB) |
| Complejidad | Media | Alta (DataGuard + 2 ADs) |

## Modos de Protección DataGuard (Matriz de decisión)

| Modo | RPO | RTO | Impacto Primario | Red | Latencia | Recomendación |
|------|-----|-----|------------------|-----|----------|---------------|
| **MAXIMUM_PERFORMANCE** | >0 (asincrónico) | 5-10 min manual | Ninguno | Internet/WAN | Ultra-baja | **Cross-region** (replicar a región remota) |
| **MAXIMUM_AVAILABILITY** | ~0 (sincrónico) | 5-10 min manual | Bajo | LAN/Metro | Baja | Mismo datacenter, máximo redundancia |
| **MAXIMUM_PROTECTION** | 0 (standby sincrónico) | 5-10 min manual | Alto (puede pausar) | LAN/Metro | Baja | Cero pérdida datos OBLIGATORIA |

## Requisitos Previos

### Cuenta OCI y Permisos

- Suscripción OCI con suficiente cuota:
  - Mínimo 2 DB Systems (verificar con límites de tenancy)
  - 2 Compute instances
  - 1 Load Balancer
  - 1 File Storage (NFS)
  - Bastion Service
- Usuario IAM con permisos para:
  - `database`, `compute`, `network`, `filestorage`, `loadbalancer`, `bastion`

### Software Local

```bash
# Verificar instalación
terraform -v       # >= 1.0
oci -v              # >= 3.0
ssh -V              # OpenSSH >= 7.x
curl --version      # para verificar endpoints

# Installer Terraform (si no existe)
# https://www.terraform.io/downloads.html

# Instalar OCI CLI
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install.sh)"

# Configurar credenciales OCI
oci setup config
# Guardará en ~/.oci/config
```

### Variables de Entorno

```bash
export OCI_REGION="us-phoenix-1"
export OCI_TENANCY_OCID="ocid1.tenancy.oc1....."
export OCI_USER_OCID="ocid1.user.oc1....."
```

### Base State Remoto (Recomendado)

Ejecutar primero Arquitectura 00-bootstrap-remotestate para crear backend remoto en Object Storage.

## Despliegue Rápido (Paso a Paso)

### Paso 1: Inicializar Terraform

```bash
cd arquitecturas-v2/07-dataguard-ha

# Con backend remoto (recomendado)
terraform init -backend-config=../00-bootstrap-remotestate/backend.hcl

# O con backend local (desarrollo)
terraform init
```

### Paso 2: Revisar Plan

```bash
# Mostrar cambios que se van a aplicar (~15 segundos)
terraform plan -out=tfplan

# Revisar output:
# Plan: XX to add, 0 to change, 0 to destroy
```

### Paso 3: Crear Variables

```bash
# Crear archivo terraform.tfvars
cat > terraform.tfvars << 'EOF'
region                       = "us-phoenix-1"
compartment_ocid             = "ocid1.compartment.oc1......"
availability_domains         = ["AD1", "AD2"]
vcn_cidr                      = "10.0.0.0/16"
dataguard_protection_mode    = "MAXIMUM_PERFORMANCE"
dataguard_transport_type     = "ASYNC"
db_admin_password            = "MySecureP@ss123"
db_edition                   = "ENTERPRISE_EDITION"
webserver_shape              = "VM.Standard.E5.Flex"
webserver_ocpu               = 1
webserver_memory             = 8
enable_fast_start_failover   = false
EOF
```

### Paso 4: Aplicar Configuración

```bash
# ADVERTENCIA: Este paso tarda 90-120 minutos
#   - DB System primario: ~60 min
#   - DataGuard Standby: ~30-45 min

terraform apply tfplan

# Monitorear progreso en OCI Console:
# Database > DB Systems > Estado

# Cuando termine, terraform mostrará:
# Apply complete! Resources: XX added, 0 changed, 0 destroyed
```

### Paso 5: Obtener Outputs

```bash
# Mostrar IPs, DNS, IDs importantes
terraform output

# Salida esperada:
# load_balancer_ip         = "132.XX.YY.ZZ"
# webserver_ad1_private_ip = "10.0.1.10"
# webserver_ad2_private_ip = "10.0.2.10"
# db_primary_ip            = "10.0.3.10"
# db_standby_ip            = "10.0.4.10"
```

## Verificación Post-Despliegue

### 1. Verificar Load Balancer

```bash
# Obtener IP del LB
LB_IP=$(terraform output -raw load_balancer_ip)

# Probar HTTP
curl -s http://${LB_IP}/ | head -20

# Esperado: Página Apache con "Hostname: webserver-ad1" o "webserver-ad2"
```

### 2. Verificar Round-Robin

```bash
# Ejecutar 6 veces y observar cambio de hostname
for i in $(seq 1 6); do
  echo "Request $i:"
  curl -s http://${LB_IP}/ | grep "Hostname:"
  sleep 1
done

# Esperado: Alternancia entre AD1 y AD2
```

### 3. Verificar NFS Compartido

```bash
# Probar acceso a archivo compartido en NFS
curl -s http://${LB_IP}/shared/shared.html

# Esperado: Contenido del archivo /var/www/html/shared/shared.html
```

### 4. Verificar DataGuard (CLI OCI)

```bash
# Obtener DB IDs
DB_PRIMARY_ID=$(terraform output -raw db_primary_system_id)
DB_STANDBY_ID=$(terraform output -raw db_standby_system_id)

# Listar asociaciones DataGuard
oci db data-guard-association list \
  --database-id ${DB_PRIMARY_ID} \
  --query 'data[*].{
    Role: role,
    PeerRole: "peer-role",
    State: "lifecycle-state",
    ProtectionMode: "protection-mode"
  }' \
  --output table

# Esperado:
# Role        | PeerRole    | State  | ProtectionMode
# PRIMARY     | STANDBY     | PEERED | MAXIMUM_PERFORMANCE
```

### 5. Verificar DataGuard (OCI Console)

1. Navegar a **Database > DB Systems**
2. Hacer clic en DB Primario
3. En sección "Data Guard Associations", verificar:
   - Estado: `Peered`
   - Protección: `MAXIMUM_PERFORMANCE`
   - Tipo: `Asynchronous`

### 6. Verificar Conectividad mediante Bastion

```bash
# Crear sesión SSH via Bastion al webserver AD1
oci bastion session create-managed-ssh \
  --bastion-id $(terraform output -raw bastion_id) \
  --target-os-user opc \
  --target-resource-id $(terraform output -raw webserver_ad1_instance_id) \
  --session-ttl-in-seconds 3600

# Conectarse (seguir instrucciones OCI)
ssh -i /path/to/key opc@<session-ip>

# Desde webserver, verificar NFS
df -h /var/www/html/shared

# Esperado: Mount point activo (ejemplo)
# 10.0.3.100:/mnt/nfs /var/www/html/shared nfs ... 100.0G 50.0G 50.0G 50%
```

## Limpieza (Destrucción de Recursos)

### Advertencia

⚠️ **DataGuard crea DOS DB Systems completos**. La destrucción eliminará ambos.

```bash
# Listar recursos a eliminar
terraform plan -destroy

# Destruir (tarda ~30-45 minutos)
terraform destroy

# Confirmación: escribe "yes"
# Esperar a que Terraform elimine DB Systems (recurso lento)
```

### Verificación Post-Limpieza

```bash
# Confirmar que no quedan recursos
oci db system list \
  --compartment-id $(terraform output -raw compartment_ocid) \
  --query 'data | length(@)'

# Esperado: 0 (o solo otros DB Systems si existen)
```

## Troubleshooting Común

### Problema 1: "Subnet does not have an available IP"

**Síntoma**: Terraform falla con error de subnet sin IPs disponibles.

**Causa**: Las subnets 10.0.3.0/24 y 10.0.4.0/24 están llenas. DB Systems usan IPs:
- 10.0.3.10-30 (primario)
- 10.0.4.10-30 (standby)
- Scan listener, listener, etc.

**Solución**:
```bash
# Aumentar CIDR de subnets en variables.tf
subnet_db_ad1_cidr = "10.0.3.0/23"   # En lugar de /24
subnet_db_ad2_cidr = "10.0.4.0/23"

terraform apply
```

### Problema 2: "DataGuard Standby stuck in provisioning"

**Síntoma**: Standby tarda >1 hora en provisionar, o queda en "PROVISIONING".

**Causa**: 
- Primario aún se está creando
- Cuota insuficiente de OCPUs
- Problema de conectividad de red entre ADs

**Solución**:
```bash
# Verificar estado del primario
oci db system get --db-system-id <DB_PRIMARY_ID> --query 'data.{State: "lifecycle-state"}'

# Si está "UPDATING" o "PROVISIONING", esperar
# Si lleva >90 min, considerar destroy y retry

# Verificar cuota de OCPUs
oci limits resource-availability list \
  --compartment-id <COMPARTMENT_ID> \
  --service-name database \
  --query 'data[?resource_name==`DbSystems`]'
```

### Problema 3: "ERROR: Health check failing for webserver"

**Síntoma**: Load Balancer marca webservers como "DOWN".

**Causa**: 
- Script user-data no ejecutó Apache
- NSG no permite tráfico HTTP 80 desde LB subnet
- Webserver está en estado error

**Solución**:
```bash
# SSH al webserver via Bastion y verificar Apache
sudo systemctl status apache2

# Si no está corriendo:
sudo systemctl start apache2
sudo systemctl enable apache2

# Verificar NSG permite 80 desde LB subnet
oci network security-group rules list \
  --network-security-group-id $(terraform output -raw webserver_nsg_id) \
  --query 'data[?direction==`INGRESS` && protocol==`6`]'

# Esperado: Regla con destination-cidr 10.0.10.0/24, destination-port-min 80
```

### Problema 4: "DataGuard shows UNSYNCHRONIZED after failover"

**Síntoma**: Después de failover, Standby (ahora Primario) muestra estado UNSYNCHRONIZED.

**Causa**: Logs de transacciones perdidos durante failover (RPO no cero).

**Solución**:
```bash
# Esperar a que se sincronice (puede tardar minutos)
while true; do
  STATE=$(oci db data-guard-association list \
    --database-id <NEW_PRIMARY_ID> \
    --query 'data[0]."lifecycle-state"' \
    --raw-output)
  echo "State: $STATE"
  [ "$STATE" = "AVAILABLE" ] && break
  sleep 10
done

# Si sigue desincronizado, verificar logs en la DB:
# SQL> SELECT * FROM v$dataguard_status;
```

## Siguiente Nivel: Arquitectura 08 — Peering Local

Una vez validada la HA de base de datos con DataGuard, el siguiente paso es escalar la arquitectura de **red** añadiendo otra VCN en topología Hub-Spoke:

- **Arquitectura 08 (Peering Local)**: 
  - Hub VCN (10.0.0.0/16) con stack completo (este despliegue)
  - Spoke VCN (10.1.0.0/16) con servidor backend
  - Local Peering Gateway para conectar ambas VCNs
  - Permite distribuir tráfico entre VCNs

Transición:
```bash
# En lugar de destroy 07, clonar para 08:
cp -r 07-dataguard-ha 08-peering-local
cd 08-peering-local
# Agregar módulo red_spoke + módulo peering-local
# Actualizar route tables de Hub + Spoke
```

## Referencias

- [Oracle DataGuard Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/19/dgcon/)
- [OCI Load Balancer](https://docs.oracle.com/en-us/iaas/Content/Balance/home.htm)
- [OCI File Storage Service](https://docs.oracle.com/en-us/iaas/Content/File/home.htm)
- [Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [OCI Best Practices for HA/DR](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm)

## Soporte

- Reportar issues en: https://github.com/jesmonsa/oracle-cloud-latam/issues
- Documentación base: `/arquitecturas-v2/README.md`
- Contacto: arquitectura@latam.oracle.com
