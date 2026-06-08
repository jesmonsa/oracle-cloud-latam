# Arquitectura 08 — Peering Local (Interconexión Hub-Spoke de VCNs)

[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-08-peering-local.zip)

## Descripción General

Esta arquitectura implementa una **topología de red empresarial Hub-Spoke** utilizando **Local Peering Gateway (LPG)** para interconectar dos VCNs en la misma región OCI. El Hub contiene los servicios principales (Load Balancer, webservers, base de datos) mientras que el Spoke aloja un servidor backend independiente con conectividad privada al Hub. Diseñada para segmentación de red, aislamiento de aplicaciones y escalabilidad horizontal.

### Caso de uso

- Separación lógica entre capa de presentación (Hub) y capa de backend (Spoke)
- Microsservicios/aplicaciones distribuidas en múltiples VCNs con conectividad privada
- Regulaciones de cumplimiento que requieren aislamiento de subredes
- Escalabilidad: agregar más Spokes para nuevos servicios sin rediseñar la red

### Características principales

- **Dos VCNs independientes**: Hub (10.0.0.0/16) y Spoke (10.1.0.0/16)
- **Local Peering Gateway**: Conexión privada de baja latencia entre VCNs
- **Bastion único**: Acceso SSH seguro a instancias en ambas VCNs
- **Load Balancer en Hub**: Distribuye tráfico a webservers del Hub
- **Backend Spoke privado**: Servidor sin exposición a Internet, accesible solo desde Hub
- **Route Tables compartidas**: Rutas automáticas para tráfico cross-VCN
- **NSGs inteligentes**: Permiten tráfico inter-VCN controlado

## Arquitectura Técnica

```
                         ┌──────────────────┐
                         │    Internet      │
                         └────────┬─────────┘
                                  │
┌─────────────────────────────────┼──────────────────────────────────┐
│           HUB VCN (10.0.0.0/16)  │                                  │
│                          ┌───────▼────────┐                         │
│                          │ Load Balancer  │                         │
│                          │   Flexible     │                         │
│                          │(10.0.10.0/24)  │                         │
│                          └───────┬────────┘                         │
│                                  │                                  │
│                          ┌───────▼────────┐                         │
│                          │  Webserver     │                         │
│                          │  Hub (Apache)  │                         │
│                          │ (10.0.1.0/24)  │                         │
│                          └────────────────┘                         │
│                                                                     │
│                          ┌──────────────┐                          │
│                          │  DB System   │                          │
│                          │ Oracle 19c   │                          │
│                          │(10.0.3.0/24) │                          │
│                          └──────┬───────┘                          │
│                                 │                                  │
│                          ┌──────▼────────┐                         │
│                          │  LPG Hub      │                         │
└──────────────────────────┼───────────────┼─────────────────────────┘
                           │   Peering     │
┌──────────────────────────┼───────────────┼─────────────────────────┐
│      SPOKE VCN (10.1.0.0/16) │  LPG Spoke │                        │
│                          └──────┬────────┘                         │
│                                 │                                  │
│                          ┌──────▼────────────┐                     │
│                          │  Backend Spoke    │                     │
│                          │  Server (Apache)  │                     │
│                          │  (10.1.1.0/24)    │                     │
│                          │  [PRIVADO]        │                     │
│                          └───────────────────┘                     │
│                                                                    │
│  Sin acceso a Internet (NAT para salida)                           │
└────────────────────────────────────────────────────────────────────┘

Peering = Local Peering Gateway (Ultra-baja latencia, sin costo)
```

## Recursos Desplegados

| Recurso | Descripción | Tipo OCI | Ubicación |
|---------|-------------|----------|----------|
| **VCN Hub** | Red virtual principal con servicios públicos | Virtual Cloud Network | 10.0.0.0/16 |
| **VCN Spoke** | Red virtual secundaria con backend privado | Virtual Cloud Network | 10.1.0.0/16 |
| **IGW Hub** | Internet Gateway para tráfico público Hub | Internet Gateway | Hub |
| **NAT GW Hub** | NAT Gateway para salida privada Hub | NAT Gateway | Hub |
| **NAT GW Spoke** | NAT Gateway para salida privada Spoke | NAT Gateway | Spoke |
| **Service GW Hub** | Service Gateway para servicios OCI Hub | Service Gateway | Hub |
| **Service GW Spoke** | Service Gateway para servicios OCI Spoke | Service Gateway | Spoke |
| **LPG Hub** | Local Peering Gateway (extremo Hub) | Local Peering Gateway | Hub |
| **LPG Spoke** | Local Peering Gateway (extremo Spoke) | Local Peering Gateway | Spoke |
| **Subnet Pública LB** | Aloja Load Balancer Flexible | Subnet 10.0.10.0/24 | Hub |
| **Subnet Privada Web Hub** | Aloja webserver Hub + Mount Target (future) | Subnet 10.0.1.0/24 | Hub |
| **Subnet Privada DB Hub** | Aloja DB System Oracle 19c | Subnet 10.0.3.0/24 | Hub |
| **Subnet Privada Backend Spoke** | Aloja backend server Spoke | Subnet 10.1.1.0/24 | Spoke |
| **Webserver Hub** | Compute flex 1 OCPU 8GB Apache | Instance 10.0.1.10 | Hub |
| **Backend Spoke** | Compute flex 1 OCPU 8GB Apache (privado) | Instance 10.1.1.10 | Spoke |
| **DB System Hub** | Oracle Database 19c Enterprise Edition | DB System | Hub 10.0.3.0/24 |
| **Load Balancer** | Load Balancer Flexible 10 Mbps Round-Robin | Load Balancer | Hub |
| **Bastion** | Bastion Service para acceso SSH seguro | Bastion Service | Hub (acceso a ambas VCNs) |
| **Route Table Hub** | Rutas para LB → web → DB → LPG Spoke | Route Table | Hub |
| **Route Table Spoke** | Rutas para backend → LPG Hub | Route Table | Spoke |
| **NSG Web** | Permite 80/443 desde LB | Network Security Group | Hub web subnet |
| **NSG DB** | Permite 1521 desde web, LPG hub/spoke | Network Security Group | Hub DB subnet |
| **NSG Backend** | Permite 80/443 desde LB Hub (via LPG) | Network Security Group | Spoke |
| **NSG Bastion** | Permite SSH desde Internet + tráfico salida | Network Security Group | Bastion |

## Shapes de Instancia Soportados

| Shape | OCPU | Memoria | Ventajas | Caso de Uso |
|-------|------|---------|----------|------------|
| **E4 Flex** | 0.5-8 | 0.5-64 GB | Flexible, ARM Graviton3 | Webservers, backends, desarrollo |
| **E5 Flex** | 0.5-8 | 0.5-64 GB | Última gen ARM, mejor precio | **Recomendado para esta arquitectura** |
| **A1 Flex ARM** | 0.5-80 | 0.5-480 GB | Máxima densidad ARM | Backend computation-heavy |
| **X9** | 0.5-128 | 0.5-512 GB | Máxima performance x86 | Backend OLTP/DataWarehouse |

**Recomendación**: E5 Flex 1 OCPU 8GB para webservers y backend (excelente relación costo-performance).

## Variables Principales

| Variable | Tipo | Descripción | Rango/Ejemplo |
|----------|------|-------------|---------------|
| `region` | string | Región OCI | `us-phoenix-1`, `sa-santiago-1` |
| `vcn_hub_cidr` | string | CIDR VCN Hub | `10.0.0.0/16` |
| `vcn_spoke_cidr` | string | CIDR VCN Spoke | `10.1.0.0/16` |
| `subnet_hub_lb_cidr` | string | CIDR subnet LB pública Hub | `10.0.10.0/24` |
| `subnet_hub_web_cidr` | string | CIDR subnet web privada Hub | `10.0.1.0/24` |
| `subnet_hub_db_cidr` | string | CIDR subnet DB privada Hub | `10.0.3.0/24` |
| `subnet_spoke_backend_cidr` | string | CIDR subnet backend privada Spoke | `10.1.1.0/24` |
| `db_admin_password` | string (sensitive) | Contraseña SYS/SYSTEM para DB | Mín. 12 chars, mayúscula, número, especial |
| `db_version` | string | Versión Oracle | `19c`, `21c` |
| `db_edition` | string | Edición de Oracle | `ENTERPRISE_EDITION` |
| `webserver_hub_shape` | string | Shape webserver Hub | `VM.Standard.E5.Flex` |
| `backend_spoke_shape` | string | Shape backend Spoke | `VM.Standard.E5.Flex` |
| `instance_ocpu` | number | OCPUs para instancias | 1, 2, 4, 8 |
| `instance_memory_gb` | number | Memoria GB para instancias | 8, 16, 32, 64 |
| `enable_bastion` | bool | Desplegar Bastion Service | `true`, `false` |

## Estimación de Costos

### Componentes con costo (sin Always Free)

| Componente | Unidad | Estimado/mes USD | Notas |
|------------|--------|------------------|-------|
| DB System Enterprise 19c (Hub) | por OCPUs | $350-800 | En Hub, 1 DB system (no DataGuard) |
| 2x Compute E5 Flex (Hub + Spoke) | por OCPU-hora | $30-60 | 1 OCPU cada uno, 8 GB RAM |
| Load Balancer Flexible | por hora | $10-15 | 10 Mbps, tráfico Hub |
| NAT Gateway (Hub + Spoke) | por millón paquetes | $5-10 | 2x NAT GWs (si hay salida) |
| Bastion Service | por sesión-hora | $0.10/hora | Acceso SSH, bajo costo |
| Egress de datos | por GB | $0.01 | Solo tráfico saliente a Internet |
| **Total estimado** | — | **$400-900** | Rango base |

### Always Free Tier (si aplica)

| Recurso | Límite Always Free | Impacto |
|---------|-------------------|--------|
| Compute (2 x E2.1 micro) | Sí, pero se necesitan E5+ | No reclaimable |
| VCN + Subnets | Sí, sin límite | Ambas VCNs libres |
| Load Balancer | No | $10-15/mes fijo |
| DB System | Sí (1), pero esta es 1 | ~$350+/mes |
| Bastion Service | No | ~$1-3/mes usage |

**Conclusión**: Always Free cubre VCN + 1 micro instance (no suficiente). Esta arquitectura requiere inversión mínima ~$400-900/mes.

## Comparación: Arquitectura 07 vs. 08

| Aspecto | Arquitectura 07 (DataGuard HA) | Arquitectura 08 (Peering Local) |
|--------|--------------------------------|--------------------------------|
| **Propósito** | HA de base de datos | Escalabilidad de red |
| **VCNs** | 1 | 2 (Hub + Spoke) |
| **DB Systems** | 2 (Primario + Standby DataGuard) | 1 (Solo Hub) |
| **Webservers** | 2 en 2 ADs | 1 Hub + 1 Spoke (mismo AD posible) |
| **Conectividad** | Intra-AD (DataGuard) | Inter-VCN (LPG) |
| **Peering** | N/A | Sí (Hub ↔ Spoke) |
| **Ruta transición** | 07 → 08 implica agregar Spoke + LPG | Extiende 07 con red distribuida |
| **Costo** | $700-1,500 (2 DBs) | $400-900 (1 DB) |
| **Complejidad Red** | Media (1 VCN, 2 ADs) | Alta (2 VCNs, LPG, routes) |
| **Complejidad BD** | Alta (DataGuard) | Baja (BD simple) |

## Requisitos Previos

### Cuenta OCI y Permisos

- Suscripción OCI activa con suficiente cuota:
  - 2 VCNs
  - 1 DB System (Hub)
  - 2 Compute instances (Hub + Spoke)
  - 1 Load Balancer
  - 1 Local Peering Gateway
  - Bastion Service
- Usuario IAM con permisos para:
  - `network`, `compute`, `database`, `loadbalancer`, `bastion`

### Software Local

```bash
# Verificar instalación
terraform -v       # >= 1.0
oci -v              # >= 3.0
ssh -V              # OpenSSH >= 7.x
curl --version

# Instalar/Actualizar Terraform
# https://www.terraform.io/downloads.html

# Instalar OCI CLI
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install.sh)"

# Configurar credenciales
oci setup config
# Creará ~/.oci/config
```

### Variables de Entorno

```bash
export OCI_REGION="us-phoenix-1"
export OCI_TENANCY_OCID="ocid1.tenancy.oc1....."
export OCI_USER_OCID="ocid1.user.oc1....."
export OCI_FINGERPRINT="aa:bb:cc:dd:ee:ff"
```

### Backend Remoto (Recomendado)

Ejecutar primero Arquitectura 00-bootstrap-remotestate para Object Storage backend.

## Despliegue Rápido (Paso a Paso)

### Paso 1: Inicializar Terraform

```bash
cd arquitecturas-v2/08-peering-local

# Con backend remoto
terraform init -backend-config=../00-bootstrap-remotestate/backend.hcl

# O local (desarrollo)
terraform init
```

### Paso 2: Revisar Plan de Despliegue

```bash
# Mostrar cambios (~20 segundos)
terraform plan -out=tfplan

# Output esperado:
# Plan: 35 to add, 0 to change, 0 to destroy
```

### Paso 3: Crear Variables

```bash
# Archivo terraform.tfvars
cat > terraform.tfvars << 'EOF'
region                    = "us-phoenix-1"
compartment_ocid          = "ocid1.compartment.oc1......"
vcn_hub_cidr              = "10.0.0.0/16"
vcn_spoke_cidr            = "10.1.0.0/16"
subnet_hub_lb_cidr        = "10.0.10.0/24"
subnet_hub_web_cidr       = "10.0.1.0/24"
subnet_hub_db_cidr        = "10.0.3.0/24"
subnet_spoke_backend_cidr = "10.1.1.0/24"
db_admin_password         = "MySecureP@ss123"
db_version                = "19c"
db_edition                = "ENTERPRISE_EDITION"
webserver_hub_shape       = "VM.Standard.E5.Flex"
backend_spoke_shape       = "VM.Standard.E5.Flex"
instance_ocpu             = 1
instance_memory_gb        = 8
enable_bastion            = true
EOF
```

### Paso 4: Aplicar Configuración

```bash
# ADVERTENCIA: Total ~70-80 minutos (DB System = recurso lento)
#   - VCNs + Subnets + Peering: ~5 min
#   - Compute instances: ~10 min
#   - DB System: ~60 min

terraform apply tfplan

# Monitorear en OCI Console:
# Database > DB Systems
# Compute > Instances
# Networking > Virtual Cloud Networks

# Cuando termine:
# Apply complete! Resources: 35 added, 0 changed, 0 destroyed
```

### Paso 5: Obtener Outputs

```bash
# Mostrar puntos de acceso importantes
terraform output

# Salida esperada:
# load_balancer_ip           = "132.XX.YY.ZZ"
# webserver_hub_private_ip   = "10.0.1.10"
# backend_spoke_private_ip   = "10.1.1.10"
# db_hub_private_ip          = "10.0.3.10"
# bastion_id                 = "ocid1.bastion.oc1......"
# peering_gateway_status     = "PEERED"
```

## Verificación Post-Despliegue

### 1. Verificar Peering Status

```bash
# Obtener estado del peering
terraform output peering_gateway_status

# Esperado: PEERED

# O via OCI CLI
oci network local-peering-gateway list \
  --vcn-id $(terraform output -raw vcn_hub_id) \
  --query 'data[0].{Name: "peer-advertised-cidr", Status: "peering-status"}'

# Esperado: Status = PEERED
```

### 2. Verificar Load Balancer (Hub)

```bash
# Obtener IP del LB
LB_IP=$(terraform output -raw load_balancer_ip)

# Probar HTTP
curl -s http://${LB_IP}/ | head -20

# Esperado: Página Apache con "Hostname: webserver-hub"
```

### 3. Verificar Conectividad Hub → Spoke

```bash
# SSH al webserver Hub via Bastion
BASTION_ID=$(terraform output -raw bastion_id)
WEB_HUB_ID=$(terraform output -raw webserver_hub_instance_id)

# Crear sesión SSH
oci bastion session create-managed-ssh \
  --bastion-id ${BASTION_ID} \
  --target-os-user opc \
  --target-resource-id ${WEB_HUB_ID} \
  --session-ttl-in-seconds 3600

# Conectarse y probar conectividad al backend Spoke
# (dentro de sesión SSH del webserver)
BACKEND_IP=$(terraform output -raw backend_spoke_private_ip)
curl -s http://${BACKEND_IP}/ | grep "Hostname:"

# Esperado: "Hostname: backend-spoke"
```

### 4. Verificar Routing Cross-VCN

```bash
# Desde webserver Hub, hacer ping al backend Spoke
# (via sesión SSH Bastion)

BACKEND_IP=$(terraform output -raw backend_spoke_private_ip)

# Dentro de sesión SSH:
ping -c 5 ${BACKEND_IP}

# Esperado: PING exitoso, latencia baja (~1-5 ms para LPG local)
```

### 5. Verificar NSGs permiten tráfico

```bash
# Listar reglas de seguridad en NSG Backend Spoke
oci network security-group rules list \
  --network-security-group-id $(terraform output -raw backend_nsg_id) \
  --query 'data[?direction==`INGRESS`]' \
  --output table

# Esperado: Regla con protocol 6 (TCP), port 80, source 10.0.0.0/16
```

### 6. Verificar DB System en Hub

```bash
# Obtener estado de DB
DB_ID=$(terraform output -raw db_hub_system_id)

oci db system get --db-system-id ${DB_ID} \
  --query 'data.{State: "lifecycle-state", VCN: "vcn-id"}'

# Esperado: State = AVAILABLE, VCN = Hub VCN ID
```

### 7. Verificación de Egress (NAT)

```bash
# Desde backend Spoke (via Bastion), verificar salida a Internet
# (dentro de sesión SSH)

curl -s https://checkip.amazonaws.com

# Esperado: IP del NAT Gateway Spoke
```

## Limpieza (Destrucción de Recursos)

```bash
# Listar recursos a eliminar
terraform plan -destroy

# Destruir (tarda ~30-40 minutos, DB System es el recurso lento)
terraform destroy

# Confirmación: escribe "yes"

# Esperar a eliminación completa
# Apply complete! Resources: 35 destroyed
```

### Verificación Post-Limpieza

```bash
# Confirmar que no quedan VCNs
oci network vcn list \
  --compartment-id $(terraform output -raw compartment_ocid) \
  --query 'data | length(@)'

# Esperado: 0 (o número anterior si existían otras)
```

## Troubleshooting Común

### Problema 1: "Peering status stuck in PROVISIONING"

**Síntoma**: LPG permanece en PROVISIONING más de 10 minutos.

**Causa**: 
- Las VCNs no tienen rutas configuradas para el LPG
- Conflicto de subredes (CIDRs solapados)
- Problemas transitorios de API OCI

**Solución**:
```bash
# Verificar que los CIDRs no se solapan
terraform plan | grep -i "cidr"
# Hub: 10.0.0.0/16, Spoke: 10.1.0.0/16 (OK)

# Si se solapan:
# Editar terraform.tfvars:
# vcn_spoke_cidr = "10.2.0.0/16"   # En lugar de 10.1.0.0/16

# Destruir y reintentar
terraform destroy -auto-approve
terraform apply
```

### Problema 2: "Backend Spoke no responde desde Hub"

**Síntoma**: Conectividad Hub → Spoke fallida (timeout en curl/ping).

**Causa**: 
- Route tables incompletas en Hub o Spoke
- NSG deniega tráfico cross-VCN
- LPG no está en estado PEERED

**Solución**:
```bash
# Paso 1: Verificar peering
terraform output peering_gateway_status
# Debe ser: PEERED

# Paso 2: Verificar rutas en Hub
oci network route-table list \
  --vcn-id $(terraform output -raw vcn_hub_id) \
  --query 'data[0].{ID: id, Rules: "route-rules"}' \
  --output table

# Esperado: Ruta a 10.1.0.0/16 con destino LPG

# Paso 3: Verificar NSG permite tráfico
oci network security-group rules list \
  --network-security-group-id $(terraform output -raw backend_nsg_id) \
  --query 'data[?direction==`INGRESS` && protocol==`6`]'

# Esperado: Regla con source 10.0.0.0/16, destination-port 80

# Si falta, agregar manualmente o redeploy
terraform apply -var="enable_bastion=true"
```

### Problema 3: "ERROR: DB System provisioning timeout"

**Síntoma**: DB System tarda >90 minutos o queda en PROVISIONING.

**Causa**: 
- Cuota de OCPUs insuficiente
- Problema de capacidad en región
- Subnet DB sin IPs disponibles

**Solución**:
```bash
# Verificar cuota
oci limits resource-availability list \
  --compartment-id <COMPARTMENT_ID> \
  --service-name database

# Si cuota insuficiente:
# - Reducir instance_ocpu a 0.5 (si es flex)
# - O cambiar región
# - O solicitar aumento de cuota en OCI Console

# Aumentar subnet DB
# En terraform.tfvars:
# subnet_hub_db_cidr = "10.0.3.0/23"   # En lugar de /24

terraform apply
```

### Problema 4: "Bastion no permite SSH a instancias"

**Síntoma**: Error al crear sesión SSH via Bastion.

**Causa**: 
- Bastion no tiene permisos para acceder a subnets privadas
- Compute instances no tienen VNIC privada
- NSG Bastion deniega tráfico de salida

**Solución**:
```bash
# Verificar que instancias están en subnets privadas
oci compute instance list \
  --compartment-id <COMPARTMENT_ID> \
  --query 'data[*].{Name: "display-name", State: "lifecycle-state"}'

# Esperado: RUNNING

# Verificar NSG Bastion tiene regla de egreso
oci network security-group rules list \
  --network-security-group-id $(terraform output -raw bastion_nsg_id) \
  --query 'data[?direction==`EGRESS`]'

# Esperado: Regla con protocol 6 (TCP), destination CIDR 10.0.0.0/16 y 10.1.0.0/16
```

### Problema 5: "Load Balancer marked backend as DOWN"

**Síntoma**: Healthcheck falla en webserver Hub.

**Causa**: 
- Apache no está corriendo en webserver
- NSG no permite tráfico HTTP 80 desde LB subnet
- Port 80 no está abierto en firewall Linux

**Solución**:
```bash
# SSH al webserver Hub via Bastion
oci bastion session create-managed-ssh \
  --bastion-id $(terraform output -raw bastion_id) \
  --target-os-user opc \
  --target-resource-id $(terraform output -raw webserver_hub_instance_id)

# Dentro de sesión SSH:
sudo systemctl status apache2
# Si está DOWN:
sudo systemctl start apache2
sudo systemctl enable apache2

# Verificar puerto 80
sudo netstat -tuln | grep 80
# Esperado: LISTEN en puerto 80

# Verificar NSG Web permite 80 desde LB
oci network security-group rules list \
  --network-security-group-id $(terraform output -raw web_nsg_id) \
  --query 'data[?direction==`INGRESS` && protocol==`6`]'

# Esperado: source 10.0.10.0/24, destination-port-min 80
```

## Siguiente Nivel: Arquitectura 09 — Peering Remoto

Una vez dominada la interconexión local Hub-Spoke con LPG, el siguiente paso es escalar geográficamente:

- **Arquitectura 09 (Peering Remoto)**:
  - VCN Hub en región principal (ej. us-phoenix-1)
  - VCN remota en otra región (ej. sa-santiago-1)
  - Remote Peering Connection (RPC) entre regiones
  - Replica datos a través de regiones para DR geográfico
  - Latencia mayor que LPG, pero costo similar

Transición:
```bash
# Opción 1: Agregar módulo RPC a 08
cd 08-peering-local
# Crear red_remota en región diferente
# Agregar módulo peering-remoto
# Actualizar route tables

# Opción 2: Nuevo stack 09
cp -r 08-peering-local 09-peering-remoto
# Reconfigurar para dos regiones
```

## Referencias y Documentación

- [OCI Local Peering Gateway](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localpeering.htm)
- [OCI Load Balancer Best Practices](https://docs.oracle.com/en-us/iaas/Content/Balance/Concepts/balanceoverview.htm)
- [Terraform OCI Provider - Networking](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_local_peering_gateway)
- [OCI Security Groups](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/securitygroups.htm)
- [OCI Route Tables](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingroutetables.htm)
- [Hub and Spoke Network Model](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)

## Soporte y Contribuciones

- Reportar issues: https://github.com/jesmonsa/oracle-cloud-latam/issues
- Documentación del repositorio: `/arquitecturas-v2/README.md`
- Discussiones: https://github.com/jesmonsa/oracle-cloud-latam/discussions
- Contacto: arquitectura@latam.oracle.com

---

**Última actualización**: 2026-04-12  
**Versión**: 2.0  
**Status**: Production-Ready
