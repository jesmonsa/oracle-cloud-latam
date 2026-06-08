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

variable "oke_cluster_id" {
  type        = string
  description = "OCID del cluster OKE existente"
}

variable "oke_cluster_name" {
  type        = string
  description = "Nombre del cluster OKE existente"
}

variable "argocd_namespace" {
  type        = string
  description = "Namespace donde instalar ArgoCD"
  default     = "argocd"
}

variable "argocd_version" {
  type        = string
  description = "Versión de ArgoCD a instalar"
  default     = "v2.10.0"
}

variable "enable_ingress" {
  type        = bool
  description = "Crear Ingress para acceso a ArgoCD"
  default     = true
}

variable "ingress_class_name" {
  type        = string
  description = "Nombre de la clase Ingress a usar"
  default     = "nginx"
}

variable "repository_url" {
  type        = string
  description = "URL del repositorio Git para sincronizar"
}

variable "repository_branch" {
  type        = string
  description = "Rama del repositorio a sincronizar"
  default     = "main"
}

variable "repository_username" {
  type        = string
  description = "Usuario para autenticación en repositorio Git"
  default     = ""
  sensitive   = true
}

variable "repository_token" {
  type        = string
  description = "Token de acceso para repositorio Git"
  default     = ""
  sensitive   = true
}

variable "enable_notifications" {
  type        = bool
  description = "Habilitar notificaciones de sincronización"
  default     = true
}

variable "notification_slack_webhook" {
  type        = string
  description = "Webhook de Slack para notificaciones"
  default     = ""
  sensitive   = true
}

variable "notification_slack_channel" {
  type        = string
  description = "Canal de Slack para notificaciones"
  default     = "#devops"
}

variable "enable_monitoring" {
  type        = bool
  description = "Integrar OCI Monitoring"
  default     = true
}

variable "enable_auto_sync" {
  type        = bool
  description = "Habilitar sincronización automática"
  default     = true
}

variable "sync_interval" {
  type        = number
  description = "Intervalo de sincronización en segundos"
  default     = 180
}

variable "enable_self_heal" {
  type        = bool
  description = "Habilitar auto-healing (reconciliación continua)"
  default     = true
}

variable "enable_rbac" {
  type        = bool
  description = "Habilitar RBAC en ArgoCD"
  default     = true
}

variable "argocd_admin_password" {
  type        = string
  description = "Contraseña inicial para admin de ArgoCD (dejar vacío para generar)"
  default     = ""
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags para aplicar a todos los recursos"
  default = {
    Architecture = "GitOps-ArgoCD"
    Terraform    = "true"
    Purpose      = "Continuous-Deployment"
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

variable "helm_chart_version" {
  type        = string
  description = "Versión del Helm chart de ArgoCD"
  default     = "6.0.0"
}

variable "replica_count" {
  type        = number
  description = "Número de réplicas de ArgoCD Server"
  default     = 1
  validation {
    condition     = var.replica_count >= 1 && var.replica_count <= 5
    error_message = "El número de réplicas debe estar entre 1 y 5."
  }
}

variable "enable_ha" {
  type        = bool
  description = "Habilitar alta disponibilidad para ArgoCD"
  default     = false
}
