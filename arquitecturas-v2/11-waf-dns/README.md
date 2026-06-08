# Arquitectura 11: WAF + DNS Zone

Arquitectura de referencia para desplegar un **Web Application Firewall (WAF)** integrado con **DNS público** en Oracle Cloud Infrastructure, proporcionando protección contra amenazas aplicativas y resolución de nombres de dominio completamente administrada.

---

## Despliegue Rápido

[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-11-waf-dns.zip)

---

## Topología de Arquitectura

```
                              INTERNET (0.0.0.0/0)
                                     │
                                     │ DNS Query
                                     │ app.ejemplo-dominio.com
                                     ▼
                    ┌────────────────────────────┐
                    │    OCI DNS Zone            │
                    │  (Primary / Authoritative) │
                    │  ejemplo-dominio.com         │
                    │                            │
                    │  A Record:                 │
                    │  app → LB IP (203.0.113.x) │
                    │  TTL: 300                  │
                    │  NS Records (auto)         │
                    └────────────┬───────────────┘
                                 │
                                 │ DNS Response
                                 │
                    ┌────────────▼───────────────┐
                    │  NSG: L7 (Aplicación)      │
                    │  Reglas:                   │
                    │  • HTTP/HTTPS entrada      │
                    │  • SSH (bastion)           │
                    └────────────┬───────────────┘
                                 │
                    ┌────────────▼──────────────────┐
                    │  WAF Policy (OWASP Core)      │
                    │                               │
                    │  ├─ XSS Protection            │
                    │  │  (CRS 941110)              │
                    │  │  Bloquea: <script>, etc.   │
                    │  │                            │
                    │  ├─ SQL Injection             │
                    │  │  (CRS 942251)              │
                    │  │  Bloquea: UNION SELECT     │
                    │  │                            │
                    │  └─ Rate Limiting             │
                    │     100 requests/min          │
                    │     Action: Block 5 min       │
                    │                               │
                    │  Mode: Detection/Active       │
                    └────────────┬──────────────────┘
                                 │
                    ┌────────────▼──────────────────┐
                    │  Load Balancer (Público)      │
                    │                               │
                    │  IP: 203.0.113.x              │
                    │  Puerto: 80/443               │
                    │  Health Check: /               │
                    │  Algorithm: Round-Robin       │
                    └────────────┬──────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
    ┌────▼────┐  ┌───────────────▼──────────────┐   ┌──▼──┐
    │ Backend  │  │       VCN: 10.0.0.0/16      │   │Base-│
    │  Pool    │  │                             │   │tion │
    └────┬────┘  │  ┌───────────────────────┐   │   │Service
         │       │  │ Subnet Privada        │   │   └──┬──┘
         │       │  │ 10.0.1.0/24           │   │      │
         │       │  │ (Sem IP Pública)      │   │      │
         │       │  │                       │   │  Acesso
         │       │  │  ┌─────────────────┐  │   │  via
         │       │  │  │ Webserver       │  │   │  SSH
         │       │  │  │ (Privado)       │  │   │  (Bastion)
         │       │  │  │ 10.0.1.x        │  │   │
         │       │  │  │ Apache HTTP     │  │   │
         │       │  │  │ Port 80         │  │   │
         │       │  │  │ Oracle Linux 8  │  │   │
         │       │  │  └──────┬──────────┘  │   │
         │       │  │         │             │   │
         │       │  │  NSG: Webserver       │   │
         │       │  │  • Ingress LB only    │   │
         │       │  │  • SSH from Bastion   │   │
         │       │  └─────────┬─────────────┘   │
         │       │            │                 │
         │       │ ┌──────────▼────────────┐   │
         │       │ │ Subnet Pública        │   │
         │       │ │ 10.0.0.0/24           │   │
         │       │ │ (LB + Bastion)        │   │
         │       │ │                       │   │
         │       │ │  NSG: LB              │   │
         │       │ │  • HTTP/HTTPS ← Int.  │   │
         │       │ │  • TCP 22 (ssh)       │   │
         │       │ └───────────────────────┘   │
         │       │                             │
         │       │  ┌─────────────────────┐    │
         │       │  │ Internet Gateway    │    │
         │       │  └─────────────────────┘    │
         │       └─────────────────────────────┘
         │
         └─► Health Checks verifican Webserver
             cada 10 segundos (HTTP GET /)

FLUJO DE TRÁFICO:

1. Cliente: curl app.ejemplo-dominio.com
2. DNS Query → OCI DNS → Responde IP del LB
3. HTTP GET → WAF Policy evalúa
4. WAF OK → LB distribuye → Webserver privado
5. Respuesta HTTP → Cliente

SEGURIDAD CAPAS:

Capa 3 (Red):      NSG permitir solo LB → Webserver
Capa 4 (Transporte): LB verificar conexión TCP
Capa 5 (Sesión):   Health Check
Capa 7 (Aplicación): WAF OWASP CRS (XSS, SQL, Rate Limit)
```

---

## Recursos Desplegados

| Recurso | Descripción | Tipo OCI | Cantidad |
|---------|-------------|----------|----------|
| **VCN** | Red privada aislada | `oci_core_vcn` | 1 |
| **Subnet Pública** | Para Load Balancer | `oci_core_subnet` | 1 |
| **Subnet Privada** | Para Webserver | `oci_core_subnet` | 1 |
| **Internet Gateway** | Acceso a Internet | `oci_core_internet_gateway` | 1 |
| **NAT Gateway** | Salida privada a Internet | `oci_core_nat_gateway` | 1 |
| **Service Gateway** | Acceso a servicios OCI | `oci_core_service_gateway` | 1 |
| **Route Table Pública** | Rutas para subnet pública | `oci_core_route_table` | 1 |
| **Route Table Privada** | Rutas para subnet privada | `oci_core_route_table` | 1 |
| **Network Security Group (Web)** | NSG para webserver | `oci_core_network_security_group` | 1 |
| **Network Security Group (SSH)** | NSG para acceso SSH | `oci_core_network_security_group` | 1 |
| **Instancia Webserver** | Servidor Apache privado | `oci_core_instance` | 1 |
| **VNIC (Webserver)** | Interfaz de red privada | `oci_core_vnic` | 1 |
| **Load Balancer Público** | Distribuye tráfico | `oci_load_balancer_load_balancer` | 1 |
| **Backend Set** | Grupo de backends | `oci_load_balancer_backend_set` | 1 |
| **Backend** | Instancia registrada | `oci_load_balancer_backend` | 1 |
| **Health Check** | Monitor del webserver | `oci_load_balancer_health_checker` | 1 |
| **Listener** | Puerto HTTP en LB | `oci_load_balancer_listener` | 1 |
| **WAF Policy** | Reglas de protección L7 | `oci_waf_web_app_firewall_policy` | 1 |
| **WAF (Web App Firewall)** | WAF instance | `oci_waf_web_app_firewall` | 1 |
| **DNS Zone** | Zona DNS pública | `oci_dns_zone` | 1 |
| **DNS A Record** | app.ejemplo-dominio.com | `oci_dns_rrset` | 1 |
| **Bastion Service** | Acceso SSH a privado | `oci_bastion_bastion` | 1 |

**Total de Recursos:** 22 recursos

---

## Shapes de Instancias Compatibles

| Shape | vCPUs | Memoria | Costo | Recomendación |
|-------|-------|---------|-------|---------------|
| **VM.Standard.E4.Flex** | 1-64 | 1-1024 GB | USD 0.04/h | **(Recomendado)** General |
| **VM.Standard.E5.Flex** | 1-64 | 1-1024 GB | USD 0.045/h | Alto rendimiento |
| **VM.Standard.A1.Flex** | 1-80 | 6-480 GB | USD 0.01/h | ARM, bajo costo |
| **VM.Optimized3.Flex** | 2-32 | 16-512 GB | USD 0.12/h | CPU intensivo |
| **VM.DenseIO3.Flex** | 2-52 | 16-832 GB | USD 0.18/h | I/O intensivo |
| **X9.2** | 48 | 768 GB | USD 7.46/h | Ultra performance |

**Recomendación para WAF+DNS:** E4.Flex o E5.Flex con 1-2 vCPUs y 4-8 GB RAM. El webserver privado recibe tráfico filtrado por WAF.

---

## Variables Principales

| Variable | Descripción | Tipo | Default | Restricciones |
|----------|-------------|------|---------|----------------|
| `compartment_ocid` | OCID del compartment | string | *(requerido)* | Válido |
| `region` | Región OCI | string | `us-ashburn-1` | Ej: `sa-saopaulo-1` |
| `proyecto` | Prefijo de recursos | string | `waf-dns` | 1-12 caracteres |
| `ambiente` | Ambiente (dev/staging/prod) | string | `desarrollo` | desarrollo, staging, produccion |
| `vcn_cidr` | CIDR de la VCN | string | `10.0.0.0/16` | CIDR válido |
| `subnet_publica_cidr` | CIDR subnet pública (LB) | string | `10.0.0.0/24` | Dentro de VCN |
| `subnet_privada_cidr` | CIDR subnet privada (WS) | string | `10.0.1.0/24` | Dentro de VCN |
| `shape_webserver` | Shape instancia | string | `VM.Standard.E4.Flex` | Shape disponible |
| `ocpus_webserver` | vCPUs webserver | number | `1` | 1-64 |
| `memoria_webserver_gb` | RAM webserver (GB) | number | `8` | Compatible shape |
| `ssh_public_key` | Llave pública SSH | string | *(requerido)* | Formato SSH |
| `dns_zone_name` | Dominio DNS | string | `ejemplo-dominio.com` | FQDN válido |
| `waf_modo` | Modo WAF | string | `Detection` | Detection o Active |
| `habilitar_nsg` | Usar Network Security Groups | bool | `true` | Recomendado: true |
| `ssh_cidr_permitido` | CIDR permitido SSH | string | `0.0.0.0/0` | Restringir en prod |

---

## Estimación de Costos

### Escenario 1: Desarrollo (1 vCPU, 4 GB, Detection Mode)

```
Instancia Webserver (VM.Standard.E4.Flex 1vCPU):
  - 1 x USD 0.05/h x 730 h/mes = USD 36.50/mes

Load Balancer (10 Mbps):
  - 1 x USD 0.025/h x 730 h/mes = USD 18.25/mes

WAF Policy:
  - USD 0.001 por millón de requests (Detection mode)
  - Estimado 1M req/mes = USD 1/mes

DNS Zone:
  - USD 0.50/mes (50k queries incluidos)

IP Pública (LB):
  - 1 x USD 0.005/h x 730 h/mes = USD 3.65/mes

Bastion Service:
  - SIN COSTO (1 sesión incluida)

Total Mensual:  ~USD 60
```

### Escenario 2: Producción (2 vCPU, 8 GB, Active Mode + Observabilidad)

```
Instancia Webserver (VM.Standard.E5.Flex 2vCPU):
  - 1 x USD 0.21/h x 730 h/mes = USD 153/mes

Load Balancer (100 Mbps):
  - 1 x USD 0.25/h x 730 h/mes = USD 182.50/mes

WAF Policy (Active Mode):
  - USD 3 por millón de requests
  - Estimado 100M req/mes = USD 300/mes

DNS Zone:
  - USD 0.50/mes

IP Pública (LB):
  - USD 3.65/mes

Bastion Service:
  - USD 300/mes (para 10+ sesiones/mes)

Monitoring + Logging (opcional):
  - USD 100-300/mes

Total Mensual:  ~USD 940 (sin observabilidad)
                ~USD 1,240 (con observabilidad)
```

### Always Free Tier

OCI Always Free NO cubre:
- **Load Balancer** (USD 18.25/mes mínimo)
- **WAF Policy** (pagado por requests)
- **DNS Zone** (USD 0.50/mes)

Esta arquitectura requiere **pago mínimo** de ~USD 20/mes.

---

## Prerrequisitos

### 1. Cuenta OCI Activa
- Tenancy ID
- User OCID
- API Key (PEM)
- Fingerprint

### 2. Dominio DNS (Opcional pero Recomendado)

```bash
# Si usas dominio personalizado:
# 1. Compra dominio en registrador (GoDaddy, namecheap, etc.)
# 2. Anota los NS records de OCI DNS
# 3. Apunta dominio a NS records de OCI

# Para testing: usa dominio por defecto ejemplo-dominio.com
# Luego puedes cambiar a tu dominio en terraform.tfvars
```

### 3. Terraform Local

```bash
terraform --version  # v1.0+

# Credenciales OCI
mkdir -p ~/.oci
cp tu-api-key.pem ~/.oci/
chmod 600 ~/.oci/tu-api-key.pem
```

### 4. Llave SSH

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_oracle -C "oracle"
cat ~/.ssh/id_oracle.pub  # Para terraform.tfvars
```

### 5. Permisos IAM Mínimos

```
allow group Developers to manage virtual-network-family in compartment <tu-compartment>
allow group Developers to manage instance-family in compartment <tu-compartment>
allow group Developers to manage load-balancers in compartment <tu-compartment>
allow group Developers to manage waf-* in compartment <tu-compartment>
allow group Developers to manage dns in compartment <tu-compartment>
allow group Developers to use bastion in compartment <tu-compartment>
allow group Developers to manage instance-console-connection in compartment <tu-compartment>
```

---

## Despliegue Rápido

### Paso 1: Configurar Valores

```bash
cd arquitecturas-v2/11-waf-dns

cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

**Contenido mínimo de `terraform.tfvars`:**

```hcl
# Autenticación
tenancy_ocid      = "ocid1.tenancy.oc1.."
compartment_ocid  = "ocid1.compartment.oc1.."
current_user_ocid = "ocid1.user.oc1.."
fingerprint       = "ab:cd:ef:01:23:45:67:89"
private_key_path  = "~/.oci/tu-api-key.pem"
region            = "sa-saopaulo-1"

# Proyecto
proyecto   = "mi-app-waf"
ambiente   = "desarrollo"
propietario = "tu-email@example.com"

# SSH
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5..."

# DNS
dns_zone_name = "ejemplo-dominio.com"  # O tu dominio

# WAF
waf_modo = "Detection"  # O "Active" en producción

# Seguridad
ssh_cidr_permitido = "192.0.2.0/24"  # Tu IP
habilitar_nsg = true
```

### Paso 2: Inicializar

```bash
terraform init
terraform validate
```

### Paso 3: Planificar

```bash
terraform plan -out=tfplan
```

### Paso 4: Desplegar

```bash
terraform apply tfplan
# Tiempo: 5-8 minutos
```

### Paso 5: Obtener Outputs

```bash
# IP del Load Balancer
terraform output lb_ip_publica

# URL del LB
terraform output lb_url

# Registro DNS
terraform output dns_app_record

# Name servers
terraform output dns_zone_nameservers

# Resumen
terraform output resumen
```

---

## Verificación Post-Despliegue

### 1. Verificar Load Balancer

```bash
LB_IP=$(terraform output -raw lb_ip_publica)

# HTTP
curl -i http://$LB_IP/

# Esperado: 200 OK desde Apache
```

### 2. Verificar WAF

```bash
# Test 1: Solicitud normal (debe pasar)
curl http://$LB_IP/

# Test 2: Intento de XSS (debe bloquearse en Active mode)
curl "http://$LB_IP/?param=<script>alert(1)</script>"

# Test 3: Intento de SQL Injection
curl "http://$LB_IP/?id=1' OR '1'='1"

# En Detection mode: Registra pero no bloquea
# En Active mode: Retorna 403 Forbidden
```

### 3. Verificar DNS

```bash
# Consultar A record
dig app.ejemplo-dominio.com +short

# Esperado: IP del Load Balancer

# Verificar NS records
dig ejemplo-dominio.com NS +short

# Esperado: NS records de OCI
```

### 4. Verificar Webserver Privado

```bash
# SSH vía Bastion
bastion_id=$(terraform output -raw bastion_id)

oci bastion session create-managed-ssh \
  --bastion-id $bastion_id \
  --target-name webserver \
  --target-port 22 \
  --username opc

# Luego:
ssh -i ~/.ssh/id_oracle opc@webserver

# Verificar Apache
sudo systemctl status httpd
```

### 5. Dashboard de Monitoreo

```bash
# Ver estado del Load Balancer
oci load-balancer load-balancer get \
  --load-balancer-id $(terraform output -raw lb_id)

# Ver backends
oci load-balancer backend list \
  --load-balancer-id $(terraform output -raw lb_id) \
  --backend-set-name default

# Ver WAF
oci waf web-app-firewall get \
  --web-app-firewall-id $(terraform output -raw waf_id)
```

---

## Limpieza de Recursos

```bash
terraform destroy

# Confirmar: yes
```

---

## Troubleshooting

### Problema 1: "Load Balancer creado pero no responde"

**Síntoma:**
```
$ curl http://203.0.113.1
curl: (7) Failed to connect
```

**Causa:** Webserver no está registrado o Health Check falla.

**Solución:**

```bash
# Verificar health check
oci load-balancer health-checker get \
  --load-balancer-id $(terraform output -raw lb_id) \
  --backend-set-name default

# Verificar webserver corriendo
ssh -i ~/.ssh/id_oracle opc@<WEBSERVER-IP> \
  "sudo systemctl status httpd"

# Reiniciar Apache si no está running
sudo systemctl restart httpd
```

---

### Problema 2: "DNS zone creada pero no resuelve"

**Síntoma:**
```
$ dig app.ejemplo-dominio.com
; <<>> DiG 9.10.6 <<>> app.ejemplo-dominio.com
;; connection timed out
```

**Causa:** Dominio no apuntado a NS records de OCI.

**Solución:**

```bash
# Obtener NS records
terraform output dns_zone_nameservers

# Si usas dominio personalizado:
# 1. Ir a tu registrador de dominios
# 2. Cambiar NS records a los de OCI
# 3. Esperar propagación (24-48 horas)

# Para testing inmediato, usar IP pública del LB
curl http://$(terraform output -raw lb_ip_publica)/
```

---

### Problema 3: "WAF activo pero bloquea tráfico legítimo"

**Síntoma:**
```
HTTP 403 en requests normales
```

**Causa:** Reglas WAF muy restrictivas.

**Solución:**

```bash
# Cambiar a Detection mode (solo logs)
terraform apply -var="waf_modo=Detection"

# Ver logs de WAF
oci waf protection-capability-imports list \
  --compartment-id <tu-compartment>

# Ajustar reglas en main.tf si es necesario
```

---

### Problema 4: "Bastion no conecta al webserver"

**Síntoma:**
```
Error: Cannot connect to webserver via bastion
```

**Causa:** NSG no permite SSH desde Bastion.

**Solución:**

```bash
# Ver NSG del webserver
oci network nsg get \
  --network-security-group-id $(terraform output -raw nsg_webserver_id)

# Debe tener regla:
# Source: Bastion subnet (10.0.0.0/24)
# Protocol: TCP port 22
```

---

### Problema 5: "Costo sorpresa en factura"

**Síntoma:**
```
Load Balancer charges: USD 200+
WAF charges: USD 500+
```

**Causa:** Load Balancer y WAF con alto volumen tráfico.

**Solución:**

```bash
# Reducir en desarrollo
terraform apply \
  -var="waf_modo=Detection" \
  -var="ambiente=desarrollo"

# Destruir si no usas
terraform destroy
```

---

## Siguiente Nivel: Arquitectura 12 - VPN IPsec

Una vez que esta arquitectura WAF+DNS esté estable, el siguiente paso es agregar:

- **VPN IPsec** para conectar oficinas remotas
- **Site-to-Site encryption** para redes privadas
- **User-based VPN** (OpenVPN/WireGuard)
- **Multi-region failover** con DNS

**Continúa a:** [Arquitectura 12: VPN IPsec](../12-vpn-ipsec/README.md)

---

## Recursos Adicionales

### Documentación OCI

- [Load Balancer](https://docs.oracle.com/en-us/iaas/Content/LoadBalancer/Concepts/overview.htm)
- [Web Application Firewall](https://docs.oracle.com/en-us/iaas/Content/WAF/Concepts/overview.htm)
- [DNS Zone](https://docs.oracle.com/en-us/iaas/Content/DNS/Concepts/dnszonemanagement.htm)
- [Bastion Service](https://docs.oracle.com/en-us/iaas/Content/Bastion/Tasks/managingsessions.htm)

### OWASP CRS

- [Core Rule Set 3.x](https://owasp.org/www-community/attacks/xss/)
- [SQL Injection Protection](https://owasp.org/www-community/attacks/SQL_Injection)
- [Rate Limiting Best Practices](https://owasp.org/www-community/attacks/Denial_of_service)

### Terraform

- [OCI Provider WAF](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/waf_web_app_firewall)
- [OCI Provider Load Balancer](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/load_balancer_load_balancer)
- [OCI Provider DNS](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/dns_zone)

---

## Licencia y Atribuciones

Esta arquitectura es parte del repositorio **oracle-cloud-latam** bajo licencia MIT.

**Autor:** jesmonsa
**Última actualización:** 2026-04-12
**Versión:** 2.0.0

---

## FAQ

### Puedo usar WAF sin Load Balancer?

No. En OCI, WAF se asocia directamente a Load Balancer. Si necesitas protección sin LB, usa Security List/NSG a nivel de red.

### Cuál es el latency agregado por WAF?

**Típicamente 5-15 ms** dependiendo de:
- Tamaño del payload
- Complejidad de reglas
- Modo (Detection < Active)

### Puedo usar dominio personalizado desde el inicio?

Sí, pero necesitas:
1. Comprar el dominio
2. Cambiar NS records a los de OCI
3. Esperar propagación DNS (24-48 horas)

Para testing rápido, usa IP pública del LB.

### Qué pasa si el webserver falla?

Con **Health Check habilitado** (default):
- LB detecta el fallo en ~30 segundos
- Deja de enviar tráfico
- Retorna errores 503 Service Unavailable

Para HA completa, agrega segundo webserver (Arquitectura 02).

### Puedo cambiar WAF de Detection a Active después?

Sí, sin downtime:

```bash
terraform apply -var="waf_modo=Active"
```

Recomendación: Mantener en Detection 48 horas para validar reglas.

### Cómo hago backup del webserver privado?

Usa **Boot Volume Backup**:

```bash
oci compute boot-volume-backup create \
  --boot-volume-id <id> \
  --display-name "backup-webserver-2026-04"
```

O con **Image** (snapshot de la instancia):

```bash
oci compute instance create-image \
  --instance-id <id> \
  --display-name "webserver-image-prod"
```

### Puedo añadir SSL/TLS?

Sí, en el Load Balancer:

```hcl
# Agregar listener HTTPS
resource "oci_load_balancer_listener" "https" {
  load_balancer_id       = module.load_balancer.load_balancer_id
  name                   = "https-listener"
  default_backend_set_name = "default"
  port                   = 443
  protocol               = "HTTPS"
  ssl_configuration {
    certificate_ids = [oci_load_balancer_certificate.ssl_cert.id]
  }
}
```

---

**Necesitas ayuda?** Abre un issue en [oracle-cloud-latam/issues](https://github.com/jesmonsa/oracle-cloud-latam/issues)
