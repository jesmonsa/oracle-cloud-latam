# 04 - Bastion Service + Webservers Privados

## Descripción General

Arquitectura de seguridad avanzada que implementa el patrón **zero-trust** al alojar los servidores web en **subnets privadas** sin acceso directo a Internet. El acceso HTTP se realiza exclusivamente a través de un Load Balancer público, mientras que el acceso SSH se canaliza a través del **Bastion Service** gestionado por OCI, eliminando completamente la exposición del puerto 22 a Internet.

Esta arquitectura representa un salto crítico en madurez de seguridad respecto a la arquitectura 03, reduciendo significativamente la superficie de ataque y estableciendo las bases para conformidad con marcos de seguridad empresariales como CIS, PCI-DSS y HIPAA.

### Características Principales

- **Webservers privados**: Sin IPs públicas, aislados de Internet directo
- **Bastion Service OCI**: Servicio gestionado (sin necesidad de EC2 dedicado)
- **NAT Gateway**: Permite tráfico saliente de los webservers (yum, actualizaciones)
- **Service Gateway**: Acceso directo a OCI Object Storage sin salir de la VCN
- **Load Balancer público**: Único punto de entrada HTTP desde Internet
- **Network Security Groups**: Políticas de firewall granulares por subnet y servicio

---

## Diagrama de Arquitectura

```
                            Internet
                               │
                    ┌──────────┴──────────┐
                    ▼                     ▼
        ┌─────────────────────┐  ┌──────────────────────┐
        │  Load Balancer      │  │  Bastion Service     │
        │  (Público)          │  │  (Servicio OCI)      │
        │  HTTP: 80/443       │  │  SSH Tunnels        │
        │  10.0.10.0/24       │  │  (Sin puerto 22 exp.)│
        └──────────┬──────────┘  └──────────┬───────────┘
                   │                        │
        ───────────┼───── VCN 10.0.0.0/16 ──┼─────────────
                   │     (Privada)          │
        ┌──────────┼─────────────────────────┼──────────┐
        │          │                         │          │
        ▼          ▼                         ▼          ▼
    ┌────────┐ ┌────────┐              ┌────────────────┐
    │ WS1    │ │ WS2    │              │ Bastion Target │
    │ AD1    │ │ AD2    │              │ (NSG Bastion)  │
    │ Private│ │ Private│              │ No SSH direct  │
    │10.0.1.x│ │10.0.2.x│              │                │
    └────┬───┘ └────┬───┘              └────────────────┘
         │          │
    NAT Gateway ← / → Service Gateway
    (outbound)       (OCI services)
```

---

## Evolución desde Arquitectura 03

| Aspecto | 03 - Load Balancer HA | 04 - Bastion Privado |
|--------|----------------------|----------------------|
| **Ubicación Webservers** | Subnets públicas con IP pública | Subnets privadas sin IP pública |
| **Acceso SSH** | Directo a puerto 22 (expuesto a Internet) | Via Bastion Service (túnel SSH gestionado) |
| **NAT Gateway** | No requerido | Sí (para outbound internet de webservers) |
| **Service Gateway** | Opcional | Sí (acceso directo a OCI services) |
| **Superficie de ataque SSH** | Alta (port 22 visible) | Nula (sin puerto 22 expuesto) |
| **Conformidad NIST/CIS** | Parcial | Alta (bastion pattern compliance) |
| **Complejidad operacional** | Baja | Media (gestión de sesiones Bastion) |

---

## Recursos Creados

| Recurso | Descripción | Tipo OCI |
|---------|-------------|----------|
| **VCN** | Red virtual privada 10.0.0.0/16 | Networking |
| **Subnets (3)** | 1 pública LB (10.0.10.0/24), 2 privadas WS (10.0.1.0/24 AD1, 10.0.2.0/24 AD2) | Networking |
| **Internet Gateway** | Acceso público para Load Balancer | Networking |
| **NAT Gateway** | Acceso saliente a Internet para webservers privados | Networking |
| **Service Gateway** | Acceso directo a Object Storage sin salir de VCN | Networking |
| **Load Balancer Flexible** | Balanceador público HTTP/HTTPS 10 Mbps | Networking |
| **VM.Standard.E4.Flex** | 2 servidores web, 1 OCPU, 8GB RAM cada uno | Compute |
| **Bastion Service** | Servicio gestionado para SSH tunneling | Security |
| **Network Security Groups (3)** | NSG para LB, NSG para webservers, NSG para Bastion | Security |

---

## Tablas de Configuración

### Shapes Compatibles (Compute)

| Shape | vCPUs | Memoria | Casos de Uso | Costo (Always Free) |
|-------|-------|---------|--------------|-------------------|
| **E4.Flex** | 1-4 | 8-64 GB | Desarrollo, testing, aplicaciones ligeras | ✓ Gratuito (1 OCPU/8GB) |
| **E5.Flex** | 1-4 | 8-64 GB | Producción general, mejor ratio precio-rendimiento | ✗ Pagado |
| **A1.Flex ARM** | 1-4 | 6-24 GB | Workloads ARM optimizados | ✗ Pagado |
| **X9.Flex** | 2-64 | 32-1024 GB | Alta memoria, bases de datos en memoria | ✗ Muy pagado |

**Recomendación**: E4.Flex es el mejor balance para Always Free. E5.Flex si requiere mejor rendimiento sostenido.

### Variables Principales

| Variable | Descripción | Valor por Defecto | Tipo |
|----------|-------------|-------------------|------|
| `compartment_ocid` | OCID del compartment donde desplegar | (requerido) | String |
| `region` | Región OCI (ej: eu-madrid-1, sa-saopaulo-1) | (requerido) | String |
| `vcn_cidr` | CIDR de la VCN | `10.0.0.0/16` | String |
| `bastion_cidr_permitidos` | CIDRs permitidos para acceder al Bastion | `["0.0.0.0/0"]` | List |
| `bastion_ttl_segundos` | TTL de sesiones SSH Bastion (segundos) | `3600` | Number |
| `lb_bandwidth` | Ancho de banda del Load Balancer (Mbps) | `10` | Number |
| `shape_ws` | Shape para webservers | `VM.Standard.E4.Flex` | String |
| `webserver_ocpus` | OCPUs para webservers | `1` | Number |
| `webserver_memory_gb` | Memoria en GB para webservers | `8` | Number |

---

## Estimación de Costos

### Modelo Always Free Tier

```
Recurso                          | Cantidad | Costo Unitario | Costo Total
----------------------------------------------------------
VCN (VLANs)                      | 1        | Gratuito       | $0
Subnets                          | 3        | Gratuito       | $0
Internet Gateway                 | 1        | Gratuito       | $0
NAT Gateway                      | 1        | Gratuito*      | $0
Service Gateway                  | 1        | Gratuito       | $0
Load Balancer Flexible 10 Mbps  | 1        | Gratuito*      | $0
VM.Standard.E4.Flex 1 OCPU/8GB  | 2        | Gratuito*      | $0
Bastion Service                  | 1        | Gratuito       | $0
Network Security Groups          | 3        | Gratuito       | $0
----------------------------------------------------------
TOTAL ESTIMADO (Always Free):    | -        | -              | $0 USD/mes
```

**Notas de Costo:**
- `*` Componentes dentro del Always Free tier gratuito
- El NAT Gateway y Load Balancer tienen límites de datos (ver documentación OCI)
- Si se exceden los límites, aplican cargos por uso
- Sin datos salientes desde webservers: $0
- Con datos salientes: ~$0.05 por GB saliente (varía por región)

**Comparativa con Bastion Host EC2:**
- Bastion Service (esta arquitectura): Gratuito, sin host EC2
- Bastion Host EC2: ~$15-30 USD/mes (E4 pequeño) + tráfico

---

## Requisitos Previos

### Acceso OCI

- [ ] Cuenta OCI activa con Always Free tier (si aplica)
- [ ] Usuario con permisos: `TENANCY_INSPECTOR`, `MANAGE_VCN`, `MANAGE_LOAD_BALANCER`, `MANAGE_BASTION`
- [ ] OCID del compartment destino documentado

### Herramientas Locales

- [ ] **Terraform** 1.0+ instalado (`terraform --version`)
- [ ] **OCI CLI** 2.0+ instalado (`oci --version`)
- [ ] **SSH Keys** configuradas en ~/.ssh/:
  - `oci_webserver` (privada)
  - `oci_webserver.pub` (pública)
  
  Generar si no existe:
  ```bash
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/oci_webserver -N ""
  ```

### Credenciales OCI

```bash
# Configurar OCI CLI
oci setup config
# Resultado esperado: ~/.oci/config con [DEFAULT] profile

# Validar acceso
oci iam compartment list
```

### Permisos IAM Mínimos

```
Allow group architects to manage virtual-networks in compartment
Allow group architects to manage instances in compartment
Allow group architects to manage load-balancers in compartment
Allow group architects to manage bastion-sessions in compartment
Allow group architects to manage security-groups in compartment
```

---

## Despliegue Rápido

### 1. Clonar Repositorio

```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas-v2/04-bastion-privado
```

### 2. Configurar Variables

```bash
# Copiar archivo de variables
cp terraform.tfvars.example terraform.tfvars

# Editar con tus valores
cat > terraform.tfvars << EOF
compartment_ocid     = "ocid1.compartment.oc1..aaaaaaaa..."
region              = "eu-madrid-1"
vcn_cidr            = "10.0.0.0/16"
bastion_cidr_permitidos = ["203.0.113.0/24"]  # Tu IP
shape_ws            = "VM.Standard.E4.Flex"
webserver_ocpus     = 1
webserver_memory_gb = 8
EOF
```

### 3. Inicializar Terraform

```bash
terraform init
# Validar sintaxis
terraform validate
# Generar plan
terraform plan -out=tfplan
```

### 4. Revisar Plan

```bash
# Ver recursos a crear
terraform show tfplan | grep -E "^(  +resource|    + id =)"

# Verificar NSG rules
terraform plan | grep -A5 "security_group"
```

### 5. Aplicar Configuración

```bash
# Desplegar (toma 5-10 minutos)
terraform apply tfplan

# Capturar outputs
terraform output -json > outputs.json
```

### 6. Obtener Credenciales de Salida

```bash
# Load Balancer IP
terraform output load_balancer_ip

# Bastion OCID (necesario para SSH)
terraform output bastion_id

# Instancia OCID
terraform output instance_ids
```

---

## Verificación post-despliegue

### Verificar recursos creados

```bash
# Listar instancias
oci compute instance list --compartment-id $COMPARTMENT_OCID

# Verificar Load Balancer
oci lb load-balancer get --load-balancer-id $(terraform output -raw lb_id)

# Verificar Bastion
oci bastion bastion get --bastion-id $(terraform output -raw bastion_id)
```

### Probar acceso HTTP

```bash
# Obtener IP del LB
LB_IP=$(terraform output -raw load_balancer_ip)

# Esperar a que el LB esté listo (2-3 minutos)
sleep 120

# Probar conectividad
curl -i http://$LB_IP/
# Respuesta esperada: HTTP/1.1 200 OK
```

### Probar acceso SSH via Bastion

```bash
# Variables
BASTION_ID=$(terraform output -raw bastion_id)
WS1_ID=$(terraform output -raw -json instance_ids | jq -r '.[0]')

# Crear sesión SSH (TTL 1 hora)
SESSION=$(oci bastion session create-managed-ssh \
  --bastion-id $BASTION_ID \
  --target-resource-id $WS1_ID \
  --target-os-username opc \
  --ssh-public-key-file ~/.ssh/oci_webserver.pub \
  --session-ttl-in-seconds 3600 \
  --wait-for-state ACTIVE \
  --query 'data.id' \
  --raw-output)

echo "Sesión creada: $SESSION"

# Obtener comando SSH
oci bastion session get --session-id $SESSION \
  --query 'data."ssh-metadata"."command"' \
  --raw-output > /tmp/ssh_command.sh

# Ejecutar comando SSH
chmod +x /tmp/ssh_command.sh
bash /tmp/ssh_command.sh << 'EOF'
whoami
hostname -I
exit
EOF
```

### Verificar conectividad de red

```bash
# Desde dentro de webserver (via Bastion)
bash /tmp/ssh_command.sh << 'EOF'
# Verificar acceso a NAT (internet)
curl -I http://www.google.com
echo "---"
# Verificar acceso a OCI Object Storage (Service Gateway)
curl -I https://objectstorage.eu-madrid-1.oraclecloud.com
exit
EOF
```

---

## Limpieza Completa

### Destruir todos los recursos

```bash
# Listar recursos a eliminar
terraform plan -destroy

# Destruir (toma 5 minutos)
terraform destroy

# Confirmar eliminación
# Responder 'yes' cuando se pida confirmación
```

### Validar limpieza

```bash
# Verificar que no hay recursos en el compartment
oci compute instance list --compartment-id $COMPARTMENT_OCID | jq '.data | length'
# Debe retornar: 0

# Verificar VCN eliminada
oci network vcn list --compartment-id $COMPARTMENT_OCID | jq '.data | length'
# Debe retornar: 0
```

---

## Troubleshooting

### Problema: "Error creating Load Balancer - Invalid shape"

**Síntoma**: Terraform falla con `shape_not_available`

**Causa**: El shape del LB no está disponible en la región

**Solución**:
```bash
# Listar shapes disponibles en tu región
oci compute shape list --compartment-id $COMPARTMENT_OCID \
  --query "data[?contains(\"Instance\", availability_domain)].[shape]" \
  --raw-output

# Actualizar terraform.tfvars con shape disponible
# Normalmente: VM.Standard.E4.Flex, E5.Flex
```

### Problema: "Bastion session expires immediately"

**Síntoma**: Sesión SSH Bastion expira después de conectar

**Causa**: TTL de sesión demasiado corto o permisos IAM incorrectos

**Solución**:
```bash
# Aumentar TTL a 7200 segundos (2 horas)
# En terraform.tfvars:
bastion_ttl_segundos = 7200

# Revalidar permisos:
oci iam policy list --compartment-id $COMPARTMENT_OCID | grep -i bastion

# Requiere: "Allow group ... to manage bastion-sessions"
```

### Problema: "No route to Host" en SSH via Bastion

**Síntoma**: `ssh: connect to host 127.0.0.1 port XXXXX: Connection refused`

**Causa**: NSG no permite tráfico SSH desde Bastion a webserver

**Solución**:
```bash
# Verificar NSG de webserver
oci network security-group rules list \
  --security-group-id $(terraform output -raw ws_nsg_id)

# Debe existir regla:
# Direction: INGRESS, Protocol: TCP, Port: 22, Source: Bastion NSG

# Si no existe, verificar archivo main.tf:
grep -A5 "ingress_rules.*bastion" main.tf

# Reaplica Terraform:
terraform apply
```

### Problema: "Load Balancer shows healthy but 502 Bad Gateway"

**Síntoma**: `curl http://<LB_IP>/` retorna 502

**Causa**: Instancias no están listas o cloud-init falló

**Solución**:
```bash
# Esperar más tiempo (cloud-init puede tardar 3-5 minutos)
sleep 300 && curl -i http://$LB_IP/

# Verificar logs de instancia
WS1_ID=$(terraform output -raw -json instance_ids | jq -r '.[0]')
oci compute instance-console-connection create --instance-id $WS1_ID --wait-for-state SUCCEEDED

# Ver console logs (últimas 50 líneas)
oci compute console-history get --instance-id $WS1_ID | tail -50

# Común: puerto 80 no abierto. Verificar:
# 1. Instancia corre Apache/Nginx
# 2. NSG permite puerto 80 desde LB
```

---

## Siguiente Nivel: Arquitectura 05

Esta arquitectura es la base para **Almacenamiento Compartido (FSS)**, donde se agrega:
- **File Storage Service (NFS)** para sincronizar contenido entre webservers
- **Mount Target** en subnet privada
- Automatización de montaje via cloud-init
- Sincronización de aplicaciones web multi-instancia

👉 **Siguiente paso**: [`../05-almacenamiento-compartido/README.md`](../05-almacenamiento-compartido/README.md)

---

## Deploy Button

[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-04-bastion-privado.zip)

---

## Soporte y Documentación

- [OCI Bastion Service - Documentación Oficial](https://docs.oracle.com/en-us/iaas/Content/Bastion/home.htm)
- [Network Security Groups - OCI Docs](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/networksecuritygroups.htm)
- [NAT Gateway - Routing Guide](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/NATgateway.htm)
- [Terraform OCI Provider - Reference](https://registry.terraform.io/providers/oracle/oci/latest/docs)
