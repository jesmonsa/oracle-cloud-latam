# ============================================================================
# Authentication & Provider
# ============================================================================

variable "tenancy_ocid" {
  description = "OCID del tenancy"
  type        = string
  sensitive   = true
}

variable "user_ocid" {
  description = "OCID del usuario"
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
  description = "Ruta a clave privada"
  type        = string
  sensitive   = true
  default     = "~/.oci/oci_api_key.pem"
}

variable "region" {
  description = "Región OCI"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID del compartment"
  type        = string
  sensitive   = true
}

# ============================================================================
# Application Configuration
# ============================================================================

variable "app_name" {
  description = "Nombre de aplicación"
  type        = string
  default     = "crud-api"
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.app_name))
    error_message = "Debe iniciar con letra minúscula"
  }
}

variable "environment" {
  description = "Entorno"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Debe ser dev, test o prod"
  }
}

# ============================================================================
# Database Configuration
# ============================================================================

variable "database_admin_password" {
  description = "Contraseña admin de la base de datos"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.database_admin_password) >= 12
    error_message = "Debe tener al menos 12 caracteres"
  }
}

variable "database_version" {
  description = "Versión de Autonomous Database"
  type        = string
  default     = "21c"
  
  validation {
    condition     = contains(["19c", "21c", "23c"], var.database_version)
    error_message = "Debe ser 19c, 21c o 23c"
  }
}

variable "database_workload_type" {
  description = "Tipo de carga de trabajo (OLTP o DW)"
  type        = string
  default     = "OLTP"
  
  validation {
    condition     = contains(["OLTP", "DW"], var.database_workload_type)
    error_message = "Debe ser OLTP o DW"
  }
}

variable "database_storage_gb" {
  description = "Storage en GB (Always Free = 20 GB)"
  type        = number
  default     = 20
  
  validation {
    condition     = var.database_storage_gb >= 20
    error_message = "Mínimo 20 GB para Always Free"
  }
}

variable "database_cpu_count" {
  description = "Número de OCPUs (Always Free = 1 OCPU)"
  type        = number
  default     = 1
  
  validation {
    condition     = var.database_cpu_count >= 1
    error_message = "Mínimo 1 OCPU"
  }
}

variable "enable_auto_backup" {
  description = "Habilitar backups automáticos"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Días de retención de backups"
  type        = number
  default     = 30
  
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 60
    error_message = "Debe estar entre 1 y 60 días"
  }
}

# ============================================================================
# Function Configuration
# ============================================================================

variable "function_memory" {
  description = "Memoria de función en MB"
  type        = number
  default     = 256
  
  validation {
    condition     = contains([128, 256, 512, 1024, 2048], var.function_memory)
    error_message = "Valores válidos: 128, 256, 512, 1024, 2048"
  }
}

variable "function_timeout" {
  description = "Timeout en segundos"
  type        = number
  default     = 60
  
  validation {
    condition     = var.function_timeout >= 1 && var.function_timeout <= 300
    error_message = "Debe estar entre 1 y 300"
  }
}

# ============================================================================
# API Configuration
# ============================================================================

variable "api_stage" {
  description = "Stage del API"
  type        = string
  default     = "prod"
}

variable "rate_limit_requests_per_minute" {
  description = "Límite de solicitudes por minuto"
  type        = number
  default     = 100
  
  validation {
    condition     = var.rate_limit_requests_per_minute > 0
    error_message = "Debe ser positivo"
  }
}

# ============================================================================
# Monitoring & Observability
# ============================================================================

variable "enable_monitoring" {
  description = "Habilitar monitoreo"
  type        = bool
  default     = true
}

variable "enable_detailed_logs" {
  description = "Logs detallados"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Retención de logs en días"
  type        = number
  default     = 30
}

# ============================================================================
# Tags
# ============================================================================

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default = {
    Architecture = "serverless"
    ManagedBy    = "Terraform"
    Application  = "crud-api"
  }
}
