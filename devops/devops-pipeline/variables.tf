variable "tenancy_ocid" {
  type        = string
  description = "OCID del tenancy de OCI"
  sensitive   = true
}

variable "user_ocid" {
  type        = string
  description = "OCID del usuario de OCI"
  sensitive   = true
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint de la clave pública del usuario"
  sensitive   = true
}

variable "private_key_path" {
  type        = string
  description = "Ruta a la clave privada del usuario"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Región de OCI"
  default     = "us-phoenix-1"
}

variable "compartment_id" {
  type        = string
  description = "OCID del compartment donde desplegar recursos"
}

variable "project_name" {
  type        = string
  description = "Nombre del proyecto DevOps"
  validation {
    condition     = can(regex("^[a-z0-9-]{1,30}$", var.project_name))
    error_message = "El nombre del proyecto debe contener solo caracteres alfanuméricos y guiones, máximo 30 caracteres."
  }
}

variable "app_name" {
  type        = string
  description = "Nombre de la aplicación"
  validation {
    condition     = can(regex("^[a-z0-9-]{1,20}$", var.app_name))
    error_message = "El nombre de la aplicación debe contener solo caracteres alfanuméricos y guiones, máximo 20 caracteres."
  }
}

variable "environment" {
  type        = string
  description = "Ambiente de despliegue"
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "El ambiente debe ser dev, staging o prod."
  }
}

variable "oke_cluster_name" {
  type        = string
  description = "Nombre del cluster OKE existente"
}

variable "oke_cluster_id" {
  type        = string
  description = "OCID del cluster OKE existente"
}

variable "repository_branch" {
  type        = string
  description = "Rama del repositorio para disparar el pipeline"
  default     = "main"
}

variable "container_repository_name" {
  type        = string
  description = "Nombre del repositorio de contenedores en Container Registry"
  default     = ""
}

variable "build_run_memory" {
  type        = number
  description = "Memoria asignada al build (en MB)"
  default     = 2048
  validation {
    condition     = var.build_run_memory >= 512 && var.build_run_memory <= 16384
    error_message = "La memoria debe estar entre 512 y 16384 MB."
  }
}

variable "enable_notifications" {
  type        = bool
  description = "Habilitar notificaciones del pipeline"
  default     = true
}

variable "notification_topic_endpoint" {
  type        = string
  description = "Endpoint para notificaciones (URL de webhook, email, Slack, etc.)"
  default     = ""
  sensitive   = true
}

variable "enable_monitoring" {
  type        = bool
  description = "Habilitar monitoreo y logging"
  default     = true
}

variable "cost_tracking_enabled" {
  type        = bool
  description = "Habilitar rastreo de costos"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags para aplicar a todos los recursos"
  default = {
    Architecture = "DevOps"
    Terraform    = "true"
    Purpose      = "CI/CD-Pipeline"
  }
}

variable "enable_artifact_registry" {
  type        = bool
  description = "Crear Artifact Registry para artefactos Java/Maven"
  default     = true
}

variable "artifact_repository_names" {
  type        = list(string)
  description = "Nombres de repositorios de artefactos a crear"
  default     = ["maven-releases", "maven-snapshots", "npm-packages"]
}

variable "enable_log_aggregation" {
  type        = bool
  description = "Habilitar agregación de logs en OCI Logging Service"
  default     = true
}

variable "log_retention_days" {
  type        = number
  description = "Días de retención de logs"
  default     = 30
  validation {
    condition     = var.log_retention_days > 0 && var.log_retention_days <= 365
    error_message = "La retención de logs debe estar entre 1 y 365 días."
  }
}
