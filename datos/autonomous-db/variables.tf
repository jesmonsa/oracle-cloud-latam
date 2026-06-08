variable "region" {
  description = "OCI Region (ej: sa-saopaulo-1, la-mexico-1, ca-montreal-1)"
  type        = string
  default     = "sa-saopaulo-1"
}

variable "compartment_id" {
  description = "Compartment OCID donde se creará la Autonomous Database"
  type        = string
  sensitive   = false
}

variable "project_name" {
  description = "Nombre del proyecto para etiquetado"
  type        = string
  default     = "mi-proyecto"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "El ambiente debe ser: dev, staging, o prod."
  }
}

variable "db_name" {
  description = "Nombre de la Autonomous Database (8 caracteres máximo, sin guiones)"
  type        = string
  default     = "atpdb"
  validation {
    condition     = length(var.db_name) <= 8 && !can(regex("-", var.db_name))
    error_message = "El nombre debe tener máximo 8 caracteres y sin guiones."
  }
}

variable "db_password" {
  description = "Password para el usuario ADMIN (mín 12 caracteres, mayúscula, minúscula, número, especial)"
  type        = string
  sensitive   = true
  validation {
    condition = (
      length(var.db_password) >= 12 &&
      can(regex("[A-Z]", var.db_password)) &&
      can(regex("[a-z]", var.db_password)) &&
      can(regex("[0-9]", var.db_password)) &&
      can(regex("[!@#$%^&*()_+=\\-\\[\\]{};:',.<>?/]", var.db_password))
    )
    error_message = "Password debe tener mín 12 caracteres, mayúscula, minúscula, número y carácter especial."
  }
}

variable "db_workload" {
  description = "Tipo de carga: OLTP (transaccional) o DW (Data Warehouse)"
  type        = string
  default     = "OLTP"
  validation {
    condition     = contains(["OLTP", "DW"], var.db_workload)
    error_message = "Workload debe ser OLTP o DW."
  }
}

variable "ocpu_count" {
  description = "Número de OCPU (1-128). Rango recomendado: 2-16"
  type        = number
  default     = 2
  validation {
    condition     = var.ocpu_count >= 1 && var.ocpu_count <= 128
    error_message = "OCPU debe estar entre 1 y 128."
  }
}

variable "storage_gb" {
  description = "Almacenamiento en GB (mínimo 20, máximo 65536)"
  type        = number
  default     = 20
  validation {
    condition     = var.storage_gb >= 20 && var.storage_gb <= 65536
    error_message = "Storage debe estar entre 20 y 65536 GB."
  }
}

variable "vcn_id" {
  description = "VCN OCID donde se creará el Private Endpoint"
  type        = string
}

variable "subnet_id" {
  description = "Subnet OCID (debe ser privada, sin Internet Gateway)"
  type        = string
}

variable "enable_backup" {
  description = "Habilitar backups automáticos"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Retención de backups en días (1-35)"
  type        = number
  default     = 30
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "Retención debe estar entre 1 y 35 días."
  }
}

variable "enable_monitoring" {
  description = "Habilitar OCI Monitoring y crear alarms"
  type        = bool
  default     = true
}

variable "enable_audit_logging" {
  description = "Habilitar OCI Audit Logging para eventos de BD"
  type        = bool
  default     = true
}

variable "enable_wallet_download" {
  description = "Descargar wallet automáticamente después de crear BD"
  type        = bool
  default     = true
}

variable "wallet_download_path" {
  description = "Ruta local donde guardar el wallet (creará directorio si no existe)"
  type        = string
  default     = "./wallet"
}

variable "monitoring_email" {
  description = "Email para recibir notificaciones de alertas (opcional)"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Tags comunes para aplicar a todos los recursos"
  type        = map(string)
  default = {
    CreatedBy  = "Terraform"
    Architecture = "datos-autonomous-db"
    ManagedBy  = "OCI-LATAM-Team"
  }
}

variable "database_edition" {
  description = "Edición de la BD: ENTERPRISE_EDITION o STANDARD_EDITION"
  type        = string
  default     = "ENTERPRISE_EDITION"
  validation {
    condition     = contains(["ENTERPRISE_EDITION", "STANDARD_EDITION"], var.database_edition)
    error_message = "Debe ser ENTERPRISE_EDITION o STANDARD_EDITION."
  }
}

variable "license_model" {
  description = "Modelo de licencia: LICENSE_INCLUDED o BRING_YOUR_OWN_LICENSE"
  type        = string
  default     = "LICENSE_INCLUDED"
  validation {
    condition     = contains(["LICENSE_INCLUDED", "BRING_YOUR_OWN_LICENSE"], var.license_model)
    error_message = "Debe ser LICENSE_INCLUDED o BRING_YOUR_OWN_LICENSE."
  }
}

variable "auto_scaling_enabled" {
  description = "Habilitar auto-scaling de compute"
  type        = bool
  default     = true
}

variable "enable_database_deletion_protection" {
  description = "Proteger la BD contra eliminación accidental"
  type        = bool
  default     = true
}

variable "maintenance_window" {
  description = "Ventana de mantenimiento preferida (formato: day_of_week:HH:MM-HH:MM)"
  type        = string
  default     = "SUNDAY:03:00-04:00"
}

variable "data_guard_enabled" {
  description = "Habilitar Data Guard para alta disponibilidad (costo adicional)"
  type        = bool
  default     = false
}

variable "whitelisted_ips" {
  description = "Lista de IPs permitidas para acceso (CIDR blocks). Vacío = solo Private Endpoint"
  type        = list(string)
  default     = []
}

variable "nsg_id" {
  description = "Network Security Group ID para control de tráfico (opcional)"
  type        = string
  default     = null
}

variable "source_db_backup_id" {
  description = "ID de backup para restaurar desde backup existente (opcional)"
  type        = string
  default     = null
}

variable "clone_from_db_id" {
  description = "OCID de BD existente para clonar (opcional)"
  type        = string
  default     = null
}
