# Arquitectura 09 — Peering Remoto (Interconexión Cross-Region vía DRG)

## Descripción General

Esta arquitectura demuestra la interconexión de **dos VCNs distribuidas en regiones diferentes** utilizando Dynamic Routing Gateways (DRG) y Remote Peering Connections (RPC). Es una solución empresarial para escenarios de disaster recovery (DR), distribución geográfica de cargas de trabajo, mejora de latencia regional y redundancia de datos.

La arquitectura implementa un modelo **Hub-Spoke** cross-region donde la región 1 actúa como concentrador principal (us-ashburn-1) alojando el load balancer público y servidores web, mientras que la región 2 (us-phoenix-1) alberga servicios backend privados. La conectividad entre regiones se establece mediante DRGs interconectados por RPC, permitiendo que el tráfico se enrute de forma segura y eficiente entre las dos regiones.

### Casos de Uso

- **Disaster Recovery**: Mantener réplicas de aplicaciones en diferentes regiones geográficas
- **Distribución Geográfica**: Servir a usuarios en múltiples zonas con baja latencia regional
- **Segregación de Cargas**: Separar frontend público de backend privado en regiones distintas
- **Cumplimiento Regulatorio**: Almacenar datos en regiones específicas según requisitos de soberanía
- **High Availability**: Implementar failover automático entre regiones
- **Escalabilidad Horizontal**: Distribuir carga de trabajo entre infraestructuras regionales

---

## Topología de la Arquitectura

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│  ┌─────────────────────── Región 1 (us-ashburn-1) ──────────────────────┐  │
│  │                                                                        │  │
│  │  ┌────────────────────────────────────────────────────────────┐  │  │
│  │  │           VCN Hub: 10.0.0.0/16                                │  │  │
│  │  │                                                                │  │  │
│  │  │  ┌──────────────────────────────────────────────────────────┐ │  │  │
│  │  │  │         Subnet Pública: 10.0.0.0/24                      │ │  │  │
│  │  │  │  ┌────────────────────────────────────────────────────┐  │ │  │  │
│  │  │  │  │                                                    │  │ │  │  │
│  │  │  │  │  Load Balancer Público (Puerto 80/443)           │  │ │  │  │
│  │  │  │  │                                                    │  │ │  │  │
│  │  │  │  └────────────────────────────────────────────────────┘  │ │  │  │
│  │  │  │           ▼                                           │ │  │  │
│  │  │  │  NSG: Tráfico HTTP/HTTPS público                     │ │  │  │
│  │  │  │  (Ingress: 0.0.0.0/0:80,443 → LB)                   │ │  │  │
│  │  │  └──────────────────────────────────────────────────────────┘ │  │  │
│  │  │                          ▼                                  │  │  │
│  │  │  ┌──────────────────────────────────────────────────────────┐ │  │  │
│  │  │  │         Subnet Privada Hub: 10.0.1.0/24              │ │  │  │
│  │  │  │                                                        │ │  │  │
│  │  │  │  ┌─────────────────────────────────────────────────┐ │ │  │  │
│  │  │  │  │  Instancias Web (Apache)                        │ │ │  │  │
│  │  │  │  │  • web-1: 10.0.1.10                            │ │ │  │  │
│  │  │  │  │  • web-2: 10.0.1.20 (opcional)                 │ │ │  │  │
│  │  │  │  └─────────────────────────────────────────────────┘ │ │  │  │
│  │  │  │  NSG: Tráfico LB + RPC desde VCN Spoke            │ │  │  │
│  │  │  │  (Ingress: 10.0.0.0/24 + 10.2.0.0/16)            │ │  │  │
│  │  │  └────────────────────────────────────────────────────────┘ │  │  │
│  │  │                                                        │  │  │
│  │  │  ┌────────────────────────────────────────────────────────┐ │  │  │
│  │  │  │         Subnet Privada Bastion: 10.0.2.0/24      │ │  │  │
│  │  │  │                                                   │ │  │  │
│  │  │  │  Bastion Service (Acceso SSH administrado)      │ │  │  │
│  │  │  │  NSG: SSH desde Internet (oci-service)          │ │  │  │
│  │  │  └────────────────────────────────────────────────────────┘ │  │  │
│  │  │                                                        │  │  │
│  │  │  ┌────────────────────────────────────────────────────────┐ │  │  │
│  │  │  │         Dynamic Routing Gateway (DRG)            │ │  │  │
│  │  │  │  • Attachment VCN Hub                            │ │  │  │
│  │  │  │  • Attachment RPC (Remote Peering)              │ │  │  │
│  │  │  │  • Rutas dinámicas a 10.2.0.0/16 vía RPC        │ │  │  │
│  │  │  └────────────────────────────────────────────────────────┘ │  │  │
│  │  │                                                        │  │  │
│  │  └────────────────────────────────────────────────────────────┘  │  │
│  │                                                                │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                    │                                  │
│                                    │ Remote Peering Connection (RPC)  │
│                                    │ Conexión Encriptada Cross-Region│
│                                    │                                  │
│                                    ▼                                  │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │                                                                │  │
│  │  ┌─────────────────── Región 2 (us-phoenix-1) ──────────────┐ │  │
│  │  │                                                            │ │  │
│  │  │  ┌────────────────────────────────────────────────────────┐ │ │  │
│  │  │  │           VCN Spoke: 10.2.0.0/16                     │ │ │  │
│  │  │  │                                                       │ │ │  │
│  │  │  │  ┌────────────────────────────────────────────────────┐│ │ │  │
│  │  │  │  │         Subnet Privada Backend: 10.2.1.0/24      ││ │ │  │
│  │  │  │  │                                                  ││ │ │  │
│  │  │  │  │  ┌────────────────────────────────────────────┐ ││ │ │  │
│  │  │  │  │  │  Instancias Backend (API/Datos)           │ ││ │ │  │
│  │  │  │  │  │  • backend-1: 10.2.1.10 (DB Primaria)    │ ││ │ │  │
│  │  │  │  │  │  • backend-2: 10.2.1.20 (DB Standby)     │ ││ │ │  │
│  │  │  │  │  └────────────────────────────────────────────┘ ││ │ │  │
│  │  │  │  │  NSG: RPC desde VCN Hub (10.0.0.0/16)       ││ │ │  │
│  │  │  │  └────────────────────────────────────────────────────┘│ │ │  │
│  │  │  │                                                       │ │ │  │
│  │  │  │  ┌────────────────────────────────────────────────────┐│ │ │  │
│  │  │  │  │         Dynamic Routing Gateway (DRG)            ││ │ │  │
│  │  │  │  │  • Attachment VCN Spoke                         ││ │ │  │
│  │  │  │  │  • Attachment RPC (Remote Peering)             ││ │ │  │
│  │  │  │  │  • Rutas dinámicas a 10.0.0.0/16 vía RPC       ││ │ │  │
│  │  │  │  └────────────────────────────────────────────────────┘│ │ │  │
│  │  │  │                                                       │ │ │  │
│  │  │  └────────────────────────────────────────────────────────┘ │ │  │
│  │  │                                                            │ │  │
│  │  └────────────────────────────────────────────────────────────┘ │  │
│  │                                                                  │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                        │
└──────────────────────────────────────────────────────────────────────────────┘

Flujo de Tráfico Típico:
1. Cliente externo → Load Balancer Público (Región 1)
2. Load Balancer → Web Servers (Subnet privada Región 1)
3. Web Servers → Backend Privado (Subnet privada Región 2 vía RPC + DRG)
4. Respuesta regresa por ruta inversa
```

---

## Recursos Desplegados

| Recurso | Descripción | Tipo OCI |
|---------|-------------|----------|
| VCN Hub (Región 1) | Red virtual 10.0.0.0/16 con IG, NAT, SGW | Virtual Cloud Network |
| VCN Spoke (Región 2) | Red virtual 10.2.0.0/16 (privada, sin IG) | Virtual Cloud Network |
| Subnet Pública Hub | 10.0.0.0/24 con acceso directo a Internet | Subnet |
| Subnet Privada Hub Web | 10.0.1.0/24 para servidores web | Subnet |
| Subnet Privada Hub Bastion | 10.0.2.0/24 para acceso SSH | Subnet |
| Subnet Privada Spoke Backend | 10.2.1.0/24 para servidores backend | Subnet |
| Internet Gateway (Hub) | Permite egreso público desde Región 1 | Internet Gateway |
| NAT Gateway (Hub) | Permite egreso desde subnets privadas | NAT Gateway |
| Service Gateway (Hub) | Acceso a servicios OCI sin Internet | Service Gateway |
| DRG Región 1 | Dynamic Routing Gateway (concentrador) | Dynamic Routing Gateway |
| DRG Región 2 | Dynamic Routing Gateway (remoto) | Dynamic Routing Gateway |
| Remote Peering Connection | Enlace encriptado entre DRGs | Remote Peering Connection |
| Load Balancer | Balanceador de carga público HTTP/HTTPS | Network Load Balancer |
| Network Security Group (LB) | Seguridad para load balancer | Network Security Group |
| Network Security Group (Web) | Seguridad para servidores web | Network Security Group |
| Network Security Group (Backend) | Seguridad para servidores backend | Network Security Group |
| Network Security Group (Bastion) | Seguridad para bastion service | Network Security Group |
| Instance (Web 1) | Instancia Apache en Región 1 | Compute Instance |
| Instance (Backend 1) | Instancia Apache en Región 2 | Compute Instance |
| Instance (Backend 2) | Instancia standby en Región 2 | Compute Instance |
| Bastion Service | Acceso SSH administrado a instancias privadas | Bastion Service |

**Total de recursos**: 23 componentes principales

---

## Compatibilidad de Shapes

Esta arquitectura se ha validado con los siguientes shapes de compute:

| Shape | vCPU | RAM | Costo/mes (Always Free) | Recomendación |
|-------|------|-----|-------------------------|----------------|
| **E4 Flex (Default)** | 0.1-4 | 0.5-24 GB | Gratis (10 GB) | Producción web, pequeño |
| **E5 Flex** | 0.1-4 | 0.5-24 GB | Gratis (10 GB) | Recomendado para backend |
| **A1 Flex (ARM)** | 0.1-4 | 0.5-24 GB | Gratis (4 instancias) | Costo mínimo (ARM64) |
| **X9** | 1-128 | 15-2000 GB | ~$2.50/hora | Enterprise HPC/ML |
| **VM.Standard3.Flex** | 0.1-4 | 0.5-24 GB | Paid | Cargas mixtas |

**Recomendación**: Para desarrollo/testing, usar A1 Flex o E4 Flex. Para producción, E5 Flex (mejor relación vCPU/RAM).

---

## Variables Principales

| Variable | Valor Predeterminado | Descripción |
|----------|-------------------|-------------|
| `tenancy_ocid` | (requerido) | OCID del tenancy OCI |
| `region` | `us-ashburn-1` | Región primaria para VCN Hub |
| `region2` | `us-phoenix-1` | Región secundaria para VCN Spoke |
| `compartment_id` | (requerido) | OCID del compartment destino |
| `vcn_hub_cidr` | `10.0.0.0/16` | CIDR de la VCN Hub |
| `subnet_hub_public_cidr` | `10.0.0.0/24` | CIDR subnet pública (LB) |
| `subnet_hub_private_cidr` | `10.0.1.0/24` | CIDR subnet privada (web) |
| `subnet_hub_bastion_cidr` | `10.0.2.0/24` | CIDR subnet privada (bastion) |
| `vcn_spoke_cidr` | `10.2.0.0/16` | CIDR de la VCN Spoke |
| `subnet_spoke_backend_cidr` | `10.2.1.0/24` | CIDR subnet privada (backend) |
| `instance_shape` | `VM.Standard.E4.Flex` | Shape de las instancias compute |
| `instance_ocpus` | `1` | vCPU asignados por instancia |
| `instance_memory_gb` | `4` | GB de memoria por instancia |
| `instance_image_ocid` | (regional) | OCID de imagen Oracle Linux 9 |
| `enable_bastion` | `true` | Habilitar Bastion Service |
| `enable_drg_routing` | `true` | Habilitar enrutamiento dinámico DRG |
| `enable_monitoring` | `true` | Habilitar métricas y alarmas |
| `tags` | `{ Arquitectura = "09-peering" }` | Tags para organización y costing |

---

## Estimación de Costos

### Modelo Always Free (Desarrollo/Testing)

```
Región 1 (us-ashburn-1):
  • 2x Compute (E4.Flex, 1 OCPU, 4GB RAM): Gratis (crédito Always Free)
  • Load Balancer: $0.025/hora = ~$18/mes
  • DRG: Gratis (primer puerto)
  • Data Transfer (intra-region): Gratis
  ────────────────────────────────────
  Total Región 1: ~$18/mes

Región 2 (us-phoenix-1):
  • 2x Compute (E4.Flex, 1 OCPU, 4GB RAM): Gratis (crédito Always Free)
  • DRG: Gratis (primer puerto)
  • Data Transfer (intra-region): Gratis
  ────────────────────────────────────
  Total Región 2: Gratis

Cross-Region:
  • Remote Peering Connection: $0.01/GB (data egress inter-region)
  • Asumiendo 10 GB/día = ~$3/mes
  ────────────────────────────────────
  COSTO TOTAL MENSUAL: ~$21/mes

Notas:
  Always Free tier cubre 2 instancias E4.Flex de 1 OCPU en cada región
  Los primeros 2 puertos de DRG son gratis (RPC es un puerto)
  Load Balancer se cobra por hora de escucha
  Data transfer inter-region: $0.01/GB saliente
```

### Producción Estimada (1000 req/min)

```
Región 1 - Frontend:
  • 3x Compute (E5.Flex, 2 OCPU, 8GB): $60/mes
  • Load Balancer (100 Mbps): $90/mes
  • DRG (5 puertos): $50/mes
  ─────────────────────────────
  Subtotal: $200/mes

Región 2 - Backend:
  • 3x Compute (E5.Flex, 4 OCPU, 16GB): $200/mes
  • Data volume (100GB): $2/mes
  • DRG (5 puertos): $50/mes
  ─────────────────────────────
  Subtotal: $252/mes

Data Transfer Cross-Region (500 GB/mes):
  • $0.01/GB x 500 GB: $5/mes
  ─────────────────────────────
  TOTAL MENSUAL: ~$457/mes
```

---

## Prerrequisitos

Antes de desplegar esta arquitectura, asegúrate de cumplir con:

### 1. Acceso y Permisos OCI

- [ ] Cuenta OCI activa con permisos administrativos
- [ ] Tenancy con **dos regiones suscritas** (us-ashburn-1 + us-phoenix-1)
  - Para verificar: OCI Console > Administration > Tenancy Details > Subscribed Regions
  - Si no aparecen ambas regiones, solicitar activación a OCI Support
- [ ] Usuario IAM con políticas de acceso:
  ```
  ALLOW group Administrators to manage virtual-cloud-networks in tenancy
  ALLOW group Administrators to manage internet-gateways in tenancy
  ALLOW group Administrators to manage nat-gateways in tenancy
  ALLOW group Administrators to manage service-gateways in tenancy
  ALLOW group Administrators to manage drgs in tenancy
  ALLOW group Administrators to manage load-balancers in tenancy
  ALLOW group Administrators to manage instances in tenancy
  ALLOW group Administrators to manage security-groups in tenancy
  ALLOW group Administrators to manage bastions in tenancy
  ALLOW group Administrators to manage instance-pools in tenancy
  ```

### 2. Herramientas Locales

- [ ] **Terraform** >= 1.5.0
  ```bash
  terraform --version
  ```
- [ ] **OCI Terraform Provider** >= 6.0.0
  - Se instalará automáticamente con `terraform init`
- [ ] **OCI CLI** >= 3.27.0 (opcional, para validación)
  ```bash
  oci --version
  ```
- [ ] **Git** para clonar el repositorio
  ```bash
  git clone https://github.com/jesmonsa/oracle-cloud-latam.git
  cd oracle-cloud-latam/arquitecturas-v2/09-peering-remoto
  ```

### 3. Credenciales OCI

- [ ] API Key configurada localmente:
  - Ubicación típica: `~/.oci/config` y `~/.oci/oci_api_key.pem`
  - Instrucciones: https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm
- [ ] Variables de entorno alternativas:
  ```bash
  export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..."
  export TF_VAR_user_ocid="ocid1.user.oc1..."
  export TF_VAR_fingerprint="xx:xx:xx:xx:xx"
  export TF_VAR_private_key_path="~/.oci/oci_api_key.pem"
  export TF_VAR_region="us-ashburn-1"
  ```

### 4. Infraestructura Preexistente

- [ ] Backend remoto Terraform configurado (del módulo `00-bootstrap-remotestate`)
  ```bash
  # Archivo: backend.hcl debe existir
  ls -la ../00-bootstrap-remotestate/backend.hcl
  ```
- [ ] Compartment de destino ya creado (o usar tenancy root)
- [ ] VPCs existentes con CIDR no conflictivos (10.0.0.0/16, 10.2.0.0/16)

### 5. Validaciones Previas

```bash
# Verificar conectividad con OCI
oci iam user get --user-id ocid1.user.oc1...

# Validar ambas regiones están activas
oci iam tenancy get

# Verificar créditos y límites de recursos
oci compute shapes list --region us-ashburn-1 | head -5
oci compute shapes list --region us-phoenix-1 | head -5
```

---

## Despliegue Rápido

### Opción 1: Deploy Button (Recomendado)

Haz clic en el botón para desplegar en la consola OCI:

[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-09-peering-remoto.zip)

**Pasos**:
1. Haz clic en el botón arriba
2. En OCI Resource Manager, selecciona tu compartment
3. Revisa variables (región1, región2, CIDRs)
4. Haz clic en "Next"
5. Valida el plan de Terraform
6. Haz clic en "Apply"
7. Espera 5-10 minutos a que se complete

### Opción 2: CLI Local (Más Control)

```bash
# 1. Clonar repositorio
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas-v2/09-peering-remoto

# 2. Crear archivo terraform.tfvars
cat > terraform.tfvars << EOF
tenancy_ocid    = "ocid1.tenancy.oc1..."
compartment_id  = "ocid1.compartment.oc1..."
region          = "us-ashburn-1"
region2         = "us-phoenix-1"
vcn_hub_cidr    = "10.0.0.0/16"
vcn_spoke_cidr  = "10.2.0.0/16"
instance_shape  = "VM.Standard.E4.Flex"
instance_ocpus  = 1
instance_memory_gb = 4
EOF

# 3. Inicializar Terraform
terraform init -backend-config=../00-bootstrap-remotestate/backend.hcl

# 4. Validar configuración
terraform validate

# 5. Ver plan (sin aplicar cambios)
terraform plan -out=tfplan

# 6. Aplicar cambios
terraform apply tfplan

# 7. Esperar 5-10 minutos...
# La salida mostrará:
# - VCN Hub ID (Región 1)
# - VCN Spoke ID (Región 2)
# - Load Balancer IP público
# - Bastion Service ID
```

### Opción 3: Terraform Cloud/Enterprise

```bash
# Si tienes workspace remoto configurado
terraform cloud login

# Aplicar directamente
terraform apply
```

---

## Verificación y Validación

### 1. Verificar Recursos en OCI Console

**Región 1 (us-ashburn-1)**:
```
Networking > Virtual Cloud Networks
  VCN "hub-vcn" (10.0.0.0/16) debe existir
  Subnets (pública, privada-web, privada-bastion)
  Internet Gateway, NAT Gateway, Service Gateway
  DRG anexado a la VCN
  Network Security Groups (4): LB, Web, Bastion, DRG

Networking > Load Balancers
  Load Balancer "hub-lb" debe estar ACTIVE
  Backend Set con 2 instancias
  Health Checks OK

Compute > Instances
  "web-1" y "web-2" en subnet privada (RUNNING)
  Subnets asignadas correctamente

Developer Services > Bastion Service
  Bastion "hub-bastion" ACTIVE
```

**Región 2 (us-phoenix-1)**:
```
Networking > Virtual Cloud Networks
  VCN "spoke-vcn" (10.2.0.0/16) debe existir
  Subnet privada "backend-subnet" (10.2.1.0/24)
  DRG anexado a la VCN
  Network Security Group "backend-sg"

Compute > Instances
  "backend-1" y "backend-2" en subnet privada (RUNNING)
```

### 2. Verificar Conectividad con CLI

```bash
# Listar VCNs en ambas regiones
oci network vcn list --region us-ashburn-1 --query "data[*].[\"display-name\",\"cidr-block\"]"
oci network vcn list --region us-phoenix-1 --query "data[*].[\"display-name\",\"cidr-block\"]"

# Verificar DRG conectado
oci network drg list --region us-ashburn-1
oci network drg list --region us-phoenix-1

# Listar Remote Peering Connections
oci network remote-peering-connection list --region us-ashburn-1
oci network remote-peering-connection list --region us-phoenix-1

# Verificar rutas dinámicas
oci network drg-route-distribution list --drg-id <DRG_ID> --region us-ashburn-1
```

### 3. Prueba de Conectividad desde Web Server a Backend

```bash
# 1. Acceder al web server vía Bastion (SSH)
# En OCI Console > Bastion > Manage Sessions > Create Session
# Seleccionar target "web-1" (10.0.1.10)

# 2. Una vez dentro del web server:
# Probar conectividad a backend
ssh -i ~/.ssh/id_rsa opc@10.0.1.10

# Dentro del web server:
curl http://10.2.1.10:80  # Debe responder desde backend

# Verificar tablas de rutas
ip route
netstat -rn

# Ver conectividad DRG
traceroute 10.2.1.10
```

### 4. Verificar Load Balancer

```bash
# Obtener IP pública del LB
LB_IP=$(oci network load-balancer list --region us-ashburn-1 --query "data[0].[\"ip-address-details\"][0][0].ip-address" --raw-output)

# Probar acceso
curl http://$LB_IP
# Debe devolver respuesta HTTP 200 desde web-1 o web-2

# Verificar health checks
oci network load-balancer backend-health list --load-balancer-id <LB_ID> --region us-ashburn-1
# Todos los backends deben estar "OK"
```

### 5. Verificar Métricas y Alarmas

```bash
# En OCI Console > Monitoring > Metrics
# Buscar namespace: oci_compute
# Métricas esperadas:
#   - CPU Utilization (debe estar bajo 50% en testing)
#   - Memory Utilization
#   - Network In/Out

# Alarmas automáticas creadas:
#   - Network Latency DRG
#   - Data Transfer Cross-Region
#   - Load Balancer Down
```

---

## Limpieza (Destrucción)

### Advertencia Importante

Este comando **eliminará TODOS los recursos** creados por esta arquitectura, incluyendo instancias, volúmenes de datos y configuraciones de red. **Esta acción es irreversible**.

```bash
# 1. Listar recursos a ser eliminados
terraform plan -destroy

# 2. Confirmar antes de destruir
echo "Deseas eliminar TODOS los recursos? (Escribe 'si' para continuar)"
read confirmacion

if [ "$confirmacion" = "si" ]; then
  # 3. Destruir infraestructura
  terraform destroy -auto-approve
  
  # 4. Esperar a que se elimine (2-5 minutos)
  echo "Esperando a que se eliminen los recursos..."
  sleep 60
  
  # 5. Verificar en OCI Console que estén eliminados
  echo "Recursos eliminados. Verifica en OCI Console."
fi
```

### Limpieza Selectiva

Si solo quieres eliminar ciertos componentes:

```bash
# Eliminar solo Load Balancer
terraform destroy -target=oci_network_load_balancer.hub_lb -auto-approve

# Eliminar solo compute instances
terraform destroy -target='oci_core_instance.web[*]' -auto-approve

# Eliminar solo DRG
terraform destroy -target='oci_core_drg.hub_drg' -auto-approve

# Para reproducir después:
terraform apply
```

---

## Troubleshooting (Problemas Comunes)

### Problema 1: "Error: 403 Unauthorized" durante terraform apply

**Síntomas**: 
```
Error: 403-NotAuthorizedOrNotFound, User is not authorized to perform this operation. (error code NotAuthorized)
```

**Causas posibles**:
- Credenciales OCI inválidas o expiradas
- Usuario IAM sin permisos suficientes
- Compartment especificado no accesible

**Solución**:
```bash
# 1. Verificar credenciales
oci iam user get

# 2. Verificar políticas IAM asignadas
oci iam policy list --compartment-id <TENANCY_OCID> --query "data[*].[\"display-name\",\"statements\"]"

# 3. Si es necesario, pedir a administrador que agregue políticas
# (Ver sección Prerequisitos)

# 4. Reintentar
terraform apply
```

---

### Problema 2: "Error: Region subscription not active" para región 2

**Síntomas**:
```
Error: Service error 404, not found (oci_core_network.NotFound). 
Service Gateway unavailable in region us-phoenix-1
```

**Causas posibles**:
- Región secundaria (us-phoenix-1) no está suscrita en el tenancy
- Servicio específico no está disponible en esa región

**Solución**:
```bash
# 1. Verificar regiones suscritas
oci iam tenancy get

# 2. Suscribirse a región en OCI Console
# Administration > Tenancy Details > Subscribed Regions > Manage Subscriptions

# 3. Seleccionar us-phoenix-1 y confirmar
# (Puede tardar 30 minutos en ser efectivo)

# 4. Reintentar después de 30 minutos
terraform apply
```

---

### Problema 3: "Error: Load Balancer health check failed" después de Apply

**Síntomas**:
```
Load Balancer backend is UNHEALTHY
Instances en backend set están "Down"
```

**Causas posibles**:
- NSG de web server no permite tráfico desde load balancer
- Instancias no tienen web server corriendo (Apache)
- Network Security Group misconfiguration

**Solución**:
```bash
# 1. Verificar NSG de web server
oci network security-group rules list \
  --security-group-id <WEB_SG_ID> \
  --region us-ashburn-1

# 2. Debe permitir tráfico 10.0.0.0/24 puerto 80
# Si no, actualizar:
oci network security-group rules add \
  --security-group-id <WEB_SG_ID> \
  --egress-rules '[{"destination":"10.0.0.0/24","protocol":"6","tcpOptions":{"destinationPortRange":{"min":80,"max":80}}}]' \
  --region us-ashburn-1

# 3. Verificar web server está corriendo
oci compute instance get --instance-id <INSTANCE_ID> --region us-ashburn-1

# 4. Si la instancia está RUNNING pero healthcheck falla,
#    acceder via Bastion y reiniciar Apache:
ssh -i ~/.ssh/id_rsa opc@10.0.1.10
sudo systemctl restart httpd

# 5. Esperar 30 segundos y verificar health
oci network load-balancer backend-health list \
  --load-balancer-id <LB_ID> \
  --region us-ashburn-1
```

---

### Problema 4: "Error: Remote Peering Connection attachment failed"

**Síntomas**:
```
RPC status: INACTIVE (debe ser PEERED)
Tráfico entre regiones no pasa
```

**Causas posibles**:
- DRG en Región 2 no aceptó la conexión RPC pendiente
- Timeout en conexión (>60 segundos)
- Conflicto de CIDR entre VCNs

**Solución**:
```bash
# 1. Verificar estado de RPC
oci network remote-peering-connection list --region us-ashburn-1
# Estado debe ser: PEERED

oci network remote-peering-connection list --region us-phoenix-1
# Estado debe ser: PEERED

# 2. Si están en PENDING o INACTIVE, aceptar manualmente:
# En OCI Console > Networking > Dynamic Routing Gateways
# > Seleccionar DRG Región 2 > Remote Peering > Aceptar conexión

# 3. Verificar CIDRs no conflictivos
# Hub: 10.0.0.0/16
# Spoke: 10.2.0.0/16
# > No deben superponerse

# 4. Verificar rutas dinámicas en DRG
oci network drg-route-distribution list --drg-id <HUB_DRG_ID> --region us-ashburn-1

# 5. Reintentar apply
terraform apply
```

---

## Siguiente Nivel: Arquitectura 10

La siguiente arquitectura en la serie avanza hacia **autoscaling automático**:

**Arquitectura 10 — Autoscaling (Instance Pool + Escalado Automático)**
- Despliega instancias dinámicamente basadas en carga de CPU
- Instance Pool con tamaño variable (min: 1, max: 3)
- Política de autoscaling: CPU > 70% > scale out (+1 instancia)
- Ideal para cargas variables: ecommerce, APIs públicas, eventos
- Documentación: `./arquitecturas-v2/10-autoscaling/README.md`

### Progresión Recomendada

1. **Arquitectura 09 (Actual)**: Peering cross-region multiregión estable
2. **Arquitectura 10**: Autoscaling dentro de una región
3. **Arquitectura 11**: WAF + DNS (seguridad perimetral)
4. **Arquitectura 12**: Kubernetes (orquestación)

---

## Referencias y Documentación

- [OCI Virtual Cloud Networks](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
- [OCI Dynamic Routing Gateway](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingDRGs.htm)
- [OCI Remote Peering Connection](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/remotepeering.htm)
- [OCI Load Balancer](https://docs.oracle.com/en-us/iaas/Content/NetworkLoadBalancer/home.htm)
- [OCI Bastion Service](https://docs.oracle.com/en-us/iaas/Content/Bastion/home.htm)
- [Terraform OCI Provider Documentation](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [OCI Pricing Calculator](https://www.oracle.com/cloud/price-list/)
- [Always Free Tier Limits](https://www.oracle.com/cloud/free/)

---

## Soporte y Contribuciones

- **Reportar Issues**: https://github.com/jesmonsa/oracle-cloud-latam/issues
- **Diskusiones**: https://github.com/jesmonsa/oracle-cloud-latam/discussions
- **Contribuir**: Pull requests bienvenidos en https://github.com/jesmonsa/oracle-cloud-latam

---

**Última actualización**: Abril 2026 | **Terraform OCI Provider**: 6.0.0+ | **Versión Arquitectura**: 2.0
