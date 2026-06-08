# OCI Functions - Hello World Básico

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/downloads.html)
[![OCI Provider](https://img.shields.io/badge/OCI%20Provider-6.0+-F80000?logo=oracle)](https://registry.terraform.io/providers/oracle/oci/latest)
[![Functions](https://img.shields.io/badge/OCI%20Functions-Supported-green?logo=oracle)](https://www.oracle.com/cloud/functions/)

## Descripción

Arquitectura **serverless minimalista** que desplega una función OCI con API Gateway. Ideal para aprender los conceptos básicos de Functions en OCI y crear prototipos rápidos.

### Características

✓ Función Python simple (Hello-World)
✓ API Gateway con endpoint público
✓ Application de Functions modular
✓ Logs automáticos en OCI Logging
✓ Monitoreo con métricas de CloudWatch
✓ IAM roles y policies preconfigurados
✓ Costo mínimo (<USD 0.20/mes en producción)

---

## Topología

```
                          INTERNET
                             │
                             ▼
                    ┌─────────────────┐
                    │  API Gateway    │
                    │ (Endpoint público)
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ OCI Functions   │
                    │  (hello-world)  │
                    │   (Python 3.x)  │
                    └─────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  OCI Logging    │
                    │   (Execution)   │
                    └─────────────────┘
```

---

## Componentes

| Componente | Tipo | Descripción | Costo |
|-----------|------|-------------|--------|
| **Functions Application** | OCI Functions | Contenedor para funciones serverless | Incluido |
| **Function (hello-world)** | OCI Functions | Función Python 3.x básica | 1M gratis/mes |
| **API Gateway** | API Gateway | Endpoint HTTP/REST público | USD 3.65/mes |
| **VCN** | Networking | Red virtual (necesaria para Functions) | Gratis |
| **Subnet** | Networking | Subred pública | Gratis |
| **Logs Group** | Logging | Logs de ejecución | Primeros 10GB/mes gratis |

**Costo Total Estimado**: USD 3.85-5.00/mes (sin considerar limite gratis)

---

## Variables

### Requeridas

```hcl
variable "tenancy_ocid" {
  description = "OCID del tenancy de OCI"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID del compartment donde desplegar"
  type        = string
}

variable "region" {
  description = "Región OCI"
  type        = string
  example     = "us-phoenix-1"
}
```

### Opcionales

```hcl
variable "app_name" {
  description = "Nombre de la aplicación"
  type        = string
  default     = "hello-world-app"
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.app_name))
    error_message = "Debe iniciar con letra, contener solo minúsculas, números y guiones."
  }
}

variable "environment" {
  description = "Entorno de despliegue"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Valores válidos: dev, test, prod"
  }
}

variable "function_name" {
  description = "Nombre de la función"
  type        = string
  default     = "hello-world"
}

variable "function_timeout" {
  description = "Timeout de función en segundos"
  type        = number
  default     = 30
  
  validation {
    condition     = var.function_timeout >= 1 && var.function_timeout <= 300
    error_message = "Debe estar entre 1 y 300 segundos"
  }
}

variable "function_memory" {
  description = "Memoria de función en MB"
  type        = number
  default     = 128
  
  validation {
    condition     = contains([128, 256, 512, 1024, 2048], var.function_memory)
    error_message = "Valores válidos: 128, 256, 512, 1024, 2048"
  }
}

variable "enable_monitoring" {
  description = "Habilitar monitoreo y alertas"
  type        = bool
  default     = true
}

variable "budget_alert_amount" {
  description = "Monto en USD para alertas de presupuesto"
  type        = number
  default     = 50
  
  validation {
    condition     = var.budget_alert_amount > 0
    error_message = "Debe ser un valor positivo"
  }
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default = {
    Architecture = "serverless"
    ManagedBy    = "Terraform"
    CostCenter   = "Engineering"
  }
}
```

---

## Instalación y Despliegue

### Paso 1: Clonar repositorio

```bash
git clone https://github.com/jesmonsa/oracle-cloud-latam.git
cd oracle-cloud-latam/serverless/functions-basico
```

### Paso 2: Configurar Terraform

```bash
# Crear archivo de variables
cp terraform.tfvars.example terraform.tfvars

# Editar valores
cat terraform.tfvars
# tenancy_ocid      = "ocid1.tenancy.oc1...."
# compartment_ocid  = "ocid1.compartment.oc1...."
# region            = "us-phoenix-1"
```

### Paso 3: Inicializar Terraform

```bash
terraform init
```

### Paso 4: Validar configuración

```bash
terraform plan
# Revisar recursos a crear
```

### Paso 5: Desplegar

```bash
terraform apply

# Confirmación requerida
# Esperar 2-3 minutos
```

### Paso 6: Obtener endpoint

```bash
terraform output api_endpoint
# Salida: https://xxxxx.apigateway.us-phoenix-1.oci.customer-oci.com/hello
```

---

## Uso

### Invocar función vía API

```bash
# Obtener endpoint
ENDPOINT=$(terraform output -raw api_endpoint)

# Invocar función
curl -s "$ENDPOINT" | jq .

# Salida esperada:
# {
#   "message": "Hello World!",
#   "timestamp": "2026-04-12T10:30:45Z",
#   "function_version": "1.0",
#   "request_id": "abc123"
# }
```

### Invocar con parámetros

```bash
curl -s "$ENDPOINT?name=Oracle" | jq .

# Salida:
# {
#   "message": "Hello Oracle!",
#   "timestamp": "2026-04-12T10:30:45Z"
# }
```

### Ver logs

```bash
# Logs en OCI Console
# Ingresa a: Observability & Management > Logging > Log Groups
# Buscar: hello-world-logs

# O vía CLI:
oci logging-search search-logs \
  --log-group-id <log-group-id> \
  --search-query 'search "hello-world"' \
  --time-range-type RELATIVE_RANGE \
  --relative-range-in-minutes 60
```

---

## Estimación de Costos

### Escenario 1: Desarrollo (10K invocaciones/mes)

```
10,000 invocaciones × $0 (dentro de 1M gratis) = $0.00
API Gateway: $3.65/mes
Logging (< 100MB): $0.00 (dentro de 10GB gratis)
Total: $3.65/mes
```

### Escenario 2: Producción (100K invocaciones/mes)

```
100,000 invocaciones × $0 (dentro de 1M gratis) = $0.00
API Gateway: $3.65/mes
Logging (< 1GB): $0.00 (dentro de 10GB gratis)
Total: $3.65/mes
```

### Escenario 3: Alto Volumen (10M invocaciones/mes)

```
1,000,000 gratis + 9,000,000 × $0.0000002 = $1.80
API Gateway: $3.65/mes
Logging (~100GB): ~$2.15/mes
Total: ~$7.60/mes
```

---

## Troubleshooting

### Problema: "Function not found" al invocar API

**Causa**: La función no está lista
**Solución**:
```bash
# Esperar 30 segundos después del despliegue
sleep 30

# Verificar estado
oci functions function get \
  --function-id <function-id>
  
# Buscar status = "ACTIVE"
```

### Problema: API Gateway retorna 404

**Causa**: Endpoint no configurado correctamente
**Solución**:
```bash
# Verificar API Gateway
oci api-gateway api list \
  --compartment-id <compartment-id>

# Verificar deployment
oci api-gateway deployment list \
  --api-id <api-id>

# Estado debe ser ACTIVE
```

### Problema: Timeout de función

**Causa**: Función tarda más de timeout configurado
**Solución**:
```bash
# Aumentar timeout en variables
# terraform.tfvars
function_timeout = 60  # en lugar de 30

# Aplicar cambios
terraform apply
```

### Problema: Errores de permisos (403)

**Causa**: IAM policy insuficiente
**Solución**:
```bash
# Verificar identity policy incluya:
Allow group Developers to manage functions-family in compartment serverless-compartment
Allow group Developers to manage api-gateway-family in compartment serverless-compartment
Allow group Developers to manage logs in compartment serverless-compartment
```

### Problema: Función está en estado FAILED

**Causa**: Error en despliegue de código
**Solución**:
```bash
# Ver logs de error
terraform destroy  # Limpiar recursos fallidos
terraform apply    # Reintentar despliegue

# O revisar manualmente:
oci logging-search search-logs --log-group-id <id>
```

---

## Monitoreo

### Métricas Disponibles

| Métrica | Descripción | Unidad |
|---------|-------------|--------|
| **Invocations** | Total de invocaciones | Count |
| **Duration** | Tiempo de ejecución promedio | ms |
| **Errors** | Total de errores | Count |
| **Duration P99** | Percentil 99 de latencia | ms |
| **ColdStartDuration** | Duración de inicio frío | ms |

### Crear Dashboard

```bash
# Los recursos se crean automáticamente con enable_monitoring = true
# Ver en: Monitoring > Dashboards > hello-world-dashboard
```

---

## Mantenimiento

### Actualizar función

```bash
# 1. Modificar código fuente
# (No incluido en este template)

# 2. Redeploy
terraform apply -target=oci_functions_function.hello_world

# 3. Verificar nueva versión
curl -s "$ENDPOINT"
```

### Escalar la función

```bash
# Aumentar memoria en terraform.tfvars
function_memory = 256  # en lugar de 128

# Aplicar
terraform apply

# Nota: CPU se asigna proporcionalmente a memoria
```

### Destruir recursos

```bash
terraform destroy

# Confirmación requerida
# Esperar 1-2 minutos

# Verificar que se eliminó todo:
oci api-gateway api list
oci functions application list
```

---

## Integración Continua/Continua

### GitHub Actions (ejemplo)

```yaml
name: Deploy Serverless

on:
  push:
    branches: [main]
    paths:
      - 'serverless/functions-basico/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Terraform Init
        working-directory: serverless/functions-basico
        run: terraform init
        env:
          TF_CLOUD_TOKEN: ${{ secrets.TF_CLOUD_TOKEN }}
      
      - name: Terraform Apply
        working-directory: serverless/functions-basico
        run: terraform apply -auto-approve
        env:
          TF_VAR_tenancy_ocid: ${{ secrets.TENANCY_OCID }}
          TF_VAR_compartment_ocid: ${{ secrets.COMPARTMENT_OCID }}
          OCI_CLI_USER: ${{ secrets.OCI_USER }}
          OCI_CLI_FINGERPRINT: ${{ secrets.OCI_FINGERPRINT }}
          OCI_CLI_KEY_CONTENT: ${{ secrets.OCI_KEY_CONTENT }}
```

---

## Seguridad

### Mejores Prácticas Implementadas

✓ **Función privada**: Solo accesible vía API Gateway
✓ **IAM Roles**: Principio de menor privilegio
✓ **VPC**: Función en red virtual aislada
✓ **Logs**: Auditoría completa de invocaciones
✓ **Encryption**: Datos en tránsito encriptados (TLS)

### Recomendaciones Adicionales

```hcl
# 1. Agregar autenticación a API Gateway
#    (OAuth2, API Keys, OIDC)

# 2. Implementar Rate Limiting
#    en API Gateway

# 3. Usar secrets para datos sensibles
#    en OCI Vault

# 4. Implementar WAF para API Gateway
#    (Web Application Firewall)

# 5. Habilitar API Analytics
#    en API Gateway
```

---

## Documentación Relacionada

- [OCI Functions Quickstart](https://docs.oracle.com/en-us/iaas/Content/Functions/home.htm)
- [OCI API Gateway User Guide](https://docs.oracle.com/en-us/iaas/Content/APIGateway/home.htm)
- [Terraform OCI Provider - Functions](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/functions_function)
- [OCI IAM Best Practices](https://docs.oracle.com/en-us/iaas/Content/Security/Concepts/security_best_practices.htm)

---

## Licencia

UPL 1.0 - Oracle Universal Permissive License

## Soporte

Para preguntas o reportar problemas:
- GitHub Issues: [jesmonsa/oracle-cloud-latam](https://github.com/jesmonsa/oracle-cloud-latam/issues)
- Contacto: arquitectura@latam.oracle.com
