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
  default     = "event-driven-app"
  
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
# Event Configuration
# ============================================================================

variable "event_sources" {
  description = "Fuentes de eventos a monitorear"
  type        = list(string)
  default     = ["object-storage"]
  
  validation {
    condition = alltrue([
      for source in var.event_sources : contains(
        ["object-storage", "database", "compute", "network", "identity"],
        source
      )
    ])
    error_message = "Válidas: object-storage, database, compute, network, identity"
  }
}

variable "event_types" {
  description = "Tipos de eventos a procesar"
  type        = list(string)
  default     = ["com.oraclecloud.objectstorage.createobject"]
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
# Error Handling & Retry
# ============================================================================

variable "enable_dlq" {
  description = "Habilitar Dead Letter Queue"
  type        = bool
  default     = true
}

variable "max_retries" {
  description = "Número máximo de reintentos"
  type        = number
  default     = 3
  
  validation {
    condition     = var.max_retries >= 1 && var.max_retries <= 10
    error_message = "Debe estar entre 1 y 10"
  }
}

variable "retry_delay_seconds" {
  description = "Retardo inicial entre reintentos en segundos"
  type        = number
  default     = 5
  
  validation {
    condition     = var.retry_delay_seconds >= 1 && var.retry_delay_seconds <= 300
    error_message = "Debe estar entre 1 y 300"
  }
}

# ============================================================================
# Processing Configuration
# ============================================================================

variable "event_batch_size" {
  description = "Tamaño de lote para procesamiento"
  type        = number
  default     = 10
  
  validation {
    condition     = var.event_batch_size >= 1 && var.event_batch_size <= 100
    error_message = "Debe estar entre 1 y 100"
  }
}

variable "event_batch_timeout_seconds" {
  description = "Timeout para recopilar lote en segundos"
  type        = number
  default     = 30
  
  validation {
    condition     = var.event_batch_timeout_seconds >= 1 && var.event_batch_timeout_seconds <= 300
    error_message = "Debe estar entre 1 y 300"
  }
}

# ============================================================================
# Notifications
# ============================================================================

variable "notification_email" {
  description = "Email para notificaciones"
  type        = string
  default     = ""
}

variable "enable_notifications" {
  description = "Habilitar notificaciones por email"
  type        = bool
  default     = false
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
    Architecture = "event-driven"
    ManagedBy    = "Terraform"
  }
}
