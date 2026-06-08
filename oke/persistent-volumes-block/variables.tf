# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  PERSISTENT VOLUMES - BLOCK STORAGE - VARIABLES                              ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# VARIABLES DE AUTENTICACIÓN Y TENENCIA
# ==============================================================================

variable "tenancy_ocid" {
  description = "OCID de la tenencia de Oracle Cloud"
  type        = string
  sensitive   = true
}

variable "current_user_ocid" {
  description = "OCID del usuario actual"
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "Fingerprint de la clave pública API"
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Ruta a la clave privada API"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Región de Oracle Cloud"
  type        = string
  default     = "sa-santiago-1"
}

# ==============================================================================
# VARIABLES DE CONFIGURACIÓN DEL CLÚST ER OKE
# ==============================================================================

variable "cluster_name" {
  description = "Nombre del clúster OKE"
  type        = string
  default     = "oke-block-storage"
}

variable "cluster_version" {
  description = "Versión de Kubernetes"
  type        = string
  default     = "1.29"
}

variable "compartment_id" {
  description = "OCID del compartimiento"
  type        = string
}

variable "vcn_cidr_block" {
  description = "Bloque CIDR de la VCN"
  type        = string
  default     = "10.2.0.0/16"
}

variable "k8s_subnet_cidr" {
  description = "Bloque CIDR de la subred de Kubernetes"
  type        = string
  default     = "10.2.1.0/24"
}

variable "worker_subnet_cidr" {
  description = "Bloque CIDR de la subred de nodos de trabajo"
  type        = string
  default     = "10.2.2.0/24"
}

variable "node_pool_size" {
  description = "Cantidad de nodos en el pool"
  type        = number
  default     = 3
}

variable "node_shape" {
  description = "Forma de los nodos"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "node_ocpus" {
  description = "Cantidad de OCPUs por nodo"
  type        = number
  default     = 2
}

variable "node_memory_gb" {
  description = "Memoria RAM en GB por nodo"
  type        = number
  default     = 8
}

# ==============================================================================
# VARIABLES DE BLOCK VOLUME STORAGE
# ==============================================================================

variable "storage_size_gb" {
  description = "Tamaño de los volúmenes en GB"
  type        = number
  default     = 100
  validation {
    condition     = var.storage_size_gb >= 50 && var.storage_size_gb <= 16384
    error_message = "Debe estar entre 50 y 16384 GB"
  }
}

variable "vpus_per_gb" {
  description = "VPUs por GB (performance level: 10, 20, 30, 40, 60)"
  type        = number
  default     = 10
  validation {
    condition     = contains([10, 20, 30, 40, 60], var.vpus_per_gb)
    error_message = "Debe ser 10, 20, 30, 40 o 60 VPUs por GB"
  }
}

variable "storage_class_name" {
  description = "Nombre de la StorageClass en Kubernetes"
  type        = string
  default     = "oci-bv-standard"
}

variable "enable_cross_ad_replication" {
  description = "Habilitar replicación entre zonas de disponibilidad"
  type        = bool
  default     = true
}

variable "backup_enabled" {
  description = "Habilitar backups automáticos de volúmenes"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Días de retención de backups"
  type        = number
  default     = 30
  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 365
    error_message = "Debe estar entre 7 y 365 días"
  }
}

variable "backup_schedule" {
  description = "Cronograma de backups (diario/semanal/mensual)"
  type        = string
  default     = "diario"
  validation {
    condition     = contains(["diario", "semanal", "mensual"], var.backup_schedule)
    error_message = "Debe ser 'diario', 'semanal' o 'mensual'"
  }
}

variable "enable_volume_snapshots" {
  description = "Habilitar snapshots de volúmenes"
  type        = bool
  default     = true
}

variable "enable_csi_driver" {
  description = "Instalar CSI driver de OCI Block Volume"
  type        = bool
  default     = true
}

variable "csi_driver_version" {
  description = "Versión del CSI driver de OCI"
  type        = string
  default     = "1.24.0"
}

# ==============================================================================
# VARIABLES DE DISASTER RECOVERY
# ==============================================================================

variable "enable_disaster_recovery" {
  description = "Habilitar configuración de disaster recovery"
  type        = bool
  default     = false
}

variable "disaster_recovery_region" {
  description = "Región secundaria para DR"
  type        = string
  default     = "sa-vinhedo-1"
}

variable "enable_volume_cloning" {
  description = "Habilitar clonación rápida de volúmenes"
  type        = bool
  default     = true
}

# ==============================================================================
# VARIABLES DE ETIQUETADO Y NOMENCLATURA
# ==============================================================================

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Nombre del proyecto para etiquetado"
  type        = string
  default     = "oke-block-storage"
}

variable "tags" {
  description = "Etiquetas de recursos"
  type        = map(string)
  default = {
    Architecture = "OKE-BlockStorage-CSI"
    Managed      = "Terraform"
    Purpose      = "High-Performance-Persistent-Storage"
  }
}

# ==============================================================================
# VARIABLES OPCIONALES AVANZADAS
# ==============================================================================

variable "enable_monitoring" {
  description = "Habilitar monitoreo con OCI Monitoring"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Habilitar logging con OCI Logging"
  type        = bool
  default     = true
}

variable "volume_encryption_key_id" {
  description = "OCID de la clave de encriptación personalizada"
  type        = string
  default     = null
}

variable "enable_volume_encryption" {
  description = "Habilitar encriptación de volúmenes"
  type        = bool
  default     = true
}

variable "standby_replicas_enabled" {
  description = "Habilitar réplicas standby para DR"
  type        = bool
  default     = false
}

variable "storage_reservation_gb" {
  description = "Reserva de storage para operaciones de admin"
  type        = number
  default     = 10
  validation {
    condition     = var.storage_reservation_gb >= 5 && var.storage_reservation_gb <= 100
    error_message = "Debe estar entre 5 y 100 GB"
  }
}
