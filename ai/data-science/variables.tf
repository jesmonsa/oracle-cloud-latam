variable "region" {
  description = "Región de OCI para desplegar recursos"
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
  description = "Perfil OCI CLI a usar"
  type        = string
  default     = "DEFAULT"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment debe ser dev, staging o prod."
  }
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{1,20}$", var.project_name))
    error_message = "project_name debe contener solo letras minúsculas, números y guiones, máximo 20 caracteres."
  }
}

# Data Science Configuration
variable "data_science_project_name" {
  description = "Nombre del OCI Data Science Project"
  type        = string
  default     = "ml-platform"
}

variable "data_science_description" {
  description = "Descripción del proyecto Data Science"
  type        = string
  default     = "Plataforma integrada de ciencia de datos y machine learning"
}

# Notebook Session Configuration
variable "notebook_enabled" {
  description = "Crear Notebook Session"
  type        = bool
  default     = true
}

variable "notebook_display_name" {
  description = "Nombre de la Notebook Session"
  type        = string
  default     = "Notebook Principal"
}

variable "notebook_shape" {
  description = "Forma (shape) para Notebook - CPU"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "notebook_ocpus" {
  description = "Número de OCPUs para Notebook"
  type        = number
  default     = 4
  validation {
    condition     = var.notebook_ocpus >= 1 && var.notebook_ocpus <= 64
    error_message = "OCPUs debe estar entre 1 y 64."
  }
}

variable "notebook_memory_in_gbs" {
  description = "Memoria en GB para Notebook"
  type        = number
  default     = 32
  validation {
    condition     = var.notebook_memory_in_gbs >= 8 && var.notebook_memory_in_gbs <= 512
    error_message = "Memory debe estar entre 8 y 512 GB."
  }
}

variable "notebook_block_storage_size_in_gbs" {
  description = "Tamaño de storage en GB para Notebook"
  type        = number
  default     = 50
  validation {
    condition     = var.notebook_block_storage_size_in_gbs >= 50 && var.notebook_block_storage_size_in_gbs <= 1024
    error_message = "Storage debe estar entre 50 y 1024 GB."
  }
}

# GPU Notebook (Opcional)
variable "gpu_notebook_enabled" {
  description = "Crear Notebook Session con GPU"
  type        = bool
  default     = false
}

variable "gpu_notebook_display_name" {
  description = "Nombre de Notebook GPU"
  type        = string
  default     = "Notebook GPU"
}

variable "gpu_notebook_shape" {
  description = "GPU Shape para Notebook"
  type        = string
  default     = "VM.GPU.A10.1"
  validation {
    condition     = contains(["VM.GPU.A10.1", "VM.GPU.A10.2", "VM.GPU.A100.1", "VM.GPU.A100.2"], var.gpu_notebook_shape)
    error_message = "GPU shape no válida. Opciones: VM.GPU.A10.1, VM.GPU.A10.2, VM.GPU.A100.1, VM.GPU.A100.2"
  }
}

# Jobs Configuration
variable "job_enabled" {
  description = "Crear Data Science Job"
  type        = bool
  default     = false
}

variable "job_display_name" {
  description = "Nombre del Job"
  type        = string
  default     = "Training Job"
}

variable "job_shape" {
  description = "Forma (shape) para Job"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "job_ocpus" {
  description = "OCPUs para Job"
  type        = number
  default     = 4
}

variable "job_memory_gbs" {
  description = "Memoria en GB para Job"
  type        = number
  default     = 32
}

# Object Storage
variable "object_storage_bucket" {
  description = "Nombre del bucket Object Storage"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{1,30}$", var.object_storage_bucket))
    error_message = "Nombre de bucket inválido."
  }
}

variable "bucket_versioning_enabled" {
  description = "Habilitar versionado en bucket"
  type        = bool
  default     = true
}

# Tags
variable "tags" {
  description = "Tags para todos los recursos"
  type        = map(string)
  default = {
    "Environment" = "dev"
    "Service"     = "data-science"
    "Team"        = "ml-team"
  }
}

# VCN Configuration (si es necesario crear)
variable "create_vcn" {
  description = "Crear nueva VCN para recursos"
  type        = bool
  default     = false
}

variable "vcn_cidr_blocks" {
  description = "CIDR blocks para VCN"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks para subnets"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "existing_vcn_id" {
  description = "OCID de VCN existente"
  type        = string
  default     = null
}

variable "existing_subnet_id" {
  description = "OCID de subnet existente"
  type        = string
  default     = null
}
