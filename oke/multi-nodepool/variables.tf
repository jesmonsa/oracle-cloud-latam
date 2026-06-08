# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables — OKE Multi Node Pool                                             ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ============================================================================
# VARIABLES DE TENANCY Y PROVIDER
# ============================================================================

variable "tenancy_ocid" {
  description = "OCID del tenancy de OCI"
  type        = string
  sensitive   = true
}

variable "current_user_ocid" {
  description = "OCID del usuario actual de OCI"
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "Fingerprint de la API key del usuario"
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Ruta a la clave privada de la API key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Región de OCI donde se desplegará la infraestructura"
  type        = string
}

variable "compartment_id" {
  description = "OCID del compartment donde se crearán los recursos"
  type        = string
}

# ============================================================================
# VARIABLES GENERALES
# ============================================================================

variable "proyecto" {
  description = "Nombre del proyecto (prefijo para todos los recursos)"
  type        = string
  default     = "oke-multi"
  validation {
    condition     = length(var.proyecto) <= 20
    error_message = "El nombre del proyecto no puede exceder 20 caracteres."
  }
}

variable "ambiente" {
  description = "Ambiente de despliegue (produccion, staging, desarrollo)"
  type        = string
  default     = "produccion"
  validation {
    condition     = contains(["produccion", "staging", "desarrollo"], var.ambiente)
    error_message = "El ambiente debe ser: produccion, staging o desarrollo."
  }
}

variable "propietario" {
  description = "Propietario del proyecto (correo o nombre)"
  type        = string
}

variable "equipo_responsable" {
  description = "Equipo responsable de la infraestructura"
  type        = string
  default     = "DevOps"
}

# ============================================================================
# VARIABLES DE RED (VCN)
# ============================================================================

variable "vcn_cidr" {
  description = "CIDR de la VCN principal"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vcn_cidr))
    error_message = "El CIDR debe tener un formato válido (ej: 10.0.0.0/16)"
  }
}

variable "subnet_api_cidr" {
  description = "CIDR de la subred para API de Kubernetes"
  type        = string
  default     = "10.0.1.0/24"
  validation {
    condition     = can(cidrnetmask(var.subnet_api_cidr))
    error_message = "El CIDR debe tener un formato válido (ej: 10.0.1.0/24)"
  }
}

variable "subnet_lb_cidr" {
  description = "CIDR de la subred para Load Balancers"
  type        = string
  default     = "10.0.2.0/24"
  validation {
    condition     = can(cidrnetmask(var.subnet_lb_cidr))
    error_message = "El CIDR debe tener un formato válido (ej: 10.0.2.0/24)"
  }
}

variable "subnet_nodepool_cidr" {
  description = "CIDR de la subred para los node pools"
  type        = string
  default     = "10.0.3.0/23"
  validation {
    condition     = can(cidrnetmask(var.subnet_nodepool_cidr))
    error_message = "El CIDR debe tener un formato válido (ej: 10.0.3.0/23)"
  }
}

variable "pods_cidr" {
  description = "CIDR de Kubernetes para los PODs (CNI)"
  type        = string
  default     = "10.244.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.pods_cidr))
    error_message = "El CIDR debe tener un formato válido (ej: 10.244.0.0/16)"
  }
}

variable "services_cidr" {
  description = "CIDR de Kubernetes para los servicios"
  type        = string
  default     = "10.96.0.0/12"
  validation {
    condition     = can(cidrnetmask(var.services_cidr))
    error_message = "El CIDR debe tener un formato válido (ej: 10.96.0.0/12)"
  }
}

# ============================================================================
# VARIABLES DE KUBERNETES
# ============================================================================

variable "kubernetes_version" {
  description = "Versión de Kubernetes a desplegar"
  type        = string
  default     = "v1.32.1"
}

variable "cluster_name" {
  description = "Nombre del cluster de Kubernetes"
  type        = string
  default     = ""
}

# ============================================================================
# VARIABLES DEL NODE POOL x86 (E4 Flex)
# ============================================================================

variable "np_x86_shape" {
  description = "Shape de instancia para el node pool x86"
  type        = string
  default     = "VM.Standard.E4.Flex"
  validation {
    condition     = startswith(var.np_x86_shape, "VM.")
    error_message = "El shape debe ser válido en OCI (ej: VM.Standard.E4.Flex)"
  }
}

variable "np_x86_ocpus" {
  description = "Número de OCPUs para el node pool x86"
  type        = number
  default     = 1
  validation {
    condition     = var.np_x86_ocpus > 0 && var.np_x86_ocpus <= 128
    error_message = "Las OCPUs deben estar entre 1 y 128."
  }
}

variable "np_x86_memoria_gb" {
  description = "Memoria en GB para el node pool x86"
  type        = number
  default     = 8
  validation {
    condition     = var.np_x86_memoria_gb > 0 && var.np_x86_memoria_gb <= 1024
    error_message = "La memoria debe estar entre 1 GB y 1024 GB."
  }
}

variable "np_x86_size" {
  description = "Número de nodos en el node pool x86"
  type        = number
  default     = 1
  validation {
    condition     = var.np_x86_size >= 1 && var.np_x86_size <= 1000
    error_message = "El tamaño debe estar entre 1 y 1000 nodos."
  }
}

# ============================================================================
# VARIABLES DEL NODE POOL ARM (A1 Flex)
# ============================================================================

variable "np_arm_shape" {
  description = "Shape de instancia para el node pool ARM"
  type        = string
  default     = "VM.Standard.A1.Flex"
  validation {
    condition     = startswith(var.np_arm_shape, "VM.")
    error_message = "El shape debe ser válido en OCI (ej: VM.Standard.A1.Flex)"
  }
}

variable "np_arm_ocpus" {
  description = "Número de OCPUs para el node pool ARM"
  type        = number
  default     = 1
  validation {
    condition     = var.np_arm_ocpus > 0 && var.np_arm_ocpus <= 128
    error_message = "Las OCPUs deben estar entre 1 y 128."
  }
}

variable "np_arm_memoria_gb" {
  description = "Memoria en GB para el node pool ARM"
  type        = number
  default     = 6
  validation {
    condition     = var.np_arm_memoria_gb > 0 && var.np_arm_memoria_gb <= 1024
    error_message = "La memoria debe estar entre 1 GB y 1024 GB."
  }
}

variable "np_arm_size" {
  description = "Número de nodos en el node pool ARM"
  type        = number
  default     = 1
  validation {
    condition     = var.np_arm_size >= 1 && var.np_arm_size <= 1000
    error_message = "El tamaño debe estar entre 1 y 1000 nodos."
  }
}

# ============================================================================
# SSH
# ============================================================================

variable "ssh_public_key" {
  description = "Llave pública SSH para acceso a los worker nodes (debug/troubleshooting)"
  type        = string
}

# ============================================================================
# VARIABLES DE TAGS EMPRESARIALES
# ============================================================================

variable "tags_empresariales" {
  description = "Tags empresariales para cumplimiento y gobernanza"
  type        = map(string)
  default = {
    Arquitectura = "oke-multi-nodepool"
    ManagedBy    = "Terraform"
  }
}
