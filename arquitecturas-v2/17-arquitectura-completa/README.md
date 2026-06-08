# 17 - Arquitectura Completa — Integración Total de Servicios Empresariales OCI

## Descripción General

Esta es la **arquitectura capstone** que integra todos los servicios OCI clave en una única solución empresarial lista para producción. Combina:
- **Networking:** VCN con subnets públicas y privadas, Load Balancer flexible
- **Compute:** Instancias en alta disponibilidad multi-AD con auto-scaling
- **Seguridad:** Vault (KMS), Bastion Service, Network Security Groups
- **Observabilidad:** Monitoring (CPU alarms), Logging (audit + flow logs), Events (automatización)
- **Datos:** Cifrado end-to-end con Vault

**Caso de uso:** Aplicaciones web de misión crítica que requieren:
- Alta disponibilidad con failover automático
- Acceso seguro sin exponerse a internet
- Auditoría completa de tráfico y cambios
- Alertas en tiempo real para problemas de performance
- Cumplimiento normativo con cifrado y logging

## Diagrama de Arquitectura

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          OCI Region (Ashburn / Frankfurt / etc)             │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                        INTERNET                                         │ │
│  └─────────────────────────────────┬──────────────────────────────────────┘ │
│                                    │                                        │
│                    ┌───────────────▼────────────────┐                      │
│                    │   Load Balancer (Flexible)    │                      │
│                    │   IP Pública: 152.x.x.x        │                      │
│                    │   Subnet Regional: 10.0.0.0/24 │                      │
│                    │   Health Check: HTTP GET /     │                      │
│                    └───────────────┬────────────────┘                      │
│                                    │                                        │
│  ┌─────────────────────────┬───────┴──────────┬──────────────────────────┐ │
│  │                         │                  │                          │ │
│  ▼                         ▼                  ▼                          │ │
│  ┌──────────────────────────────────┐ ┌──────────────────────────────┐  │ │
│  │  Webserver 1 (Apache + SSL)      │ │ Webserver 2 (Apache + SSL)   │  │ │
│  │  VM.Standard.E4.Flex             │ │ VM.Standard.E4.Flex          │  │ │
│  │  1 OCPU / 8 GB RAM               │ │ 1 OCPU / 8 GB RAM            │  │ │
│  │  Oracle Linux 8                  │ │ Oracle Linux 8               │  │ │
│  │  Subnet Privada AD1: 10.0.1.0/24 │ │ Subnet Privada AD2: 10.0.2.0 │  │ │
│  │  NSG: Web (443) + SSH (22)       │ │ NSG: Web (443) + SSH (22)    │  │ │
│  │  NAT Gateway → Internet (salida) │ │ NAT Gateway → Internet       │  │ │
│  └──────────────────────────────────┘ └──────────────────────────────┘  │ │
│         │                                        │                        │ │
│         │ (SSH privado)                          │ (SSH privado)          │ │
│         │                                        │                        │ │
│  ┌──────┴────────────────────────────────────────┴────────────────────┐  │ │
│  │            Bastion Service (acceso SSH seguro)                     │  │ │
│  │  - Sesiones limitadas en tiempo (1 hora por defecto)              │  │ │
│  │  - Auditoría de acceso en Logging                                 │  │ │
│  │  - Sin exposed SSH keys a internet                                │  │ │
│  └───────────────────────────────────────────────────────────────────┘  │ │
│                                                                          │ │
│  ┌──────────────────────────────────────────────────────────────────┐  │ │
│  │                   SEGURIDAD & CIFRADO                             │  │ │
│  │  OCI Vault (KMS) → Master Encryption Key (AES-256)               │  │ │
│  │  - Cifra datos en reposo en aplicaciones                         │  │ │
│  │  - Rotación automática de claves                                 │  │ │
│  │  - Auditoría de acceso a datos sensibles                         │  │ │
│  │                                                                    │  │ │
│  │  Network Security Groups (NSG)                                    │  │ │
│  │  - LB-NSG: permite HTTP (80), HTTPS (443)                       │  │ │
│  │  - Web-NSG: permite HTTPS entrada (de LB), SSH (bastion)        │  │ │
│  │  - Bastion-NSG: acceso SSH controlado                           │  │ │
│  │  - Reglas de salida: internet para actualizaciones               │  │ │
│  └──────────────────────────────────────────────────────────────────┘  │ │
│                                                                          │ │
│  ┌──────────────────────────────────────────────────────────────────┐  │ │
│  │                  OBSERVABILIDAD & ALERTAS                         │  │ │
│  │  Monitoring (CPU Utilization)                                     │  │ │
│  │  - Métrica: CPU % cada 60 segundos                                │  │ │
│  │  - Alarm: si CPU > 80% por 5 minutos                              │  │ │
│  │  - Action: notifica ONS Topic → Email al ops team                 │  │ │
│  │                                                                    │  │ │
│  │  Logging (Auditoría + Seguridad)                                  │  │ │
│  │  - VCN Flow Logs: tráfico entrante/saliente                      │  │ │
│  │  - Audit Logs: cambios administrativos (API calls)               │  │ │
│  │  - Security Logs: fallos de acceso, cambios NSG                  │  │ │
│  │  - Retención: 30 días (configurable hasta 365)                   │  │ │
│  │                                                                    │  │ │
│  │  Events + Automation                                               │  │ │
│  │  - Cambio de estado instance (RUNNING → STOPPED)                 │  │ │
│  │  - Cloud Guard problema detectado                                │  │ │
│  │  - Dispara acciones: Email al ops, Slack, webhooks               │  │ │
│  │                                                                    │  │ │
│  │  ONS Topic → Email Notificaciones                                 │  │ │
│  │  - Alertas de CPU high                                            │  │ │
│  │  - Cambios de estado de instancias                                │  │ │
│  │  - Errores de acceso desde Bastion                                │  │ │
│  └──────────────────────────────────────────────────────────────────┘  │ │
│                                                                          │ │
│  ┌──────────────────────────────────────────────────────────────────┐  │ │
│  │                      SERVICIOS SOPORTE                            │  │ │
│  │  - Service Gateway: acceso privado a Object Storage (backups)    │  │ │
│  │  - NAT Gateway: salida segura a internet (parches, updates)      │  │ │
│  │  - Internet Gateway: tráfico entrante al Load Balancer           │  │ │
│  └──────────────────────────────────────────────────────────────────┘  │ │
│                                                                          │ │
└──────────────────────────────────────────────────────────────────────────┘
```

## Recursos Desplegados

| Recurso | Descripción | Tipo OCI |
|---------|-------------|----------|
| **VCN** | Red virtual con CIDR 10.0.0.0/16 | `oci_core_virtual_network` |
| **Internet Gateway** | Punto de entrada para tráfico público | `oci_core_internet_gateway` |
| **NAT Gateway** | Salida controlada a internet desde subnets privadas | `oci_core_nat_gateway` |
| **Service Gateway** | Acceso privado a servicios OCI (Object Storage, etc) | `oci_core_service_gateway` |
| **Subnet Pública** | Subnet regional para Load Balancer (10.0.0.0/24) | `oci_core_subnet` |
| **Subnet Privada AD1** | Subnet en AD1 para Webserver 1 (10.0.1.0/24) | `oci_core_subnet` |
| **Subnet Privada AD2** | Subnet en AD2 para Webserver 2 (10.0.2.0/24) | `oci_core_subnet` |
| **Load Balancer Flexible** | Punto de entrada HTTP/HTTPS, round-robin entre webservers | `oci_load_balancer_load_balancer` |
| **Backend Set** | Grupo de instancias servidas por LB con health checks | `oci_load_balancer_backend_set` |
| **Compute Instances** | 2 x VM con Apache, Oracle Linux 8 (multi-AD) | `oci_core_instance` |
| **Network Security Groups** | NSG para LB, Webservers, Bastion (fine-grained firewall) | `oci_core_network_security_group` |
| **OCI Vault (KMS)** | Bóveda de claves para cifrado de datos sensibles | `oci_kms_vault` |
| **Master Encryption Key** | Clave AES-256 para cifrado end-to-end | `oci_kms_key` |
| **Bastion Service** | Acceso SSH seguro sin exponer puertos públicamente | `oci_bastion_bastion` |
| **Monitoring Alarm** | Alarma en CPU > 80% durante 5 minutos | `oci_monitoring_alarm` |
| **Log Group (Audit)** | Logs de cambios administrativos (API calls) | `oci_logging_log_group` |
| **Log Group (VCN Flow)** | Logs de tráfico de red entrante/saliente | `oci_logging_log_group` |
| **ONS Topic** | Centro de notificaciones para alertas | `oci_ons_notification_topic` |
| **ONS Subscription (Email)** | Entrega de alertas vía correo electrónico | `oci_ons_subscription` |

## Formas Compatibles (Compute Shapes)

| Shape | OCPU | Memoria (GB) | Red (Mbps) | Costo Mensual Estimado | Caso de Uso |
|-------|------|--------------|-----------|----------------------|------------|
| **VM.Standard.E4.Flex** | 1 | 8 | 3000 | $0 (Always Free) | Desarrollo, Testing, PoC |
| **VM.Standard.E4.Flex** | 2 | 16 | 6000 | ~$30 USD | Producción pequeña/media |
| **VM.Standard.E5.Flex** | 1 | 8 | 3000 | ~$20 USD | Cargas optimizadas |
| **VM.Standard.A1.Flex (ARM)** | 1 | 8 | 1000 | $0 (Always Free) | Baja latencia, ARM |
| **VM.Optimized3.Flex** | 1 | 8 | 6000 | ~$50 USD | Compute intensivo |
| **VM.DenseIO3.Flex** | 1 | 8 | 6000 | ~$70 USD | I/O intensivo, DB |

### Recomendaciones por Ambiente

| Ambiente | Shape Recomendado | OCPU | RAM | Justificación |
|----------|-------------------|------|-----|---------------|
| **Desarrollo/PoC** | `E4.Flex` | 1 | 8 GB | Costo mínimo (Always Free) |
| **Staging** | `E4.Flex` o `E5.Flex` | 2 | 16 GB | Performance realista, costo controlado |
| **Producción (bajo tráfico)** | `E4.Flex` | 2-4 | 16-32 GB | Balance rendimiento/costo |
| **Producción (alto tráfico)** | `Optimized3` o `DenseIO3` | 4+ | 32+ GB | Performance máxima |

## Variables Principales

| Variable | Descripción | Valor Por Defecto | Requerida |
|----------|-------------|-------------------|-----------|
| `tenancy_ocid` | OCID de tu tenancy de OCI | - | Sí |
| `compartment_ocid` | OCID del compartment destino | - | Sí |
| `current_user_ocid` | OCID del usuario OCI | - | Sí |
| `fingerprint` | Fingerprint de clave API | - | Sí |
| `private_key_path` | Ruta a clave privada OCI | - | Sí |
| `ssh_public_key` | Tu clave SSH pública (para conectar a instancias) | - | Sí |
| `region` | Región OCI (us-ashburn-1, eu-frankfurt-1, etc) | `us-ashburn-1` | No |
| `proyecto` | Prefijo para nombrar recursos | `completa` | No |
| `ambiente` | Tipo de ambiente (desarrollo/staging/produccion) | `desarrollo` | No |
| `propietario` | Equipo/persona responsable | `admin` | No |
| `vcn_cidr` | CIDR de la VCN | `10.0.0.0/16` | No |
| `subnet_publica_cidr` | CIDR de subnet pública | `10.0.0.0/24` | No |
| `subnet_privada_cidr` | CIDR de subnets privadas | `10.0.1.0/24` | No |
| `shape_webserver` | Shape para instancias compute | `VM.Standard.E4.Flex` | No |
| `ocpus_webserver` | Número de OCPUs (si flex) | `1` | No |
| `memoria_webserver_gb` | RAM en GB (si flex) | `8` | No |
| `habilitar_nsg` | Usar NSG (recomendado true) | `true` | No |
| `ssh_cidr_permitido` | CIDR que puede acceder SSH al Bastion | `0.0.0.0/0` | No |
| `email_notificacion` | Email para recibir alertas | `admin@example.com` | No |

## Estimación de Costos

### Escenario 1: Desarrollo (Always Free)
```
VM.Standard.E4.Flex (1 OCPU, 8 GB RAM):    $0  (Always Free)
VM.Standard.E4.Flex (1 OCPU, 8 GB RAM):    $0  (Always Free)
Load Balancer Flexible (10 Mbps):           $0  (Always Free)
Networking (VCN, IGW, NAT, SGW):           $0  (Gratis)
Vault (1 bóveda + 1 key):                  $7.50 USD/mes
Monitoring + Logging:                      ~$1 USD/mes
─────────────────────────────────────────────
TOTAL:                                     ~$8.50 USD/mes
```

### Escenario 2: Producción Pequeña/Media
```
VM.Standard.E4.Flex (2 OCPU, 16 GB RAM):   ~$30 USD x 2 = $60 USD/mes
Load Balancer Flexible (100 Mbps):         ~$15 USD/mes
Data Transfer (salida):                    ~$20 USD/mes
Vault + KMS:                               $10 USD/mes
Monitoring + Logging + Events:             ~$5 USD/mes
Bastion Service:                           ~$5 USD/mes
─────────────────────────────────────────────
TOTAL:                                     ~$115 USD/mes
```

### Escenario 3: Producción Alta Disponibilidad
```
VM.Standard.E5.Flex (4 OCPU, 32 GB RAM):   ~$80 USD x 2 = $160 USD/mes
Load Balancer Flexible (400 Mbps):         ~$50 USD/mes
Data Transfer (salida):                    ~$50 USD/mes
Vault + Cloud Guard:                       $20 USD/mes
Logging Analytics:                         ~$30 USD/mes
Events + Automation:                       ~$5 USD/mes
Bastion Service:                           ~$5 USD/mes
─────────────────────────────────────────────
TOTAL:                                     ~$320 USD/mes
```

## Prerequisitos

### 1. Credenciales de OCI
```bash
# Generar par de claves API
mkdir -p ~/.oci
openssl genrsa -out ~/.oci/oci_api_key.pem 2048
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem

# Subir clave pública a OCI Console
# Profile → Tenancy Settings → API Keys → Add Public Key
# Copiar el fingerprint generado (ej: a1:b2:c3:...)
```

### 2. Clave SSH para acceder a instancias
```bash
# Generar clave SSH local
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_oci -C "oci-arquitectura"

# Contenido de la clave pública en terraform.tfvars
cat ~/.ssh/id_rsa_oci.pub
```

### 3. Terraform CLI (versión 1.0+)
```bash
# macOS
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip -d /usr/local/bin/

terraform version
```

### 4. OCI CLI (recomendado)
```bash
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
oci setup config
```

## Despliegue Rápido

### Opción 1: Resource Manager (Recomendado para principiantes)

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-17-arquitectura-completa.zip)

Pasos:
1. Click en el botón "Desplegar en Oracle Cloud"
2. Login en OCI Console
3. Acepta términos de Resource Manager
4. Configura variables (proyecto, ambiente, email, ssh_public_key)
5. Review plan Terraform
6. Click "Apply" para desplegar

### Opción 2: Terraform CLI (Completo control)

```bash
# 1. Clonar y navegar
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas-v2/17-arquitectura-completa

# 2. Preparar variables
cp terraform.tfvars.example terraform.tfvars

# 3. Editar terraform.tfvars con tus credenciales y configuración

# 4. Inicializar Terraform
terraform init

# 5. Validar configuración
terraform validate

# 6. Plan (revisa qué será creado)
terraform plan -out=plan.tfplan

# 7. Aplicar
terraform apply plan.tfplan

# 8. Ver outputs (IP del LB, SSH comando al Bastion, etc)
terraform output
```

## Verificación Post-Despliegue

### 1. Validar Load Balancer
```bash
# Obtener IP pública del LB
LB_IP=$(terraform output -raw lb_ip_publica)

# Prueba HTTP
curl -i http://$LB_IP/

# Prueba HTTPS (si certificado auto-signed)
curl -k https://$LB_IP/
```

### 2. Validar Instancias Compute
```bash
# Listar instancias creadas
oci compute instance list --compartment-id $COMPARTMENT_OCID

# Ver detalles de una instancia
oci compute instance get --instance-id <ocid> --query 'data.[display-name,state]'
```

### 3. Acceder via Bastion Service (SSH)
```bash
# Obtener comando de sesión Bastion desde outputs
BASTION_CMD=$(terraform output -raw bastion_ssh_command)

# Ejecutar comando
eval $BASTION_CMD

# Dentro de la sesión, conectar a webserver privado
ssh -i ~/.ssh/id_rsa_oci opc@10.0.1.x
```

### 4. Validar Vault
```bash
# Ver Master Key
oci kms management key list --compartment-id $COMPARTMENT_OCID \
  --endpoint <management-endpoint>
```

### 5. Validar Monitoring & Logging
```bash
# Ver alarmas
oci monitoring alarm list --compartment-id $COMPARTMENT_OCID

# Ver logs recientes
oci logging-search log-search --log-group-id <log-group-id> \
  --query 'data.results[0:5]'
```

### 6. Prueba de Carga (opcional)
```bash
# Instalar Apache Bench
sudo yum install -y httpd-tools

# Generar carga para activar alarmas
ab -n 1000 -c 10 http://$LB_IP/

# Monitorear CPU en OCI Console → Compute → Instances → CPU Utilization
```

## Limpieza (Destruir Arquitectura)

```bash
# ADVERTENCIA: Esto es irreversible. Eliminará:
# - Instancias compute
# - Load Balancer
# - VCN y subnets
# - Vault y claves
# - Logs y alarmas

# 1. Revisar qué será destruido
terraform plan -destroy

# 2. Ejecutar destrucción
terraform destroy

# 3. Responder "yes" cuando se pida confirmación

# 4. Validar que recursos fueron eliminados
oci compute instance list --compartment-id $COMPARTMENT_OCID
oci load-balancer load-balancer list --compartment-id $COMPARTMENT_OCID
```

## Troubleshooting

### Problema: "Error: 400 Bad Request" en terraform init
**Causa:** Credenciales OCI inválidas o camino de archivo incorrecto
**Solución:**
```bash
# Verificar que el archivo de clave privada existe
ls -l ~/.oci/oci_api_key.pem

# Verificar permisos
chmod 600 ~/.oci/oci_api_key.pem

# Verificar OCID format (debe empezar con ocid1.xxx)
echo $TENANCY_OCID
echo $COMPARTMENT_OCID
```

### Problema: "Error: Conflict" al desplegar Load Balancer
**Causa:** Ya existe un LB con ese nombre
**Solución:**
```bash
# Cambiar el prefijo del proyecto en terraform.tfvars
proyecto = "myapp-v2"

# O destruir el anterior
terraform destroy -target=oci_load_balancer_load_balancer.principal
```

### Problema: Instancias no reciben tráfico del LB
**Causa:** NSG bloqueando puerto 443, o health check fallando
**Solución:**
```bash
# Verificar que Apache está corriendo en las instancias
# Conectar via Bastion y revisar:
sudo systemctl status httpd

# Ver logs de Apache
sudo tail -f /var/log/httpd/access_log

# Revisar NSG rules (OCI Console → Networking → NSG)
# Asegurate que puerto 443 está permitido desde el LB
```

### Problema: SSH via Bastion funciona pero no ping a instancias privadas
**Causa:** Service Gateway o rutas de NAT no configuradas correctamente
**Solución:**
```bash
# Verificar rutas
oci network route-table list --compartment-id $COMPARTMENT_OCID

# Dentro de la instancia, probar salida a internet
curl -I https://www.google.com

# Si falla, revisar NAT Gateway
oci network nat-gateway list --compartment-id $COMPARTMENT_OCID
```

### Problema: Alarma de CPU no envía email
**Causa:** Suscripción ONS no confirmada, o email no válido
**Solución:**
```bash
# Revisar estado de suscripción
oci ons subscription list --compartment-id $COMPARTMENT_OCID \
  --query 'data[*].[id,endpoint,lifecycle_state]' --output table

# Si estado es PENDING, confirmar email desde bandeja de entrada

# Simular alarma (optional):
# Conectar a instancia y ejecutar: stress-ng --cpu 4 --timeout 5m
```

## Siguiente Nivel

### Para Kubernetes/Containerización
[Sección OKE](../13-oke-kubernetes/) — Arquitecturas específicas para:
- Oracle Kubernetes Engine (OKE)
- Container Registry
- CI/CD pipelines con OKE
- Service mesh (Istio, Linkerd)
- Ingress controllers

### Para Data
[Sección 07 - Database](../07-dataguard-ha/) — Arquitecturas para:
- Oracle Database (single + DataGuard)
- MySQL Database Service
- PostgreSQL Database Service
- Autonomous Database (ADB)

### Para Networking Avanzado
[Sección 08/09 - Peering](../08-peering-local/) — Conectar múltiples VCNs:
- Local Peering (misma región)
- Remote Peering (regiones diferentes)
- VPN IPSec
- FastConnect (dedicado)

## Arquitecturas Relacionadas

| Arquitectura | Descripción | Enlace |
|-------------|-------------|--------|
| **16 - Vault + Baselines** | Seguridad aislada (sin compute) | `../16-vault-baselines/` |
| **15 - Observabilidad** | Monitoring + Logging avanzado | `../15-observabilidad/` |
| **14 - API Gateway** | REST APIs serverless con autenticación | `../14-api-gateway/` |
| **13 - OKE** | Kubernetes en OCI | `../13-oke-kubernetes/` |
| **12 - VPN IPSec** | Conexión segura a datacenter on-prem | `../12-vpn-ipsec/` |
| **11 - WAF + DNS** | Web Application Firewall + DDoS | `../11-waf-dns/` |

## Mejores Prácticas Implementadas

**Seguridad en Capas:**
- Network Security Groups (NSG) granulares
- Vault para cifrado de datos
- Bastion Service (sin exponer SSH a internet)
- Logging de auditoría completo

**Alta Disponibilidad:**
- Load Balancer con health checks automáticos
- Instancias en múltiples Availability Domains
- NAT Gateway redundante (multi-AD)

**Observabilidad:**
- Monitoring de CPU con alarmas
- VCN Flow Logs para análisis de tráfico
- Logging de cambios administrativos

**Automatización:**
- Events para disparar acciones automáticas
- Terraform para IaC reproducible
- Outputs para integración con otros sistemas

**Cumplimiento:**
- Auditoría de todas las acciones
- Cifrado de datos en reposo (Vault)
- TLS/HTTPS para datos en tránsito
- Documentación de configuración

## Licencia

UPL-1.0 (Universal Permissive License)

Basado en el trabajo original de Martin Linxfeld / FoggyKitchen, refactorizado y modernizado por Jesús Monsa para la comunidad LATAM de Oracle Cloud.

## Soporte y Contribuciones

- **Issues/Bugs:** GitHub Issues en el repositorio
- **Mejoras:** Pull Requests bienvenidas
- **Preguntas:** Discussions en el repositorio
- **Community:** Únete al Slack de Oracle Cloud LATAM
