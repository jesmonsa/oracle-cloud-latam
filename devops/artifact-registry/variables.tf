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

variable "artifact_namespace" {
  type        = string
  description = "Namespace para Artifact Registry (ej: my-company)"
}

variable "create_maven_repos" {
  type        = bool
  description = "Crear repositorios Maven (releases, snapshots)"
  default     = true
}

variable "create_npm_repos" {
  type        = bool
  description = "Crear repositorios NPM"
  default     = true
}

variable "container_image_names" {
  type        = list(string)
  description = "Nombres de imágenes de contenedores a crear"
  default     = ["backend", "frontend", "api"]
}

variable "enable_image_scanning" {
  type        = bool
  description = "Habilitar scans automáticos de vulnerabilidades"
  default     = true
}

variable "enable_replication" {
  type        = bool
  description = "Habilitar replicación a otra región"
  default     = false
}

variable "replication_region" {
  type        = string
  description = "Región destino para replicación"
  default     = "us-ashburn-1"
}

variable "artifact_retention_days" {
  type        = number
  description = "Días de retención de artefactos (0 = indefinido)"
  default     = 90
}

variable "enable_audit_logging" {
  type        = bool
  description = "Habilitar logging de auditoría"
  default     = true
}

variable "enable_encryption" {
  type        = bool
  description = "Habilitar encriptación de artefactos"
  default     = true
}

variable "kms_key_id" {
  type        = string
  description = "OCID de la clave KMS para encriptación"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags para aplicar a todos los recursos"
  default = {
    Architecture = "Artifact-Registry"
    Terraform    = "true"
  }
}

variable "create_proxy_repos" {
  type        = bool
  description = "Crear repositorios proxy"
  default     = false
}

variable "environment" {
  type        = string
  description = "Ambiente (dev, staging, prod)"
  default     = "dev"
}

variable "enable_notifications" {
  type        = bool
  description = "Habilitar notificaciones de eventos"
  default     = false
}

variable "notification_topic_endpoint" {
  type        = string
  description = "Endpoint para notificaciones"
  default     = ""
  sensitive   = true
}
