# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables — Arquitectura 16: Vault + Baselines                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

variable "tenancy_ocid" {
  type = string
}

variable "compartment_ocid" {
  type = string
}

variable "current_user_ocid" {
  type = string
}

variable "fingerprint" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "region" {
  type    = string
  default = "us-ashburn-1"
}

variable "proyecto" {
  type    = string
  default = "vault"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,11}$", var.proyecto))
    error_message = "proyecto: solo minúsculas, números o guiones, máx 12 caracteres."
  }
}

variable "ambiente" {
  type    = string
  default = "desarrollo"
}

variable "propietario" {
  type    = string
  default = "admin"
}

variable "vcn_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_privada_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "email_notificacion" {
  type    = string
  default = "admin@example.com"
}
