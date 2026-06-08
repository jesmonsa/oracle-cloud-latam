# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables — Arquitectura 13: OKE (Kubernetes)                             ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

variable "tenancy_ocid"      { type = string }
variable "compartment_ocid"  { type = string }
variable "current_user_ocid" { type = string }
variable "fingerprint"       { type = string }
variable "private_key_path"  { type = string }

variable "region" {
  type    = string
  default = "us-ashburn-1"
}

variable "proyecto" {
  type    = string
  default = "oke"
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

# ─── Red ──────────────────────────────────────────────────────────────────────
variable "vcn_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_api_cidr" {
  type    = string
  default = "10.0.0.0/28"
}

variable "subnet_lb_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "subnet_nodepool_cidr" {
  type    = string
  default = "10.0.10.0/24"
}

variable "pods_cidr" {
  type    = string
  default = "10.244.0.0/16"
}

variable "services_cidr" {
  type    = string
  default = "10.96.0.0/16"
}

# ─── Kubernetes ───────────────────────────────────────────────────────────────
variable "k8s_version" {
  description = "Versión de Kubernetes"
  type        = string
  default     = "v1.31.1"
}

variable "node_pool_size" {
  description = "Número de worker nodes"
  type        = number
  default     = 1
}

variable "node_shape" {
  description = "Shape Flex para worker nodes OKE. Compatible: VM.Standard.E4.Flex, VM.Standard.E5.Flex, VM.Standard.A1.Flex (ARM), VM.Optimized3.Flex"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "node_ocpus" {
  type    = number
  default = 1
}

variable "node_memoria_gb" {
  type    = number
  default = 8
}

variable "ssh_public_key" {
  description = "Llave pública SSH para los worker nodes"
  type        = string
}
