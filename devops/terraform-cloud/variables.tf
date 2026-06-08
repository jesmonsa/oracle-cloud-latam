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

variable "tfc_organization" {
  type        = string
  description = "Organización en Terraform Cloud"
  validation {
    condition     = can(regex("^[a-z0-9-]{1,30}$", var.tfc_organization))
    error_message = "El nombre de organización debe contener solo caracteres alfanuméricos y guiones."
  }
}

variable "tfc_token" {
  type        = string
  description = "Token de API de Terraform Cloud"
  sensitive   = true
}

variable "vcs_oauth_token_id" {
  type        = string
  description = "OAuth Token ID para VCS integration (GitHub, GitLab, etc.)"
  sensitive   = true
}

variable "vcs_repository" {
  type        = string
  description = "Repositorio VCS en formato org/repo"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+/[a-zA-Z0-9._-]+$", var.vcs_repository))
    error_message = "El repositorio debe estar en formato org/repo."
  }
}

variable "workspace_name" {
  type        = string
  description = "Nombre del workspace en Terraform Cloud"
  validation {
    condition     = can(regex("^[a-z0-9_-]{1,40}$", var.workspace_name))
    error_message = "El nombre del workspace debe contener solo caracteres alfanuméricos, guiones y guiones bajos."
  }
}

variable "terraform_version" {
  type        = string
  description = "Versión de Terraform a usar en Terraform Cloud"
  default     = "1.5.0"
}

variable "enable_cost_estimation" {
  type        = bool
  description = "Habilitar estimación de costos en Terraform Cloud"
  default     = true
}

variable "enable_sentinel_policies" {
  type        = bool
  description = "Habilitar Policy as Code con Sentinel"
  default     = true
}

variable "enable_vcs_integration" {
  type        = bool
  description = "Habilitar integración con VCS"
  default     = true
}

variable "vcs_branch" {
  type        = string
  description = "Rama del repositorio para monitorear"
  default     = "main"
}

variable "require_approval" {
  type        = bool
  description = "Requerir aprobación manual antes de apply"
  default     = true
}

variable "enable_auto_apply" {
  type        = bool
  description = "Aplicar automáticamente después de plan aprobado"
  default     = false
}

variable "execution_mode" {
  type        = string
  description = "Modo de ejecución (remote, local)"
  default     = "remote"
  validation {
    condition     = contains(["remote", "local", "agent"], var.execution_mode)
    error_message = "El modo de ejecución debe ser remote, local o agent."
  }
}

variable "create_oci_backend" {
  type        = bool
  description = "Crear bucket Object Storage para backend remoto"
  default     = true
}

variable "enable_state_encryption" {
  type        = bool
  description = "Habilitar encriptación de state con KMS"
  default     = true
}

variable "kms_key_id" {
  type        = string
  description = "OCID de la clave KMS para encriptación"
  default     = ""
}

variable "enable_audit_logging" {
  type        = bool
  description = "Habilitar logging de auditoría"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags para aplicar a todos los recursos"
  default = {
    Architecture = "Terraform-Cloud"
    Terraform    = "true"
    Purpose      = "IaC-Management"
  }
}

variable "environment" {
  type        = string
  description = "Ambiente (dev, staging, prod)"
  default     = "prod"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "El ambiente debe ser dev, staging o prod."
  }
}

variable "run_trigger_patterns" {
  type        = list(string)
  description = "Patrones de rutas para disparar runs automáticamente"
  default     = ["**/*.tf", "variables.tf", "terraform.tfvars"]
}

variable "enable_notifications" {
  type        = bool
  description = "Habilitar notificaciones de runs"
  default     = true
}

variable "notification_webhook_url" {
  type        = string
  description = "Webhook URL para notificaciones (Slack, etc.)"
  default     = ""
  sensitive   = true
}
