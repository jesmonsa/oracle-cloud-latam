# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  PERSISTENT VOLUMES - FILE STORAGE SERVICE - VARIABLES                       ║
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
  default     = "oke-file-storage"
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
  default     = "10.3.0.0/16"
}

variable "k8s_subnet_cidr" {
  description = "Bloque CIDR de la subred de Kubernetes"
  type        = string
  default     = "10.3.1.0/24"
}

variable "worker_subnet_cidr" {
  description = "Bloque CIDR de la subred de nodos de trabajo"
  type        = string
  default     = "10.3.2.0/24"
}

variable "fss_subnet_cidr" {
  description = "Bloque CIDR de la subred para FSS"
  type        = string
  default     = "10.3.3.0/24"
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
# VARIABLES DE FILE STORAGE SERVICE (FSS)
# ==============================================================================

variable "fss_availability_domain" {
  description = "Dominio de disponibilidad para FSS (ej: ChKb:SA-SANTIAGO-1-AD-1)"
  type        = string
  default     = ""  # Auto-detectar si está vacío
}

variable "export_path" {
  description = "Ruta de exportación NFS (ej: /exportfs)"
  type        = string
  default     = "/exportfs"
  validation {
    condition     = startswith(var.export_path, "/")
    error_message = "Debe comenzar con /"
  }
}

variable "mount_target_subnet_id" {
  description = "ID de la subred donde se crea el Mount Target"
  type        = string
  default     = ""  # Se crea automáticamente si está vacío
}

variable "create_mount_target" {
  description = "Crear Mount Target automáticamente"
  type        = bool
  default     = true
}

variable "nfs_version" {
  description = "Versión de NFS (NFSv3 o NFSv4.1)"
  type        = string
  default     = "NFSv3"
  validation {
    condition     = contains(["NFSv3", "NFSv4.1"], var.nfs_version)
    error_message = "Debe ser NFSv3 o NFSv4.1"
  }
}

variable "enable_kerberos" {
  description = "Habilitar Kerberos para seguridad NFS"
  type        = bool
  default     = false
}

variable "storage_class_name" {
  description = "Nombre de la StorageClass en Kubernetes"
  type        = string
  default     = "oci-fss"
}

variable "fss_provisioner_version" {
  description = "Versión del provisioner de FSS"
  type        = string
  default     = "1.3.0"
}

# ==============================================================================
# VARIABLES DE PERFORMANCE Y CAPACIDAD
# ==============================================================================

variable "fss_initial_size_gb" {
  description = "Tamaño inicial de FSS en GB"
  type        = number
  default     = 100
  validation {
    condition     = var.fss_initial_size_gb >= 100 && var.fss_initial_size_gb <= 8388608
    error_message = "Debe estar entre 100 y 8388608 GB"
  }
}

variable "enable_auto_expansion" {
  description = "Expandir FSS automáticamente cuando se alcance 80% de uso"
  type        = bool
  default     = true
}

variable "auto_expansion_size_gb" {
  description = "Tamaño a incrementar en auto-expansión"
  type        = number
  default     = 50
  validation {
    condition     = var.auto_expansion_size_gb >= 50 && var.auto_expansion_size_gb <= 1024
    error_message = "Debe estar entre 50 y 1024 GB"
  }
}

variable "max_fss_size_gb" {
  description = "Tamaño máximo de FSS para auto-expansion"
  type        = number
  default     = 500
  validation {
    condition     = var.max_fss_size_gb >= 100 && var.max_fss_size_gb <= 8388608
    error_message = "Debe estar entre 100 y 8388608 GB"
  }
}

# ==============================================================================
# VARIABLES DE SEGURIDAD Y ACCESO
# ==============================================================================

variable "enable_network_security_group" {
  description = "Crear Network Security Group para FSS"
  type        = bool
  default     = true
}

variable "nfs_port" {
  description = "Puerto NFS (típicamente 2049)"
  type        = number
  default     = 2049
  validation {
    condition     = var.nfs_port >= 1024 && var.nfs_port <= 65535
    error_message = "Debe estar entre 1024 y 65535"
  }
}

variable "mountd_port" {
  description = "Puerto mountd (típicamente 111)"
  type        = number
  default     = 111
  validation {
    condition     = var.mountd_port >= 1024 && var.mountd_port <= 65535
    error_message = "Debe estar entre 1024 y 65535"
  }
}

variable "restricted_client_cidr_list" {
  description = "CIDR list de clientes permitidos (vacío = todos)"
  type        = list(string)
  default     = []
}

# ==============================================================================
# VARIABLES DE BACKUPS Y SNAPSHOTS
# ==============================================================================

variable "enable_fss_snapshots" {
  description = "Habilitar snapshots de FSS"
  type        = bool
  default     = true
}

variable "snapshot_policy" {
  description = "Política de snapshots (hourly, daily, weekly)"
  type        = string
  default     = "daily"
  validation {
    condition     = contains(["hourly", "daily", "weekly"], var.snapshot_policy)
    error_message = "Debe ser 'hourly', 'daily' o 'weekly'"
  }
}

variable "retention_days" {
  description = "Días de retención de snapshots"
  type        = number
  default     = 30
  validation {
    condition     = var.retention_days >= 7 && var.retention_days <= 365
    error_message = "Debe estar entre 7 y 365 días"
  }
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
  default     = "oke-file-storage"
}

variable "tags" {
  description = "Etiquetas de recursos"
  type        = map(string)
  default = {
    Architecture = "OKE-FSS-Shared"
    Managed      = "Terraform"
    Purpose      = "Shared-Persistent-Storage"
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

variable "iam_enabled" {
  description = "Habilitar IAM para controlar acceso a FSS"
  type        = bool
  default     = true
}

variable "read_only_export" {
  description = "Exportar como read-only"
  type        = bool
  default     = false
}

variable "allow_anonymous_access" {
  description = "Permitir acceso anónimo (uid 65534)"
  type        = bool
  default     = false
}
