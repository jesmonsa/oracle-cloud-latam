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

# Language Service Capabilities
variable "enable_sentiment_analysis" {
  description = "Habilitar análisis de sentimientos"
  type        = bool
  default     = true
}

variable "enable_classification" {
  description = "Habilitar clasificación de documentos"
  type        = bool
  default     = true
}

variable "enable_entity_extraction" {
  description = "Habilitar extracción de entidades"
  type        = bool
  default     = true
}

variable "enable_syntax_analysis" {
  description = "Habilitar análisis de sintaxis"
  type        = bool
  default     = true
}

variable "enable_summarization" {
  description = "Habilitar resumen de documentos"
  type        = bool
  default     = false
}

variable "enable_key_phrase_extraction" {
  description = "Habilitar extracción de palabras clave"
  type        = bool
  default     = true
}

variable "enable_language_detection" {
  description = "Habilitar detección de idioma"
  type        = bool
  default     = true
}

variable "enable_translation" {
  description = "Habilitar traducción automática"
  type        = bool
  default     = false
}

variable "supported_languages" {
  description = "Lista de idiomas soportados"
  type        = list(string)
  default     = ["en", "es", "pt"]
  validation {
    condition = alltrue([
      for lang in var.supported_languages : contains(
        ["en", "es", "pt", "fr", "de", "it", "ja", "zh", "hi", "ar"],
        lang
      )
    ])
    error_message = "Algunos idiomas no son válidos."
  }
}

# API Gateway
variable "api_gateway_enabled" {
  description = "Crear API Gateway"
  type        = bool
  default     = true
}

variable "api_gateway_display_name" {
  description = "Nombre de API Gateway"
  type        = string
  default     = "Language API"
}

variable "api_key_enabled" {
  description = "Crear API keys"
  type        = bool
  default     = true
}

variable "rate_limit_per_minute" {
  description = "Límite de requests por minuto"
  type        = number
  default     = 1000
}

# Object Storage
variable "input_bucket_name" {
  description = "Nombre del bucket de entrada"
  type        = string
}

variable "results_bucket_name" {
  description = "Nombre del bucket de resultados"
  type        = string
}

variable "bucket_versioning_enabled" {
  description = "Habilitar versionado"
  type        = bool
  default     = true
}

# Logging & Monitoring
variable "enable_request_logging" {
  description = "Habilitar logging"
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
    "Service"     = "ai-language"
    "Team"        = "ai-team"
  }
}

# VCN
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
