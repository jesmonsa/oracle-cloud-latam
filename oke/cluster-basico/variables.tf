# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables — OKE Cluster Básico — Arquitectura de Referencia                ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Autenticación OCI ─────────────────────────────────────────────────────────

variable "tenancy_ocid" {
  description = "OCID del tenancy de Oracle Cloud"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID del compartment de destino para los recursos"
  type        = string
}

variable "current_user_ocid" {
  description = "OCID del usuario actual para autenticación"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint de la clave API OCI"
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Ruta a la clave privada OCI en el sistema local"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Región de Oracle Cloud Infrastructure para el despliegue"
  type        = string
  default     = "us-ashburn-1"
}

# ─── Identificación y Tags Empresariales ──────────────────────────────────────

variable "proyecto" {
  description = "Nombre del proyecto — prefijo para todos los recursos (minúsculas, máx 12 caracteres)"
  type        = string
  default     = "oke-basico"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,11}$", var.proyecto))
    error_message = "proyecto: solo minúsculas, números o guiones, máximo 12 caracteres."
  }
}

variable "ambiente" {
  description = "Ambiente de despliegue (desarrollo, staging, produccion)"
  type        = string
  default     = "desarrollo"
  validation {
    condition     = contains(["desarrollo", "staging", "produccion"], var.ambiente)
    error_message = "ambiente debe ser: desarrollo, staging o produccion."
  }
}

variable "propietario" {
  description = "E-mail o nombre del propietario/responsable del cluster"
  type        = string
  default     = "admin"
}

# ─── Configuración de Red (VCN y Subnets) ─────────────────────────────────────

variable "vcn_cidr" {
  description = "Bloque CIDR de la red virtual (VCN)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_api_cidr" {
  description = "CIDR para la subnet del API Endpoint — pública, acceso desde kubectl"
  type        = string
  default     = "10.0.0.0/28"
}

variable "subnet_lb_cidr" {
  description = "CIDR para la subnet del Load Balancer — pública, servicios K8s tipo LoadBalancer"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_nodepool_cidr" {
  description = "CIDR para la subnet del Node Pool — privada, worker nodes de Kubernetes"
  type        = string
  default     = "10.0.10.0/24"
}

# ─── Configuración de Kubernetes (Cluster y Node Pool) ────────────────────────

variable "k8s_version" {
  description = "Versión de Kubernetes para cluster y node pool"
  type        = string
  default     = "v1.32.1"
}

variable "node_pool_size" {
  description = "Cantidad de worker nodes en el pool (recomendado >= 2 para HA)"
  type        = number
  default     = 2
  validation {
    condition     = var.node_pool_size >= 1 && var.node_pool_size <= 10
    error_message = "node_pool_size debe estar entre 1 y 10."
  }
}

variable "node_shape" {
  description = "Shape de instancia para los worker nodes (e.g. VM.Standard.E4.Flex, VM.Standard.A1.Flex, VM.Standard.X9.Flex)"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "node_ocpus" {
  description = "Número de OCPUs por worker node en shape Flex"
  type        = number
  default     = 1
  validation {
    condition     = var.node_ocpus >= 1 && var.node_ocpus <= 128
    error_message = "node_ocpus debe estar entre 1 y 128."
  }
}

variable "node_memoria_gb" {
  description = "RAM en GB por worker node en shape Flex"
  type        = number
  default     = 8
  validation {
    condition     = var.node_memoria_gb >= 1 && var.node_memoria_gb <= 1024
    error_message = "node_memoria_gb debe estar entre 1 y 1024."
  }
}

variable "ssh_public_key" {
  description = "Clave pública SSH para acceso a los worker nodes (debug y administración)"
  type        = string
  sensitive   = true
}

# ─── Configuración de Red Interna (Flannel CNI) ────────────────────────────────

variable "pods_cidr" {
  description = "Bloque CIDR para pods — no debe solaparse con la VCN"
  type        = string
  default     = "10.244.0.0/16"
}

variable "services_cidr" {
  description = "Bloque CIDR para Kubernetes Services (ClusterIP)"
  type        = string
  default     = "10.96.0.0/16"
}
