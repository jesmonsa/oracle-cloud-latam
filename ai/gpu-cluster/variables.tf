variable "region" {
  description = "Región de OCI"
  type        = string
  default     = "us-phoenix-1"
}

variable "compartment_id" {
  description = "OCID del compartment"
  type        = string
}

variable "tenancy_id" {
  description = "OCID del tenancy"
  type        = string
}

variable "oci_profile" {
  description = "Perfil OCI CLI"
  type        = string
  default     = "DEFAULT"
}

variable "environment" {
  description = "Ambiente"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{1,20}$", var.project_name))
    error_message = "project_name debe contener solo letras minúsculas, números y guiones."
  }
}

# Cluster Configuration
variable "cluster_name" {
  description = "Nombre del cluster GPU"
  type        = string
  default     = "ml-training-cluster"
}

variable "num_gpu_nodes" {
  description = "Número de nodos GPU"
  type        = number
  default     = 2
  validation {
    condition     = var.num_gpu_nodes >= 1 && var.num_gpu_nodes <= 32
    error_message = "num_gpu_nodes debe estar entre 1 y 32."
  }
}

variable "gpu_shape" {
  description = "GPU shape para compute nodes"
  type        = string
  default     = "VM.GPU.A100.2"
  validation {
    condition = contains([
      "VM.GPU.A10.1",
      "VM.GPU.A10.2",
      "VM.GPU.A100.1",
      "VM.GPU.A100.2",
      "VM.GPU.V100.1",
      "BM.GPU.A100"
    ], var.gpu_shape)
    error_message = "GPU shape no válida."
  }
}

# Master Node
variable "master_shape" {
  description = "Shape para nodo master"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "master_ocpus" {
  description = "OCPUs para master node"
  type        = number
  default     = 8
  validation {
    condition     = var.master_ocpus >= 4 && var.master_ocpus <= 64
    error_message = "master_ocpus debe estar entre 4 y 64."
  }
}

variable "master_memory_gbs" {
  description = "Memoria en GB para master node"
  type        = number
  default     = 64
  validation {
    condition     = var.master_memory_gbs >= 16 && var.master_memory_gbs <= 256
    error_message = "master_memory_gbs debe estar entre 16 y 256 GB."
  }
}

# FSS Configuration
variable "filesystem_size_gb" {
  description = "Tamaño del file system en GB"
  type        = number
  default     = 1000
  validation {
    condition     = var.filesystem_size_gb >= 100 && var.filesystem_size_gb <= 8192
    error_message = "filesystem_size_gb debe estar entre 100 y 8192 GB."
  }
}

variable "enable_snapshots" {
  description = "Habilitar snapshots automáticos"
  type        = bool
  default     = true
}

variable "snapshot_schedule" {
  description = "Frecuencia de snapshots"
  type        = string
  default     = "daily"
  validation {
    condition     = contains(["daily", "weekly", "monthly"], var.snapshot_schedule)
    error_message = "snapshot_schedule debe ser daily, weekly o monthly."
  }
}

# SLURM Configuration
variable "enable_slurm" {
  description = "Instalar y configurar SLURM"
  type        = bool
  default     = true
}

variable "max_job_time_minutes" {
  description = "Tiempo máximo de job en minutos"
  type        = number
  default     = 360  # 6 horas
}

variable "enable_job_history" {
  description = "Guardar historial de jobs"
  type        = bool
  default     = true
}

# Networking
variable "enable_rdma" {
  description = "Habilitar RDMA networking"
  type        = bool
  default     = true
}

variable "rdma_network_type" {
  description = "Tipo de red RDMA"
  type        = string
  default     = "ib200"
  validation {
    condition     = contains(["ib100", "ib200"], var.rdma_network_type)
    error_message = "rdma_network_type debe ser ib100 o ib200."
  }
}

# Monitoring
variable "enable_monitoring" {
  description = "Habilitar monitoring"
  type        = bool
  default     = true
}

variable "enable_dcgm_exporter" {
  description = "Habilitar NVIDIA DCGM exporter"
  type        = bool
  default     = true
}

variable "grafana_enabled" {
  description = "Habilitar Grafana"
  type        = bool
  default     = true
}

variable "monitoring_retention_days" {
  description = "Días de retención de métricas"
  type        = number
  default     = 30
}

# VCN Configuration
variable "create_vcn" {
  description = "Crear nueva VCN"
  type        = bool
  default     = true
}

variable "vcn_cidr_blocks" {
  description = "CIDR blocks para VCN"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "existing_vcn_id" {
  description = "OCID de VCN existente"
  type        = string
  default     = null
}

# Tags
variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default = {
    "Environment" = "dev"
    "Service"     = "gpu-cluster"
    "Team"        = "ml-team"
  }
}
