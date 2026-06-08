# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables de Terraform - OKE con OCIR Registry                              ║
# ║  Definición centralizada de parámetros configurables                         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE AUTENTICACIÓN OCI                                              │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "tenancy_ocid" {
  description = "OCID del Tenancy de Oracle Cloud Infrastructure"
  type        = string
  sensitive   = true
}

variable "current_user_ocid" {
  description = "OCID del usuario IAM actual"
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "Fingerprint de la clave API del usuario"
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Ruta al archivo de clave privada PEM"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Región de OCI donde desplegar (ej: sa-santiago-1)"
  type        = string
  default     = "sa-santiago-1"
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE CONFIGURACIÓN OKE                                              │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "cluster_name" {
  description = "Nombre del cluster OKE"
  type        = string
  default     = "oke-ocir-cluster"
  validation {
    condition     = length(var.cluster_name) >= 3 && length(var.cluster_name) <= 255
    error_message = "El nombre del cluster debe tener entre 3 y 255 caracteres."
  }
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes a desplegar"
  type        = string
  default     = "v1.29"
}

variable "node_pool_name" {
  description = "Nombre del node pool"
  type        = string
  default     = "pool-standard-ocir"
}

variable "initial_node_count" {
  description = "Número inicial de nodos en el pool"
  type        = number
  default     = 3
  validation {
    condition     = var.initial_node_count >= 1 && var.initial_node_count <= 100
    error_message = "El número de nodos debe estar entre 1 y 100."
  }
}

variable "node_shape" {
  description = "Shape de las instancias de los nodos"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "node_ocpus" {
  description = "Número de OCPUs para nodos Flex"
  type        = number
  default     = 2
  validation {
    condition     = var.node_ocpus >= 1 && var.node_ocpus <= 64
    error_message = "Los OCPUs deben estar entre 1 y 64."
  }
}

variable "node_memory_gb" {
  description = "Memoria en GB para nodos Flex"
  type        = number
  default     = 16
  validation {
    condition     = var.node_memory_gb >= 1 && var.node_memory_gb <= 1024
    error_message = "La memoria debe estar entre 1 y 1024 GB."
  }
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE CONFIGURACIÓN VCN                                              │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "vcn_name" {
  description = "Nombre de la VCN"
  type        = string
  default     = "vcn-oke-ocir"
}

variable "vcn_cidr_block" {
  description = "Bloque CIDR de la VCN"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vcn_cidr_block, 0))
    error_message = "Debe ser un bloque CIDR válido."
  }
}

variable "subnet_cidr_block" {
  description = "Bloque CIDR de la subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE OCIR REGISTRY                                                  │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "registry_namespace" {
  description = "Namespace de OCIR (compartment-based)"
  type        = string
  validation {
    condition     = length(var.registry_namespace) >= 1 && length(var.registry_namespace) <= 255
    error_message = "El namespace debe ser válido."
  }
}

variable "repository_name" {
  description = "Nombre del repositorio en OCIR"
  type        = string
  default     = "mi-aplicacion"
  validation {
    condition     = can(regex("^[a-z0-9/_-]+$", var.repository_name))
    error_message = "El nombre del repositorio solo puede contener minúsculas, números, guiones, barras y guiones bajos."
  }
}

variable "image_compartment_id" {
  description = "OCID del compartment para la imagen"
  type        = string
  sensitive   = true
}

variable "is_public_registry" {
  description = "Si el repositorio debe ser público"
  type        = bool
  default     = false
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE NAMESPACE Y SEGURIDAD                                          │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "kubernetes_namespace" {
  description = "Namespace de Kubernetes para aislamiento"
  type        = string
  default     = "ocir-workloads"
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.kubernetes_namespace))
    error_message = "El nombre del namespace debe cumplir con las reglas de DNS."
  }
}

variable "image_pull_secret_name" {
  description = "Nombre del secret de Kubernetes para pull de imágenes"
  type        = string
  default     = "ocir-pull-secret"
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE ETIQUETADO Y METADATOS                                         │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "tags" {
  description = "Etiquetas aplicadas a todos los recursos"
  type        = map(string)
  default = {
    ManagedBy  = "Terraform"
    Proyecto   = "OKE-OCIR"
    Ambiente   = "Producción"
    VersionArq = "1.0"
  }
}

variable "freeform_tags" {
  description = "Tags de forma libre para clasificación"
  type        = map(string)
  default = {
    FinanceCenter = "Engineering"
    CostCenter    = "DevOps"
    Compliance    = "ISO27001"
  }
}
