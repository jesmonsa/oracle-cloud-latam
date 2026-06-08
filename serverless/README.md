# Serverless - Catálogo Empresarial

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/downloads.html)
[![OCI Provider](https://img.shields.io/badge/OCI%20Provider-6.0+-F80000?logo=oracle)](https://registry.terraform.io/providers/oracle/oci/latest)
[![License](https://img.shields.io/badge/License-UPL%201.0-green)](LICENSE)
[![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen)](.)

## Descripción General

Este catálogo empresarial proporciona arquitecturas serverless de **producción lista** basadas en **OCI Functions, API Gateway, Events, y Streaming**. Cada arquitectura es modular, escalable y sigue las mejores prácticas de seguridad y costo de Oracle Cloud Infrastructure.

### Por qué Serverless en OCI

- **Costo Eficiente**: Paga solo por invocaciones (primeras 1M gratis/mes)
- **Sin Gestión de Infraestructura**: OCI gestiona servidores, redes y escalado
- **Integración Nativa**: API Gateway, Events, Streaming, Notifications nativos
- **Multi-lenguaje**: Python, Java, Node.js, Go, Ruby
- **Máxima Disponibilidad**: Distribuido automáticamente entre zonas

---

## Arquitecturas Disponibles

| # | Nombre | Descripción | Complejidad | Caso de Uso |
|---|--------|-------------|-------------|-----------|
| 1 | **functions-basico** | Hello-World con API Gateway | ⭐ Básica | Prototipos, pruebas rápidas |
| 2 | **functions-api-crud** | REST API completa + Autonomous DB | ⭐⭐⭐ Media | Aplicaciones CRUD empresariales |
| 3 | **event-driven** | Arquitectura orientada a eventos | ⭐⭐⭐⭐ Alta | Procesamiento asincrónico, integraciones |
| 4 | **streaming-kafka** | Kafka compatible con OCI Streaming | ⭐⭐⭐⭐ Alta | Análisis en tiempo real, pipelines ETL |
| 5 | **functions-container** | Funciones con imágenes Docker | ⭐⭐⭐ Media | Dependencias complejas, ML models |

---

## Inicio Rápido

### Opción 1: Desplegar desde OCI Resource Manager (recomendado)

#### 1. functions-basico
[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/v1.0.0/serverless-functions-basico.zip)

#### 2. functions-api-crud
[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/v1.0.0/serverless-functions-api-crud.zip)

#### 3. event-driven
[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/v1.0.0/serverless-event-driven.zip)

#### 4. streaming-kafka
[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/v1.0.0/serverless-streaming-kafka.zip)

#### 5. functions-container
[![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/v1.0.0/serverless-functions-container.zip)

### Opción 2: Desplegar con Terraform CLI

```bash
cd serverless/functions-basico
terraform init
terraform plan
terraform apply
```

---

## Topología General

```
┌─────────────────────────────────────────────────────────────────┐
│                     INTERNET / USUARIOS                         │
└────────────────────┬────────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
    ┌───▼─────────┐       ┌──────▼─────────┐
    │ API Gateway │       │ Events Service  │
    └───┬─────────┘       └──────┬──────────┘
        │                        │
        │                 ┌──────┴─────────┐
        │                 │                │
    ┌───▼──────────┐  ┌───▼────────┐  ┌──▼─────────┐
    │ OCI Functions├──┤ Storage    ├──┤Autonomous │
    │ (Python/Java)│  │ (Object)   │  │ Database  │
    └───┬──────────┘  └────────────┘  └───────────┘
        │
    ┌───▼──────────────────┐
    │ Notifications    │
    │ (Email/SMS/Push) │
    └──────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    OCI STREAMING (Kafka)                        │
├─────────────────────────────────────────────────────────────────┤
│  Topic 1      │  Topic 2      │  Topic 3      │  ...            │
│  ┌─────────┐  │  ┌─────────┐  │  ┌─────────┐  │                │
│  │Consumer │  │  │Consumer │  │  │Consumer │  │                │
│  │Function │  │  │Function │  │  │Function │  │                │
│  └─────────┘  │  └─────────┘  │  └─────────┘  │                │
└─────────────────────────────────────────────────────────────────┘
```

---

## Prerrequisitos

### Requerimientos Técnicos

- **Terraform**: v1.5 o superior
- **OCI Provider**: v6.0 o superior
- **CLI de OCI**: Configurado con credenciales válidas
- **Docker** (solo para `functions-container`): v20.10+

### Preparación de Cuenta OCI

```bash
# 1. Crear compartimento (recomendado)
oci iam compartment create \
  --name serverless-compartment \
  --description "Compartimento para recursos serverless"

# 2. Generar API Key
oci setup repair-file-permissions --file ~/.oci/config

# 3. Configurar variables de entorno (opcional)
export OCI_TENANCY_OCID="ocid1.tenancy.oc1...."
export OCI_USER_OCID="ocid1.user.oc1...."
export OCI_FINGERPRINT="xx:xx:xx:..."
export OCI_REGION="us-phoenix-1"
```

### Permisos Mínimos Requeridos (IAM Policy)

```hcl
# Crear esta política en Identity > Policies
Allow group Developers to manage functions-family in compartment serverless-compartment
Allow group Developers to manage api-gateway-family in compartment serverless-compartment
Allow group Developers to manage events in compartment serverless-compartment
Allow group Developers to manage streams in compartment serverless-compartment
Allow group Developers to manage autonomous-database-family in compartment serverless-compartment
Allow group Developers to manage object-storage in compartment serverless-compartment
Allow group Developers to manage container-images in compartment serverless-compartment
```

---

## Estimación de Costos

### OCI Functions (Pay-per-invocation Model)

| Métrica | Tarifa | Nota |
|---------|--------|------|
| **Invocaciones** | Primeras 1M/mes gratis | ~USD 0.0000002/invocación adicional |
| **GB-segundo** | Incluido en invocaciones | Sin costo adicional |
| **Almacenamiento de código** | USD 0.021/GB/mes | Típicamente < 1 MB por función |
| **Tiempo ejecución** | Hasta 300 segundos | Sin costo por tiempo (incluido en invocación) |

### Ejemplo de Costo Mensual (1M invocaciones)

```
1,000,000 invocaciones/mes (después de limite gratuito)
× USD 0.0000002/invocación
= USD 0.20/mes

Almacenamiento: 50 MB × USD 0.021
= USD 0.001/mes

TOTAL ESTIMADO: ~USD 0.20/mes (mínimo)
```

### Comparar con Otros Servicios

| Servicio | 1M Solicitudes | Costo/mes |
|----------|---|----------|
| **OCI Functions** | Gratis + tráfico | USD 0.20 |
| **API Gateway** | USD 3.65 | USD 3.65 |
| **Object Storage** | 5GB | USD 0.026 |
| **Autonomous DB** | Always Free (1 instancia) | USD 0.00 |
| **Total** | - | **USD 3.88** |

---

## Variables Comunes

Todas las arquitecturas utilizan estas variables:

```hcl
variable "tenancy_ocid" {
  description = "OCID del tenancy de OCI"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID del compartment destino"
  type        = string
}

variable "region" {
  description = "Región OCI (ej: us-phoenix-1)"
  type        = string
  default     = "us-phoenix-1"
}

variable "app_name" {
  description = "Nombre de la aplicación"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.app_name))
    error_message = "Debe comenzar con letra, contener solo minúsculas, números y guiones."
  }
}

variable "environment" {
  description = "Entorno (dev, test, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Debe ser uno de: dev, test, prod"
  }
}

variable "enable_monitoring" {
  description = "Habilitar monitoring y logs"
  type        = bool
  default     = true
}

variable "budget_alert_threshold" {
  description = "Umbral de alerta de presupuesto en USD"
  type        = number
  default     = 100
}
```

---

## Gestión de Estado

Todas las configuraciones usan **S3-Compatible Object Storage** de OCI para el estado remoto:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-latam"
    key            = "serverless/{architecture}/terraform.tfstate"
    region         = "us-phoenix-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
```

---

## Documentación Oficial

- [OCI Functions Documentation](https://docs.oracle.com/en-us/iaas/Content/Functions/home.htm)
- [OCI API Gateway](https://docs.oracle.com/en-us/iaas/Content/APIGateway/home.htm)
- [OCI Events Service](https://docs.oracle.com/en-us/iaas/Content/Events/home.htm)
- [OCI Streaming (Kafka-compatible)](https://docs.oracle.com/en-us/iaas/Content/Streaming/home.htm)
- [OCI Autonomous Database](https://docs.oracle.com/en-us/iaas/Content/Database/home.htm)

---

## Detalles por Arquitectura

### 1. functions-basico
**Ideal para**: Prototipos, demostraciones, primeros pasos

Características:
- Función Python simple con retorno "Hello World"
- API Gateway expuesta públicamente
- Monitoreo básico con logs
- SLA 99.95%

Tiempo de despliegue: 5-10 minutos

### 2. functions-api-crud
**Ideal para**: Aplicaciones CRUD completas

Características:
- REST API con operaciones GET, POST, PUT, DELETE
- Integración con Autonomous Database
- Autenticación con API Keys
- Validación de datos entrada
- Documentación Swagger/OpenAPI

Tiempo de despliegue: 15-20 minutos

### 3. event-driven
**Ideal para**: Procesamiento asincrónico, integraciones complejas

Características:
- Eventos disparados automáticamente
- Múltiples funciones encadenadas
- Notificaciones por email/SMS
- Dead Letter Queue para errores
- Auditoría completa

Tiempo de despliegue: 20-25 minutos

### 4. streaming-kafka
**Ideal para**: Análisis en tiempo real, pipelines ETL

Características:
- Kafka-compatible (100% compatible con librerías Kafka)
- Consumidores escalables
- Retención de mensajes configurable
- Monitoreo de Consumer Group
- Integraciones con Data Science

Tiempo de despliegue: 25-30 minutos

### 5. functions-container
**Ideal para**: Dependencias complejas, modelos de ML

Características:
- Imágenes Docker personalizadas
- Soporte para cualquier lenguaje
- Registry privado OCIR
- Recursos (CPU/memoria) configurables
- Compilación y push automáticos

Tiempo de despliegue: 30-40 minutos

---

## Estructura de Directorios

```
serverless/
├── README.md                              # Este archivo
├── functions-basico/
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── schema.yaml
│   └── terraform.tfvars.example
├── functions-api-crud/
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── schema.yaml
│   └── terraform.tfvars.example
├── event-driven/
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── schema.yaml
│   └── terraform.tfvars.example
├── streaming-kafka/
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── schema.yaml
│   └── terraform.tfvars.example
└── functions-container/
    ├── README.md
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── provider.tf
    ├── schema.yaml
    └── terraform.tfvars.example
```

---

## Soporte y Contribuciones

Para reportar problemas o contribuir mejoras:
- Issues: GitHub Issues
- Discusiones: GitHub Discussions
- Contacto: arquitectura@latam.oracle.com

---

## Licencia

UPL 1.0 - Oracle Universal Permissive License
