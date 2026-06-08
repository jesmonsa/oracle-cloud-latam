# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables de Terraform - OKE Virtual Nodes                                  ║
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
# │ VARIABLES DE CONFIGURACIÓN OKE (ENHANCED)                                   │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "cluster_name" {
  description = "Nombre del cluster OKE Enhanced"
  type        = string
  default     = "oke-virtual-nodes-cluster"
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

variable "cluster_type" {
  description = "Tipo de cluster (debe ser ENHANCED para Virtual Nodes)"
  type        = string
  default     = "ENHANCED"
  validation {
    condition     = var.cluster_type == "ENHANCED"
    error_message = "Virtual Nodes requiere cluster tipo ENHANCED."
  }
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE VIRTUAL NODE POOL                                              │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "virtual_node_pool_name" {
  description = "Nombre del virtual node pool"
  type        = string
  default     = "pool-virtual-nodes"
}

variable "virtual_node_count" {
  description = "Número de pods que ejecutar simultáneamente (Virtual Nodes)"
  type        = number
  default     = 10
  validation {
    condition     = var.virtual_node_count >= 1 && var.virtual_node_count <= 1000
    error_message = "El número de pods virtuales debe estar entre 1 y 1000."
  }
}

variable "pod_shape" {
  description = "Shape para pods virtuales (E4 o E3 Flex)"
  type        = string
  default     = "Pod.Standard.E4.Flex"
  validation {
    condition     = contains(["Pod.Standard.E4.Flex", "Pod.Standard.E3.Flex"], var.pod_shape)
    error_message = "El shape debe ser Pod.Standard.E4.Flex o Pod.Standard.E3.Flex."
  }
}

variable "pod_ocpus" {
  description = "Número de OCPUs por pod (Virtual Node)"
  type        = number
  default     = 1
  validation {
    condition     = var.pod_ocpus >= 0.1 && var.pod_ocpus <= 64
    error_message = "Los OCPUs por pod deben estar entre 0.1 y 64."
  }
}

variable "pod_memory_gb" {
  description = "Memoria en GB por pod (Virtual Node)"
  type        = number
  default     = 4
  validation {
    condition     = var.pod_memory_gb >= 0.5 && var.pod_memory_gb <= 1024
    error_message = "La memoria por pod debe estar entre 0.5 y 1024 GB."
  }
}

variable "enable_pod_eviction_policy" {
  description = "Habilitar política de evicción de pods"
  type        = bool
  default     = true
}

variable "pod_eviction_grace_duration_seconds" {
  description = "Tiempo de gracia en segundos antes de evictar un pod"
  type        = number
  default     = 30
  validation {
    condition     = var.pod_eviction_grace_duration_seconds >= 0 && var.pod_eviction_grace_duration_seconds <= 3600
    error_message = "La duración debe estar entre 0 y 3600 segundos."
  }
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE CONFIGURACIÓN VCN                                              │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "vcn_name" {
  description = "Nombre de la VCN"
  type        = string
  default     = "vcn-oke-virtual-nodes"
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
# │ VARIABLES DE CONTAINER INSTANCES (BACKEND)                                  │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "container_instances_compartment_id" {
  description = "OCID del compartment para Container Instances"
  type        = string
  sensitive   = true
}

variable "enable_container_logging" {
  description = "Habilitar logging de Container Instances"
  type        = bool
  default     = true
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE NAMESPACES Y SEGURIDAD                                         │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "system_namespace" {
  description = "Namespace del sistema (obligatorio para Virtual Nodes)"
  type        = string
  default     = "kube-system"
}

variable "app_namespace" {
  description = "Namespace para aplicaciones con Virtual Nodes"
  type        = string
  default     = "virtual-workloads"
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.app_namespace))
    error_message = "El nombre del namespace debe cumplir con las reglas de DNS."
  }
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE TOLERANCIAS Y AFINIDAD                                         │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "virtual_node_taint_key" {
  description = "Clave del taint para Virtual Nodes"
  type        = string
  default     = "virtual-node"
}

variable "virtual_node_taint_value" {
  description = "Valor del taint para Virtual Nodes"
  type        = string
  default     = "true"
}

variable "apply_virtual_node_taint" {
  description = "Aplicar taint automático a Virtual Nodes"
  type        = bool
  default     = true
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE ETIQUETADO Y METADATOS                                         │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "tags" {
  description = "Etiquetas aplicadas a todos los recursos"
  type        = map(string)
  default = {
    ManagedBy    = "Terraform"
    Proyecto     = "OKE-VirtualNodes"
    Ambiente     = "Producción"
    VersionArq   = "1.0"
    Serverless   = "true"
  }
}

variable "freeform_tags" {
  description = "Tags de forma libre para clasificación"
  type        = map(string)
  default = {
    FinanceCenter = "Engineering"
    CostCenter    = "Serverless"
    Compliance    = "ISO27001"
    Type          = "Virtual"
  }
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE MONITOREO Y ESCALADO                                           │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "enable_monitoring" {
  description = "Habilitar monitoreo de OCI"
  type        = bool
  default     = true
}

variable "monitoring_namespace" {
  description = "Namespace para monitoring"
  type        = string
  default     = "monitoring"
}
