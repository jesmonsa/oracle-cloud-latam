# 16 - Vault + Baselines — Seguridad Empresarial con KMS, Cloud Guard y Auditoría

## Descripción General

Esta arquitectura implementa los cimientos de seguridad empresarial en Oracle Cloud Infrastructure (OCI). Integra los servicios de seguridad más críticos para proteger datos sensibles, detectar amenazas y mantener una auditoría completa del entorno.

**Caso de uso:** Organizaciones que requieren cumplimiento de normativas (PCI-DSS, HIPAA, SOC 2, ISO 27001) y necesitan:
- Cifrado centralizado de datos en reposo con Vault/KMS
- Detección automática de amenazas y vulnerabilidades
- Alertas en tiempo real para eventos de seguridad
- Auditoría completa de acciones administrativas y cambios en la configuración

## Diagrama de Arquitectura

```
┌────────────────────────────────────────────────────────────────┐
│                    OCI Tenancy/Region                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    VCN (Minimal)                         │  │
│  │  Endpoint de Vault (HTTPS)                              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │         OCI VAULT (KMS) — Almacén de Claves            │   │
│  │  ┌───────────────────────────────────────────────────┐  │   │
│  │  │    Master Encryption Key (AES-256)               │  │   │
│  │  │    • Almacenamiento seguro a nivel HSM           │  │   │
│  │  │    • Rotación automática configurable            │  │   │
│  │  │    • Auditoría de acceso a claves                │  │   │
│  │  └───────────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │    CLOUD GUARD — Detección de Amenazas                 │   │
│  │  ┌───────────────────────────────────────────────────┐  │   │
│  │  │  Target: Compartment                             │  │   │
│  │  │  • Detector Recipes (análisis continuo)          │  │   │
│  │  │  • Responder Recipes (remediación automática)    │  │   │
│  │  │  • Problemas activos visualizados en consola     │  │   │
│  │  └───────────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │    ONS (Oracle Notification Service)                    │   │
│  │  ┌───────────────────────────────────────────────────┐  │   │
│  │  │  Topic: Alertas de Seguridad                     │  │   │
│  │  │  └─► Suscriptor Email (admin@ejemplo.com)        │  │   │
│  │  │       • Alertas de Vault                         │  │   │
│  │  │       • Alertas de Cloud Guard                   │  │   │
│  │  │       • Alertas de cambios de configuración      │  │   │
│  │  └───────────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │    LOGGING — Auditoría y Rastreo                        │   │
│  │  ┌───────────────────────────────────────────────────┐  │   │
│  │  │  Log Group: Audit + Security                     │  │   │
│  │  │  • Auditoría administrativo (API calls)          │  │   │
│  │  │  • Registros de seguridad (fallos de acceso)     │  │   │
│  │  │  • Logs personalizados de aplicaciones           │  │   │
│  │  │  • Retención: 30 días (configurable)             │  │   │
│  │  └───────────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │    EVENTOS Y ALERTAS                                     │   │
│  │  • Crear/Actualizar secretos → Email                  │   │
│  │  • Cambios en políticas de IAM → Email               │   │
│  │  • Cloud Guard detecta problemas → Responde auto    │   │
│  └─────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────┘
```

## Recursos Desplegados

| Recurso | Descripción | Tipo OCI |
|---------|-------------|----------|
| **OCI Vault (KMS)** | Bóveda de claves criptográficas con soporte HSM | `oci_kms_vault` |
| **Master Encryption Key** | Clave AES-256 para cifrado de datos en reposo | `oci_kms_key` |
| **Cloud Guard Target** | Objetivo de evaluación de seguridad a nivel de compartment | `oci_cloud_guard_target` |
| **Cloud Guard Recipes** | Detector + Responder para detección y remediación automática | `oci_cloud_guard_*_recipe` |
| **ONS Topic** | Tema de notificación para alertas de seguridad | `oci_ons_notification_topic` |
| **ONS Subscription (Email)** | Suscriptor que entrega alertas vía correo electrónico | `oci_ons_subscription` |
| **Audit Log Group** | Grupo de logs para auditoría administrativa | `oci_logging_log_group` |
| **Security Log Group** | Grupo de logs para eventos de seguridad | `oci_logging_log_group` |
| **VCN (Minimal)** | Red virtual mínima para endpoints de Vault | `oci_core_virtual_network` |

## Características de Seguridad Clave

### OCI Vault (KMS)
- **Cifrado de nivel HSM:** Claves almacenadas en Hardware Security Module de Oracle
- **Rotación automática:** Política configurable de rotación de claves maestras
- **Auditoría completa:** Todas las operaciones de cifrado/descifrado registradas
- **Cumplimiento normativo:** Soporta PCI-DSS, HIPAA, FedRAMP, ISO 27001

### Cloud Guard
- **Detector Recipes:** Análisis continuo de configuración, permisos y cambios
- **Responder Recipes:** Remediación automática de problemas detectados
- **Severidades:** Crítica, Alta, Media, Baja
- **Visibilidad:** Dashboard de problemas activos, históricos y resueltos

### Logging y Auditoría
- **Audit Logs:** Registro de cambios administrativos (crear, actualizar, eliminar recursos)
- **Security Logs:** Fallos de acceso, cambios de políticas, eventos de seguridad
- **Retención:** Configurable (30 días por defecto, hasta 365 días)
- **Integración:** Los logs pueden ser exportados a Object Storage o analizados con Logging Analytics

### Notificaciones
- **Alertas en tiempo real:** Cambios inmediatos en la configuración de Vault
- **Email notifications:** Integración con servicios externos vía protocolo SMTP
- **Escalabilidad:** Topic único permite múltiples suscriptores (Slack, PagerDuty, etc.)

## Costos Estimados

| Servicio | Configuración | Costo Estimado |
|----------|---------------|----------------|
| **OCI Vault** | 1 bóveda DEFAULT + 1 clave AES-256 | **$7.50 USD/mes** |
| **Cloud Guard** | Target + Recipes (1 compartment) | **$10.00 USD/mes** |
| **ONS** | 1 topic + 1 suscriptor email | Gratis (< 1000 msgs/mes) |
| **Logging** | Log groups con retención 30 días | ~**$0.50 USD/mes** |
| **VCN Minimal** | 1 VCN sin tráfico significativo | Gratis |
| | **TOTAL ESTIMADO** | **~$18 USD/mes** |

### Notas sobre Always Free Tier
- **Vault no está en Always Free,** pero es altamente recomendado para producción
- Para pruebas de desarrollo, puede usar Secrets Manager (sin cifrado HSM) - Gratis hasta 10 secretos
- Cloud Guard requiere permisos de tenancy admin y está fuera del Always Free Tier

## Prerequisitos

### 1. Cuenta de Oracle Cloud
- Tenancy activa con permisos de administrador o desarrollador
- Mínimo 1 compartment accesible (recomendado: compartment dedicado a seguridad)

### 2. Credenciales de OCI
```bash
# Crear par de claves API en OCI Console:
# Profile → Tenancy Settings → API Keys
# Guardar la clave privada en ~/.oci/oci_api_key.pem (permisos 600)

# Crear archivo de configuración
mkdir -p ~/.oci
cp oci_api_key.pem ~/.oci/
chmod 600 ~/.oci/oci_api_key.pem
```

### 3. Terraform CLI
```bash
# Instalación en macOS/Linux
brew install terraform

# Verificar versión (mínimo 1.0)
terraform version
```

### 4. OCI CLI (opcional pero recomendado)
```bash
# Instalación
curl https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh | bash

# Configuración
oci setup config
```

### 5. Variables requeridas
```bash
# Obtener del OCI Console
# 1. Tenancy OCID: Admin → Tenancy Details
# 2. Compartment OCID: Identity → Compartments
# 3. User OCID: Admin → Users → Your User
# 4. API Key Fingerprint: User details → API Keys
```

### 6. Correo de notificación
- Email válido para recibir alertas de seguridad
- Recomendado: usar dirección de grupo (ops-alerts@ejemplo.com)

## Despliegue Rápido

### Opción 1: Despliegue con OCI Resource Manager (GUI)

[![Desplegar en Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/latest/download/v2-16-vault-baselines.zip)

Pasos:
1. Haz clic en el botón "Desplegar en Oracle Cloud"
2. Inicia sesión en tu tenancy de OCI
3. Acepta los términos de Resource Manager
4. Configura las variables (proyecto, ambiente, email)
5. Revisa el plan Terraform
6. Haz clic en "Apply" para crear los recursos

### Opción 2: Despliegue Manual con Terraform CLI

```bash
# 1. Clonar repositorio
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/arquitecturas-v2/16-vault-baselines

# 2. Crear archivo de variables
cp terraform.tfvars.example terraform.tfvars

# 3. Editar terraform.tfvars con tus valores
# Requeridos:
#   - tenancy_ocid
#   - compartment_ocid
#   - current_user_ocid
#   - fingerprint
#   - private_key_path
#   - email_notificacion (para alertas)

# 4. Inicializar Terraform
terraform init

# 5. Revisar el plan
terraform plan -out=tfplan

# 6. Aplicar los cambios
terraform apply tfplan

# 7. Ver outputs
terraform output
```

## Variables Principales

| Variable | Descripción | Valor Por Defecto | Requerida |
|----------|-------------|-------------------|-----------|
| `tenancy_ocid` | OCID de tu tenancy de OCI | - | Sí |
| `compartment_ocid` | OCID del compartment destino | - | Sí |
| `current_user_ocid` | OCID del usuario OCI | - | Sí |
| `fingerprint` | Fingerprint de la clave API | - | Sí |
| `private_key_path` | Ruta a la clave privada | - | Sí |
| `region` | Región de OCI | `us-ashburn-1` | No |
| `proyecto` | Prefijo para nombrar recursos | `vault` | No |
| `ambiente` | ambiente de despliegue | `desarrollo` | No |
| `propietario` | Propietario/equipo responsable | `admin` | No |
| `vcn_cidr` | CIDR block de la VCN | `10.0.0.0/16` | No |
| `email_notificacion` | Email para alertas de seguridad | `admin@example.com` | No |

## Verificación Post-Despliegue

### 1. Validar creación de Vault
```bash
# Ver detalles del Vault creado
oci kms management vault list --compartment-id $COMPARTMENT_OCID

# Ver la Master Key
oci kms management key list --compartment-id $COMPARTMENT_OCID \
  --endpoint <management-endpoint-from-vault>
```

### 2. Validar Cloud Guard (si está habilitado)
```bash
# Listar targets de Cloud Guard
oci cloud-guard target list --compartment-id $COMPARTMENT_OCID

# Ver problemas detectados
oci cloud-guard problem list --compartment-id $COMPARTMENT_OCID
```

### 3. Validar ONS Topic y suscripción
```bash
# Listar topics
oci ons topic list --compartment-id $COMPARTMENT_OCID

# Listar suscripciones
oci ons subscription list --compartment-id $COMPARTMENT_OCID
```

### 4. Validar Logging
```bash
# Listar log groups
oci logging log-group list --compartment-id $COMPARTMENT_OCID

# Ver logs recientes
oci logging-search log-search --log-group-id <log-group-id>
```

### 5. Prueba de cifrado (opcional)
```bash
# Crear un secreto cifrado con la Master Key
oci secrets create --secret-content-type 'application/octet-stream' \
  --vault-id <vault-id> \
  --secret-content-format base64 \
  --secret-content "$(echo 'DatosSecretos123' | base64)"

# Recuperar el secreto (demuestra cifrado/descifrado)
oci secrets get --secret-id <secret-id>
```

### 6. Verificación de Email
- Revisa tu bandeja de entrada (inbox + spam)
- Confirma la suscripción al topic ONS
- Prueba manualmente: crea un recurso o hace un cambio para generar un evento

## Limpieza (Destruir Recursos)

```bash
# ADVERTENCIA: Esta acción es irreversible y eliminará:
# - OCI Vault y Master Key
# - Cloud Guard configuration
# - ONS Topic y subscriptions
# - Log Groups
# - VCN

# 1. Revisar qué será destruido
terraform plan -destroy

# 2. Destruir los recursos
terraform destroy

# 3. Confirmar cuando se solicite
# Responde "yes" para proceder

# 4. Limpiar estado local (opcional)
rm -rf .terraform terraform.tfstate*
```

## Troubleshooting

### Problema: "Error: 404 Not Found" al crear Cloud Guard Target
**Causa:** Cloud Guard no está habilitado en la tenancy
**Solución:**
```bash
# Habilitar Cloud Guard desde OCI Console:
# - Navigate to: Security → Cloud Guard
# - Click "Enable Cloud Guard"
# - Wait 5-10 minutes for initialization
# - Retry terraform apply
```

### Problema: "Error: UnauthorizedOperation" para permisos de Vault
**Causa:** El usuario de OCI no tiene permisos suficientes
**Solución:**
```bash
# En OCI Console, añade políticas al grupo del usuario:
# Identity → Policies → Create Policy
# Agregar línea:
# Allow group <your-group> to manage kms-family in compartment <compartment-name>
```

### Problema: Email no recibe confirmación de suscripción ONS
**Causa:** Email no enviado o en spam, o endpoint inválido
**Solución:**
1. Revisa bandeja de spam/junk
2. Confirma email válido en terraform.tfvars
3. Re-ejecuta: `terraform apply -target=oci_ons_subscription.email`
4. Comprueba logs: `oci logging-search log-search --query '*'`

### Problema: "Error: Timeout waiting for Vault to be ACTIVE"
**Causa:** Vault tarda en activarse (normal en primera creación)
**Solución:**
```bash
# Esperar 2-3 minutos y reintentar
sleep 180
terraform apply
```

## Siguiente Nivel

[**17 - Arquitectura Completa**](../17-arquitectura-completa/) — Integración total de Vault + Baselines con:
- Load Balancer + Webservers privados (alta disponibilidad)
- Bastion Service para acceso SSH seguro
- Monitoring + Alarms (CPU, memoria)
- Events + Automation (respuesta a cambios de estado)
- Auditoría y Logging integrados
- Cifrado end-to-end con Vault

## Lecturas Recomendadas

1. [OCI Vault documentation](https://docs.oracle.com/en-us/iaas/Content/KeyManagement/Concepts/keyoverview.htm)
2. [OCI Cloud Guard best practices](https://docs.oracle.com/en-us/iaas/cloud-guard/using/home.htm)
3. [OCI Logging & Monitoring](https://docs.oracle.com/en-us/iaas/Content/Logging/Concepts/loggingoverview.htm)
4. [Security Best Practices Guide](https://docs.oracle.com/en-us/iaas/Content/Security/Concepts/security.htm)
5. [Oracle Cloud Security Standards](https://www.oracle.com/cloud/security/)

## Licencia

UPL-1.0 (Universal Permissive License)

Basado en el trabajo original de Martin Linxfeld / FoggyKitchen y transformado por Jesús Monsa para la comunidad LATAM de Oracle Cloud.
