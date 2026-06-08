# ============================================================================
# Authentication & Provider Configuration
# ============================================================================

variable "tenancy_ocid" {
  description = "OCID del tenancy de Oracle Cloud"
  type        = string
  sensitive   = true
}

variable "user_ocid" {
  description = "OCID del usuario para autenticación"
  type        = string
  sensitive   = true
  default     = ""
}

variable "fingerprint" {
  description = "Fingerprint del API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "private_key_path" {
  description = "Ruta al archivo de clave privada"
  type        = string
  sensitive   = true
  default     = "~/.oci/oci_api_key.pem"
}

variable "region" {
  description = "Región OCI para desplegar recursos"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "Región debe estar en formato válido: us-phoenix-1, us-ashburn-1, eu-zurich-1, etc"
  }
}

variable "compartment_ocid" {
  description = "OCID del compartment donde desplegar los recursos"
  type        = string
  sensitive   = true
}

# ============================================================================
# Application Configuration
# ============================================================================

variable "app_name" {
  description = "Nombre de la aplicación (usado para naming de recursos)"
  type        = string
  default     = "hello-world-app"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.app_name))
    error_message = "Debe iniciar con letra minúscula, contener solo minúsculas, números y guiones, y terminar con alfanumérico."
  }
}

variable "environment" {
  description = "Entorno de despliegue (dev, test, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Valores válidos: dev, test, prod"
  }
}

# ============================================================================
# Function Configuration
# ============================================================================

variable "function_name" {
  description = "Nombre de la función OCI"
  type        = string
  default     = "hello-world"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.function_name))
    error_message = "Debe iniciar con letra minúscula y contener solo minúsculas, números y guiones."
  }
}

variable "function_timeout" {
  description = "Timeout de ejecución en segundos (1-300)"
  type        = number
  default     = 30

  validation {
    condition     = var.function_timeout >= 1 && var.function_timeout <= 300
    error_message = "Timeout debe estar entre 1 y 300 segundos."
  }
}

variable "function_memory" {
  description = "Memoria asignada a la función en MB"
  type        = number
  default     = 128

  validation {
    condition     = contains([128, 256, 512, 1024, 2048], var.function_memory)
    error_message = "Memoria debe ser uno de: 128, 256, 512, 1024, 2048 MB."
  }
}

variable "function_provisioned_concurrency" {
  description = "Número de instancias provisionadas (0 = sin provisionar)"
  type        = number
  default     = 0

  validation {
    condition     = var.function_provisioned_concurrency >= 0 && var.function_provisioned_concurrency <= 100
    error_message = "Concurrencia debe estar entre 0 y 100."
  }
}

# ============================================================================
# Networking Configuration
# ============================================================================

variable "vcn_cidr_block" {
  description = "Bloque CIDR de la VCN"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vcn_cidr_block, 0))
    error_message = "Debe ser un bloque CIDR válido."
  }
}

variable "subnet_cidr_block" {
  description = "Bloque CIDR de la subred"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.subnet_cidr_block, 0))
    error_message = "Debe ser un bloque CIDR válido."
  }
}

# ============================================================================
# Monitoring & Observability
# ============================================================================

variable "enable_monitoring" {
  description = "Habilitar monitoreo con dashboards y alertas"
  type        = bool
  default     = true
}

variable "enable_detailed_logs" {
  description = "Habilitar logs detallados de ejecución"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Días de retención de logs"
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days > 0 && var.log_retention_days <= 3650
    error_message = "Debe estar entre 1 y 3650 días."
  }
}

# ============================================================================
# Budget & Cost Management
# ============================================================================

variable "budget_alert_amount" {
  description = "Monto en USD para alertas de presupuesto"
  type        = number
  default     = 50

  validation {
    condition     = var.budget_alert_amount > 0
    error_message = "Debe ser un valor positivo."
  }
}

variable "budget_alert_threshold_percentage" {
  description = "Porcentaje del presupuesto para generar alerta (0-100)"
  type        = number
  default     = 80

  validation {
    condition     = var.budget_alert_threshold_percentage > 0 && var.budget_alert_threshold_percentage <= 100
    error_message = "Debe estar entre 0 y 100 porciento."
  }
}

# ============================================================================
# Tags & Labels
# ============================================================================

variable "tags" {
  description = "Tags para aplicar a todos los recursos"
  type        = map(string)
  default = {
    Architecture = "serverless"
    ManagedBy    = "Terraform"
    CostCenter   = "Engineering"
    Application  = "hello-world"
  }
}

variable "freeform_tags" {
  description = "Tags de forma libre para control de costos"
  type        = map(string)
  default = {
    Environment = "dev"
    Owner       = "platform-team"
  }
}

# ============================================================================
# API Gateway Configuration
# ============================================================================

variable "api_gateway_stage" {
  description = "Nombre del stage de API Gateway"
  type        = string
  default     = "prod"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.api_gateway_stage))
    error_message = "Debe ser válido para naming de recursos."
  }
}

variable "api_gateway_enable_metrics" {
  description = "Habilitar métricas en API Gateway"
  type        = bool
  default     = true
}

variable "api_gateway_logging_level" {
  description = "Nivel de logging de API Gateway"
  type        = string
  default     = "INFO"

  validation {
    condition     = contains(["FATAL", "ERROR", "WARNING", "INFO", "DEBUG"], var.api_gateway_logging_level)
    error_message = "Debe ser uno de: FATAL, ERROR, WARNING, INFO, DEBUG"
  }
}
