# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables — Track OKE Lección 02: Node Pools Flex (E4 x86 + A1 ARM)      ║
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
  default = "oke-flex"
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
  description = "CIDR de la VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_api_cidr" {
  description = "CIDR para la subnet del API Endpoint (pública)"
  type        = string
  default     = "10.0.0.0/28"
}

variable "subnet_lb_cidr" {
  description = "CIDR para la subnet del Load Balancer (pública)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_nodepool_cidr" {
  description = "CIDR para la subnet de Node Pools (privada)"
  type        = string
  default     = "10.0.10.0/24"
}

variable "pods_cidr" {
  description = "CIDR para pods (Flannel overlay)"
  type        = string
  default     = "10.244.0.0/16"
}

variable "services_cidr" {
  description = "CIDR para K8s Services"
  type        = string
  default     = "10.96.0.0/16"
}

# ─── Kubernetes ───────────────────────────────────────────────────────────────

variable "k8s_version" {
  description = "Versión de Kubernetes para cluster y node pools"
  type        = string
  default     = "v1.32.1"
}

# ─── Node Pool 1: E4 Flex (x86) ──────────────────────────────────────────────

variable "np_x86_size" {
  description = "Cantidad de workers x86 (E4 Flex)"
  type        = number
  default     = 1
}

variable "np_x86_shape" {
  description = "Shape para workers x86"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "np_x86_ocpus" {
  description = "OCPUs por worker x86"
  type        = number
  default     = 1
}

variable "np_x86_memoria_gb" {
  description = "RAM en GB por worker x86"
  type        = number
  default     = 8
}

# ─── Node Pool 2: A1 Flex (ARM / Ampere) ───────────────────────────────────

variable "np_arm_size" {
  description = "Cantidad de workers ARM (A1 Flex)"
  type        = number
  default     = 1
}

variable "np_arm_shape" {
  description = "Shape para workers ARM"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "np_arm_ocpus" {
  description = "OCPUs por worker ARM"
  type        = number
  default     = 1
}

variable "np_arm_memoria_gb" {
  description = "RAM en GB por worker ARM"
  type        = number
  default     = 6
}

# ─── SSH ──────────────────────────────────────────────────────────────────────

variable "ssh_public_key" {
  description = "Llave pública SSH para acceso a worker nodes"
  type        = string
}
