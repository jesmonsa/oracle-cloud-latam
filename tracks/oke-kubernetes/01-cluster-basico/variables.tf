# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables — Track OKE Lección 01: Cluster Básico (Flannel CNI)            ║
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
  default = "oke-basico"
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
  description = "CIDR para la subnet del Node Pool (privada)"
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
  description = "Versión de Kubernetes para cluster y node pool"
  type        = string
  default     = "v1.32.1"
}

variable "node_pool_size" {
  description = "Cantidad de worker nodes"
  type        = number
  default     = 2
}

variable "node_shape" {
  description = "Shape de los worker nodes"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "node_ocpus" {
  description = "OCPUs por worker node"
  type        = number
  default     = 1
}

variable "node_memoria_gb" {
  description = "RAM en GB por worker node"
  type        = number
  default     = 8
}

variable "ssh_public_key" {
  description = "Llave pública SSH para acceso a worker nodes"
  type        = string
}
