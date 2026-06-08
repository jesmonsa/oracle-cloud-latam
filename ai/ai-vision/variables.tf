variable "region" {
  description = "Región de OCI"
  type        = string
  default     = "us-phoenix-1"
}

variable "compartment_id" {
  description = "OCID del compartment"
  type        = string
}

variable "tenancy_id" {
  description = "OCID del tenancy"
  type        = string
}

variable "oci_profile" {
  description = "Perfil OCI CLI"
  type        = string
  default     = "DEFAULT"
}

variable "environment" {
  description = "Ambiente"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{1,20}$", var.project_name))
    error_message = "project_name debe contener solo letras minúsculas, números y guiones."
  }
}

# Vision Service Configuration
variable "enable_image_classification" {
  description = "Habilitar clasificación de imágenes"
  type        = bool
  default     = true
}

variable "enable_object_detection" {
  description = "Habilitar detección de objetos"
  type        = bool
  default     = true
}

variable "enable_document_analysis" {
  description = "Habilitar análisis de documentos"
  type        = bool
  default     = true
}

# API Gateway
variable "api_gateway_enabled" {
  description = "Crear API Gateway para Vision"
  type        = bool
  default     = true
}

variable "api_gateway_display_name" {
  description = "Nombre de API Gateway"
  type        = string
  default     = "Vision API"
}

variable "api_key_enabled" {
  description = "Crear API keys para autenticación"
  type        = bool
  default     = true
}

variable "rate_limit_per_minute" {
  description = "Límite de requests por minuto"
  type        = number
  default     = 1000
  validation {
    condition     = var.rate_limit_per_minute >= 10 && var.rate_limit_per_minute <= 10000
    error_message = "Rate limit debe estar entre 10 y 10000."
  }
}

# Object Storage
variable "input_bucket_name" {
  description = "Nombre del bucket para imágenes de entrada"
  type        = string
}

variable "results_bucket_name" {
  description = "Nombre del bucket para resultados"
  type        = string
}

variable "bucket_versioning_enabled" {
  description = "Habilitar versionado"
  type        = bool
  default     = true
}

# Logging & Monitoring
variable "enable_request_logging" {
  description = "Habilitar logging de requests"
  type        = bool
  default     = true
}

variable "enable_metrics" {
  description = "Habilitar métricas"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Días de retención de logs"
  type        = number
  default     = 30
}

# Tags
variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default = {
    "Environment" = "dev"
    "Service"     = "ai-vision"
    "Team"        = "ai-team"
  }
}

# VCN (if needed)
variable "existing_vcn_id" {
  description = "OCID de VCN existente"
  type        = string
  default     = null
}

variable "existing_subnet_id" {
  description = "OCID de subnet existente"
  type        = string
  default     = null
}
