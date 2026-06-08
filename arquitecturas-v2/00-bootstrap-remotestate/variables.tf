# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables - Bootstrap Remote State                                         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Autenticación OCI ───────────────────────────────────────────────────────
variable "tenancy_ocid" {
  description = "OCID del tenancy"
  type        = string
}

variable "current_user_ocid" {
  description = "OCID del usuario que ejecuta Terraform"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint de la API key del usuario"
  type        = string
}

variable "private_key_path" {
  description = "Ruta al archivo PEM de la API key"
  type        = string
}

variable "region" {
  description = "Región OCI (ej: us-ashburn-1)"
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_ocid" {
  description = "OCID del compartment donde crear el bucket (por defecto = tenancy root)"
  type        = string
  default     = ""
}

# ─── Configuración del Bucket ────────────────────────────────────────────────
variable "bucket_name" {
  description = "Nombre del bucket para almacenar los archivos tfstate"
  type        = string
  default     = "tf-state-latam"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,62}[a-z0-9]$", var.bucket_name))
    error_message = "El nombre del bucket debe tener entre 3 y 63 caracteres, solo minúsculas, números, puntos y guiones."
  }
}

variable "proyecto" {
  description = "Nombre del proyecto (para tags)"
  type        = string
  default     = "oracle-cloud-latam"
}
