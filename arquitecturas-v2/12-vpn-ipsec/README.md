# 12 - VPN Site-to-Site (IPSec): Conectividad Segura On-Premises a OCI

[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-12-vpn-ipsec.zip)

## Descripción

Arquitectura empresarial que establece un túnel **VPN Site-to-Site seguro con IPSec** entre una red on-premises simulada (192.168.0.0/16) y un VCN en OCI (10.0.0.0/16). Implementa dos túneles redundantes a través de un Dynamic Routing Gateway (DRG) para garantizar alta disponibilidad de la conectividad de red.

La solución incluye un CPE (Customer Premises Equipment) virtual con IP simulada (203.0.113.1 — RFC 5737 TEST-NET-3) y un webserver en subnet privada accesible a través de Load Balancer público. Esta arquitectura es ideal para empresas que necesitan extender su infraestructura on-premises a OCI manteniendo seguridad y control de acceso.

---

## Diagrama de Arquitectura

```
┌──────────────────────────────────────────────────────────────────┐
│                      OCI Region                                  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │               VCN Cloud (10.0.0.0/16)                      │  │
│  │  ┌──────────────────────────────────────────────────────┐  │  │
│  │  │         Subnet Pública (10.0.0.0/24)                │  │  │
│  │  │                                                      │  │  │
│  │  │    ┌──────────────────────┐                          │  │  │
│  │  │    │  Load Balancer       │<-- Internet (HTTP/S)    │  │  │
│  │  │    │  IP Pública          │                          │  │  │
│  │  │    └──────────┬───────────┘                          │  │  │
│  │  └───────────────┼──────────────────────────────────────┘  │  │
│  │                  │                                          │  │
│  │  ┌───────────────┼──────────────────────────────────────┐  │  │
│  │  │               ▼                                      │  │  │
│  │  │  Subnet Privada (10.0.1.0/24)                       │  │  │
│  │  │                                                      │  │  │
│  │  │    ┌──────────────────────┐                          │  │  │
│  │  │    │  Webserver Apache    │<-- Tráfico LB           │  │  │
│  │  │    │  Oracle Linux 8      │                          │  │  │
│  │  │    │  E4.Flex (privada)   │                          │  │  │
│  │  │    └──────────────────────┘                          │  │  │
│  │  └──────────────┬───────────────────────────────────────┘  │  │
│  │                 │                                           │  │
│  │    ┌────────────▼────────────┐                             │  │
│  │    │  DRG (Dynamic Routing   │                             │  │
│  │    │  Gateway)               │                             │  │
│  │    │  <-- VPN Route: 192.168.│                             │  │
│  │    │      0.0/16             │                             │  │
│  │    └────────────┬────────────┘                             │  │
│  └─────────────────┼────────────────────────────────────────┘  │
│                    │                                            │
│                    │ IPSec Tunnels (Redundante)                │
│     ┌──────────────┴──────────┐                                │
│     │ Tunnel 1 (Primario)      │                                │
│     │ Tunnel 2 (Secundario)    │                                │
│     └──────────────┬──────────┘                                │
└─────────────────────┼──────────────────────────────────────────┘
                      │
        ┌─────────────┴──────────────┐
        ▼                            ▼
    ┌────────────┐            ┌────────────┐
    │ Túnel 1    │            │ Túnel 2    │
    │ On-Prem    │            │ On-Prem    │
    │ (Activo)   │            │ (Respaldo) │
    └────────────┘            └────────────┘
        │                          │
        └──────────┬───────────────┘
                   ▼
    ┌──────────────────────────────────┐
    │  CPE (Customer Premises Equip.)   │
    │  IP Simulada: 203.0.113.1         │
    │  (RFC 5737 TEST-NET-3)            │
    │  IKEv2 + IPSec ESP                │
    └──────────────────────────────────┘
                   │
                   ▼
    ┌──────────────────────────────────┐
    │ On-Premises Network               │
    │ CIDR: 192.168.0.0/16              │
    │ (Simulado para laboratorio)       │
    └──────────────────────────────────┘
```

---

## Recursos Desplegados

| Recurso | Descripción | Tipo OCI |
|---------|-------------|----------|
| **VCN** | Red virtual cloud con CIDR configurable | `oci_core_vcn` |
| **Subnets** | 2 subnets (1 pública para LB, 1 privada para webserver) | `oci_core_subnet` |
| **Internet Gateway** | Acceso a internet para subnet pública | `oci_core_internet_gateway` |
| **NAT Gateway** | Salida a internet desde subnet privada | `oci_core_nat_gateway` |
| **Service Gateway** | Acceso a servicios Oracle sin salir de VCN | `oci_core_service_gateway` |
| **DRG (Dynamic Routing Gateway)** | Gateway de enrutamiento dinámico para VPN | `oci_core_drg` |
| **DRG Attachment** | Adjunta VCN al DRG | `oci_core_drg_attachment` |
| **CPE (Customer Premises Equipment)** | Representación del equipo on-premises | `oci_core_cpe` |
| **IPSec Connection** | Conexión VPN con 2 túneles redundantes | `oci_core_ipsec` |
| **IPSec Tunnels (x2)** | Túneles individuales con shared secret | `oci_core_ipsec_connection_tunnel_management` |
| **Route Table (Privada)** | Tabla de enrutamiento con ruta DRG→On-Prem | `oci_core_route_table` |
| **Network Security Groups** | Reglas de firewall granulares para web y SSH | `oci_core_network_security_group` |
| **Load Balancer (10 Mbps)** | Balanceador flexible en subnet pública | `oci_load_balancer_load_balancer` |
| **Compute Instance** | VM Apache en subnet privada | `oci_core_instance` |
| **Bastion Service** | Sesión SSH segura a servidor privado | `oci_bastion_bastion` |

---

## Shapes Compatibles

| Shape | OCPU | RAM | Costo Estimado/mes | Always Free |
|-------|------|-----|-------------------|------------|
| **VM.Standard.E4.Flex** | 1 | 8 GB | Gratis | Si |
| **VM.Standard.E5.Flex** | 1 | 8 GB | $0.07 | Si (primeros 2 OCPU) |
| **VM.Standard.A1.Flex** | 1 (ARM) | 8 GB | Gratis | Si |
| **VM.Standard.X9.Flex** | 1 | 8 GB | $0.85+ | No (computación premium) |

**Recomendación:** E4.Flex para desarrollo/lab, E5.Flex para producción con mejor relación precio-rendimiento.

---

## Variables Principales

| Variable | Descripción | Default | Rango/Validación |
|----------|-------------|---------|------------------|
| `proyecto` | Prefijo para nombres de recursos | `vpn-ipsec` | 3-12 caracteres, minúsculas |
| `ambiente` | Ambiente de despliegue | `desarrollo` | desarrollo, staging, produccion |
| `region` | Región OCI | `us-ashburn-1` | us-ashburn-1, us-phoenix-1, sa-santiago-1, etc. |
| `vcn_cidr` | CIDR del VCN en OCI | `10.0.0.0/16` | Cualquier /16 privado |
| `subnet_publica_cidr` | CIDR subnet pública (LB) | `10.0.0.0/24` | Dentro de vcn_cidr |
| `subnet_privada_cidr` | CIDR subnet privada (servidor) | `10.0.1.0/24` | Dentro de vcn_cidr |
| `cpe_ip_address` | IP pública simulada del CPE on-prem | `203.0.113.1` | IP de test válida (RFC 5737) |
| `on_prem_cidr` | CIDR de la red on-premises | `192.168.0.0/16` | Ruta estática en IPSec |
| `shared_secret` | PSK para autenticación IPSec | **(SIN DEFAULT)** | Min 20 caracteres, caracteres especiales |
| `shape_webserver` | Shape de la instancia | `VM.Standard.E4.Flex` | E4.Flex, E5.Flex, A1.Flex, X9.Flex |
| `ocpus_webserver` | OCPUs para webserver Flex | `1` | 1-4 según shape |
| `memoria_webserver_gb` | RAM en GB | `8` | 8-64 según shape |
| `habilitar_nsg` | Usar Network Security Groups | `true` | true/false |
| `ssh_cidr_permitido` | CIDR para acceso SSH (bastion) | `0.0.0.0/0` | CIDR específica para mayor seguridad |
| `ssh_public_key` | Llave pública SSH para bastion | **(REQUERIDO)** | Formato OpenSSH |
| `propietario` | Email del propietario (tag) | `admin` | E-mail válido |

**Nota Crítica:** `shared_secret` es **sensible** y **NO tiene default**. Debe ser un valor fuerte con mínimo 20 caracteres.

---

## Estimación de Costos

### Desglose por Recurso (Region us-ashburn-1, 730 horas/mes)

| Componente | Cantidad | Precio Unit./mes | Subtotal/mes | Notas |
|---|---|---|---|---|
| **Load Balancer (10 Mbps)** | 1 | $0 | $0 | Always Free Tier |
| **VM.Standard.E4.Flex (1 OCPU, 8GB)** | 1 | $0 | $0 | Always Free Tier |
| **DRG** | 1 | $0 | $0 | Gratis, pagas solo tráfico IPSec |
| **IPSec Connection (2 tunnels)** | 1 | $0 | $0 | Incluido en DRG |
| **Data Transfer (On-Prem <-> OCI)** | Por GB | $0.02/GB | Varía | Si 1 GB/día = $60/mes |
| **NAT Gateway (salida internet)** | 1 | $0.045/GB | Varía | Negligible para lab |

**Costo Total Estimado:**
- **Lab/Desarrollo sin tráfico:** $0 USD/mes (100% Always Free)
- **Producción 1GB/día tráfico IPSec:** ~$60 USD/mes + almacenamiento/backup

### Cómo Optimizar Costos

1. **Always Free Tier:** Mantener webserver con 1 OCPU máximo
2. **Monitoreo de tráfico:** DRG permite ver GB transferidos en Console
3. **Tiered Pricing:** OCI ofrece descuentos por volumen de tráfico IPSec
4. **Data Transfer Optimization:** Comprimir datos antes de transmitir por VPN

---

## Arquitectura de Seguridad

### Autenticación y Cifrado

- **Protocolo:** IKEv2 (Internet Key Exchange version 2) — estándar empresarial
- **Cifrado Fase 1 (IKE):** AES-128-CBC (configurable a AES-256)
- **Cifrado Fase 2 (ESP):** AES-128-GCM con Perfect Forward Secrecy (PFS)
- **Shared Secret:** Pre-shared key, almacenado en estado Terraform (con `sensitive = true`)
- **Integridad:** HMAC-SHA256 en ambas fases

### Controles de Acceso en Capas

```
Internet
   │
   ├─► Internet Gateway (subnet pública)
   │
   ├─► Load Balancer (NSG/SL abre puerto 80/443)
   │
   ├─► NSG Web: Solo tráfico HTTP/HTTPS desde internet
   │
   ├─► Subnet Privada: NAT Gateway + Bastion
   │      │
   │      └─► Webserver (acceso: LB + Bastion SSH)
   │
   └─► On-Premises via DRG IPSec Tunnel
       └─► NSG SSH: Acceso desde VCN (10.0.0.0/16)
```

### Recomendaciones de Producción

1. **IP Whitelisting:** Reducir `ssh_cidr_permitido` a rangos específicos
2. **Bastion Host:** Use Bastion Service (incluido) en lugar de IP pública
3. **Shared Secret:** Usar secreto de 32+ caracteres con mayúsculas, minúsculas, números, símbolos
4. **Logs y Auditoría:**
   - Habilitar VCN Flow Logs (captura tráfico)
   - Auditoría OCI de cambios IPSec
   - CloudTrail/Audit Logs para eventos de configuración

---

## Prerequisitos

### Software Requerido

- **Terraform:** >= 1.5.0
  ```bash
  terraform --version
  ```
- **OCI CLI:** >= 3.40.0
  ```bash
  oci --version
  ```
- **SSH Key Pair:** Llave pública en formato OpenSSH
  ```bash
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_oci -C "oci@empresa"
  cat ~/.ssh/id_rsa_oci.pub  # Copiar para variable ssh_public_key
  ```

### Credenciales OCI

1. **API Keys:** Generar en OCI Console → User → API Keys
2. **Variables de entorno:**
   ```bash
   export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..."
   export TF_VAR_compartment_ocid="ocid1.compartment.oc1..."
   export TF_VAR_current_user_ocid="ocid1.user.oc1..."
   export TF_VAR_fingerprint="aa:bb:cc:dd:..."
   export TF_VAR_private_key_path="~/.oci/api_key.pem"
   export TF_VAR_ssh_public_key="ssh-rsa AAAA..."
   export TF_VAR_shared_secret="<tu_vpn_shared_secret>"
   ```

### Configuración Inicial

```bash
# 1. Clonar repositorio
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas-v2/12-vpn-ipsec

# 2. Crear terraform.tfvars
cp terraform.tfvars.example terraform.tfvars

# 3. Editar con tus valores
nano terraform.tfvars
# Mínimo: shared_secret, ssh_public_key, credenciales OCI

# 4. Validar credenciales
oci iam user get --user-id $TF_VAR_current_user_ocid
```

---

## Despliegue Rápido

### Opción A: Terraform Directo

```bash
# 1. Inicializar Terraform
terraform init

# 2. Planificar cambios (revisar antes de aplicar)
terraform plan -out=plan.tfplan

# 3. Aplicar configuración
terraform apply plan.tfplan

# Tiempo estimado: 5-10 minutos
# - VCN + Subnets: ~1 min
# - DRG + IPSec: ~2-3 min
# - Compute + LB: ~3-5 min
```

### Opción B: Oracle Resource Manager (UI)

1. **Descargar archivo ZIP** de este repositorio
2. **Ir a OCI Console** → Resource Manager → Stacks → Create Stack
3. **Subir archivo ZIP** y configurar variables en UI
4. **Plan → Apply**

### Opción C: Terraform Cloud/Enterprise

```bash
# Si usas TFC:
terraform login
terraform init
terraform apply
```

---

## Verificación Post-Despliegue

### 1. Validar Recursos Creados

```bash
# Obtener estado de infraestructura
terraform output

# Output esperado:
# lb_ip_publica = "1.2.3.4"
# webserver_ip_privada = "10.0.1.X"
# drg_id = "ocid1.drg.oc1...."
# ipsec_connection_id = "ocid1.ipsecconnection.oc1...."
```

### 2. Verificar IPSec Tunnels

```bash
# Obtener OCID de conexión IPSec (desde output o Console)
IPSEC_ID="ocid1.ipsecconnection.oc1...."

# Ver estado de túneles (CLI)
oci core ipsec-connection get --ipsec-id $IPSEC_ID \
  --query "data.[id,lifecycle_state,time_created]" \
  --output table

# En OCI Console: Networking → Virtual Cloud Networks → <VCN> → IPSec Connections
```

### 3. Acceder al Webserver

```bash
# Obtener IP del Load Balancer
LB_IP=$(terraform output -raw lb_ip_publica)

# Conectar vía HTTP
curl -v http://$LB_IP
# Esperado: HTTP 200, respuesta Apache con información del servidor
```

### 4. Monitorear Tráfico

```bash
# En OCI Console → Monitoring:
# 1. Ve a Metrics → DRG
# 2. Ver "Bytes In/Out" — confirmará tráfico IPSec cuando CPE esté activo
# 3. VCN Flow Logs: Networking → VCNs → <VCN> → Flow Logs
```

### 5. Health Check del Load Balancer

```bash
# Ver backends del LB
oci lb backend list --load-balancer-id $(terraform output -raw lb_ocid) \
  --backend-set-name $(terraform output -raw lb_backend_set) \
  --query "data[].{ip:ip_address,status:status}" \
  --output table

# Esperado: Estado "OK" con IP privada del webserver
```

---

## Limpieza

### Destruir Todos los Recursos

```bash
# 1. Revisar qué se va a destruir
terraform plan -destroy

# 2. Confirmar destrucción
terraform destroy -auto-approve

# Tiempo estimado: 3-5 minutos
```

### Limpieza Manual en Console

Si Terraform falla, eliminar manualmente en OCI Console:
1. **IPSec Connection** → Lifecycle: Delete
2. **CPE** → Delete
3. **DRG Attachment** → Detach
4. **DRG** → Delete
5. **Load Balancer** → Delete
6. **VCN** → Delete Subnets → Delete VCN

---

## Troubleshooting

### Problema 1: IPSec Tunnels Quedan en Estado DOWN

**Síntomas:**
- Túneles muestran "provisioned" pero no "UP"
- Tráfico no fluye entre on-prem y OCI

**Causas:**
- CPE simulado sin equipo real (esperado en lab)
- Shared secret incorrecto
- Firewall bloqueando puertos IPSec (UDP 500, 4500)

**Solución:**
```bash
# 1. Validar shared_secret en ambos lados
terraform output -raw shared_secret  # Debe coincidir en CPE real

# 2. Verificar firewall local
# En CPE real: sudo iptables -L | grep 500

# 3. Para esta arquitectura de LAB: Túneles quedarán DOWN sin CPE físico
#    Pero la configuración es válida y lista para producción
```

### Problema 2: Load Balancer No Responde (HTTP 503)

**Síntomas:**
- `curl http://<LB-IP>` retorna 503 Service Unavailable
- Backend status "Critical" en Console

**Solución:**
```bash
# 1. Verificar que NAT Gateway existe
terraform output nat_gateway_id

# 2. Validar NSG de webserver
oci network nsg list --compartment-id $TF_VAR_compartment_ocid \
  --query "data[?contains(display_name, 'web')].id" \
  --output table

# 3. Revisar reglas NSG (ingress desde LB port 80)
oci network nsg-security-rules list --network-security-group-id <NSG-ID> \
  --query "data[].{src:source,dport:tcp_options.destination_port_range}" \
  --output table
```

### Problema 3: Terraform Apply Falla con Error de Autenticación

**Síntomas:**
```
Error: 401 - Unauthorized
```

**Solución:**
```bash
# 1. Validar credenciales OCI
oci iam user get --user-id $TF_VAR_current_user_ocid

# 2. Verificar API key
oci iam api-key list --user-id $TF_VAR_current_user_ocid \
  --query "data[].{fingerprint:fingerprint,status:lifecycle_state}"

# 3. Reintentar Terraform
terraform init -upgrade
terraform plan
```

---

## Siguiente Nivel

[**13 - OKE (Kubernetes):** Desplegar aplicaciones containerizadas en un cluster Kubernetes gestionado por Oracle](../13-oke-kubernetes/)

En esta arquitectura avanzada:
- Despliega un cluster OKE con 3 subnets (API, LB, Nodes)
- Usa Flannel CNI para networking entre pods
- Implementa auto-scaling de nodos
- Integra con Load Balancer de OCI para servicios

---

## Referencias y Documentación

### Documentación Oficial OCI

- [DRG (Dynamic Routing Gateway)](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingDRGs.htm)
- [IPSec VPN Connections](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingIPSecConnections.htm)
- [CPE (Customer Premises Equipment)](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingCPEs.htm)
- [Load Balancer](https://docs.oracle.com/en-us/iaas/Content/Balance/Concepts/balanceoverview.htm)

### Estándares IPSec

- [RFC 7539: ChaCha20 and Poly1305 AEAD](https://tools.ietf.org/html/rfc7539)
- [RFC 5737: IPv4 Address Blocks for Documentation](https://tools.ietf.org/html/rfc5737)
- [IKEv2 Specification (RFC 7296)](https://tools.ietf.org/html/rfc7296)

### Herramientas Útiles

- [OCI Terraform Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [iperf3](https://iperf.fr/) — Pruebas de ancho de banda en túnel
- [StrongSwan](https://www.strongswan.org/) — Stack IPSec para CPE real
- [WireGuard](https://www.wireguard.com/) — Alternativa moderna a IPSec

---

## Licencia

Este código es proporcionado bajo licencia **GPL-3.0**. Úsalo libremente en tu infraestructura.

**Creado por:** Comunidad LATAM Oracle Cloud
**Mantenedor:** [@jesmonsa](https://github.com/jesmonsa)
**Última actualización:** 2026-04-12
