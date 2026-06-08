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
  default     = "streaming-app"
  
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
# Streaming Configuration
# ============================================================================

variable "num_partitions" {
  description = "Número de particiones"
  type        = number
  default     = 3
  
  validation {
    condition     = var.num_partitions >= 1 && var.num_partitions <= 32
    error_message = "Debe estar entre 1 y 32"
  }
}

variable "retention_hours" {
  description = "Horas de retención de mensajes"
  type        = number
  default     = 24
  
  validation {
    condition     = contains([24, 72, 168], var.retention_hours)
    error_message = "Válidos: 24 (1 día), 72 (3 días), 168 (7 días)"
  }
}

variable "stream_topics" {
  description = "Topics a crear"
  type        = list(string)
  default     = ["events", "transactions"]
}

# ============================================================================
# Consumer Configuration
# ============================================================================

variable "consumer_group_name" {
  description = "Nombre del consumer group"
  type        = string
  default     = "default-group"
}

variable "enable_auto_offset_reset" {
  description = "Reset automático de offset"
  type        = bool
  default     = true
}

variable "max_partition_bytes" {
  description = "Tamaño máximo de partición en bytes"
  type        = number
  default     = 1073741824  # 1 GB
}

# ============================================================================
# Function Configuration
# ============================================================================

variable "function_memory" {
  description = "Memoria de función en MB"
  type        = number
  default     = 512
  
  validation {
    condition     = contains([128, 256, 512, 1024, 2048], var.function_memory)
    error_message = "Valores válidos: 128, 256, 512, 1024, 2048"
  }
}

variable "function_timeout" {
  description = "Timeout en segundos"
  type        = number
  default     = 120
  
  validation {
    condition     = var.function_timeout >= 1 && var.function_timeout <= 300
    error_message = "Debe estar entre 1 y 300"
  }
}

# ============================================================================
# Destination Configuration
# ============================================================================

variable "archive_bucket_name" {
  description = "Nombre del bucket para archival"
  type        = string
  default     = ""  # Si está vacío, no crear bucket
}

variable "enable_database_sink" {
  description = "Habilitar sink a Autonomous Database"
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

variable "consumer_lag_threshold" {
  description = "Umbral de consumer lag en mensajes"
  type        = number
  default     = 10000
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
    Architecture = "streaming"
    ManagedBy    = "Terraform"
  }
}
