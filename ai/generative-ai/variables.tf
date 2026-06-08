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

# LLM Model Configuration
variable "llm_model" {
  description = "Modelo LLM a usar"
  type        = string
  default     = "meta.llama-2-70b-chat"
  validation {
    condition = contains([
      "meta.llama-2-7b-chat",
      "meta.llama-2-13b-chat",
      "meta.llama-2-70b-chat",
      "cohere.command",
      "cohere.command-light"
    ], var.llm_model)
    error_message = "LLM model no válido."
  }
}

variable "enable_text_generation" {
  description = "Habilitar generación de texto"
  type        = bool
  default     = true
}

variable "enable_chat_completions" {
  description = "Habilitar completions de chat"
  type        = bool
  default     = true
}

variable "enable_embeddings" {
  description = "Habilitar embeddings"
  type        = bool
  default     = true
}

variable "enable_fine_tuning" {
  description = "Habilitar fine-tuning"
  type        = bool
  default     = false
}

variable "max_tokens" {
  description = "Máximo de tokens en respuesta"
  type        = number
  default     = 1000
  validation {
    condition     = var.max_tokens >= 100 && var.max_tokens <= 4096
    error_message = "max_tokens debe estar entre 100 y 4096."
  }
}

variable "temperature" {
  description = "Temperatura para generación (0.0-1.0)"
  type        = number
  default     = 0.7
  validation {
    condition     = var.temperature >= 0.0 && var.temperature <= 1.0
    error_message = "temperature debe estar entre 0.0 y 1.0."
  }
}

# RAG Configuration
variable "enable_rag" {
  description = "Habilitar RAG pipeline"
  type        = bool
  default     = true
}

variable "vector_db_type" {
  description = "Tipo de Vector DB"
  type        = string
  default     = "mysql-heatwave"
  validation {
    condition     = contains(["mysql-heatwave", "adw", "opensearch"], var.vector_db_type)
    error_message = "Vector DB type no válido."
  }
}

variable "embedding_model" {
  description = "Modelo de embeddings"
  type        = string
  default     = "cohere.embed-english-v3.0"
}

variable "similarity_threshold" {
  description = "Umbral mínimo de similitud para RAG"
  type        = number
  default     = 0.7
  validation {
    condition     = var.similarity_threshold >= 0.0 && var.similarity_threshold <= 1.0
    error_message = "Threshold debe estar entre 0.0 y 1.0."
  }
}

variable "top_k_results" {
  description = "Top K documentos para RAG"
  type        = number
  default     = 5
  validation {
    condition     = var.top_k_results >= 1 && var.top_k_results <= 20
    error_message = "top_k_results debe estar entre 1 y 20."
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
  default     = "GenAI API"
}

variable "rate_limit_per_minute" {
  description = "Límite de requests por minuto"
  type        = number
  default     = 100
}

variable "max_concurrent_requests" {
  description = "Máximo de requests concurrentes"
  type        = number
  default     = 50
}

# Document Storage
variable "documents_bucket_name" {
  description = "Nombre del bucket para documentos RAG"
  type        = string
}

variable "embeddings_cache_enabled" {
  description = "Habilitar caché de embeddings"
  type        = bool
  default     = true
}

# Logging & Monitoring
variable "enable_conversation_logging" {
  description = "Habilitar logging de conversaciones"
  type        = bool
  default     = true
}

variable "enable_usage_metrics" {
  description = "Habilitar métricas de uso"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Días de retención de logs"
  type        = number
  default     = 90
}

# Tags
variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default = {
    "Environment" = "dev"
    "Service"     = "generative-ai"
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
