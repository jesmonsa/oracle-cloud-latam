variable "compartment_id" {
  description = "OCID del compartment donde se creará el DB System"
  type        = string
}

variable "availability_domain" {
  description = "Availability Domain donde se creará el DB System"
  type        = string
}

variable "subnet_id" {
  description = "OCID de la subnet donde se desplegará el DB System"
  type        = string
}

variable "proyecto" {
  description = "Prefijo para nombrar los recursos"
  type        = string
}

variable "ambiente" {
  description = "Ambiente de despliegue (ej. desarrollo, produccion)"
  type        = string
}

variable "shape" {
  description = <<-EOT
    Shape del nodo de Base de Datos. Shapes Flex soportados por Base Database:
      - VM.Standard.E4.Flex   — AMD EPYC Milan       (1–64 OCPU)
      - VM.Standard.E5.Flex   — AMD EPYC Genoa        (1–94 OCPU) ← recomendado nuevos proyectos
      - VM.Standard.E6.Flex   — AMD EPYC Turin        (1–128 OCPU)
      - VM.Standard.x9-15     — Intel Ice Lake X9     (15 OCPU fijos, 1 TB RAM)
    Nota: Los shapes BM (Bare Metal) para BD requieren licencia EE Extreme Performance
    y configuración adicional fuera del alcance de este módulo.
  EOT
  type        = string
  default     = "VM.Standard.E4.Flex"

  validation {
    condition = contains([
      "VM.Standard.E4.Flex",
      "VM.Standard.E5.Flex",
      "VM.Standard.E6.Flex",
      "VM.Standard.x9-15",
    ], var.shape)
    error_message = "Shape de BD no soportado. Usa: VM.Standard.E4.Flex, VM.Standard.E5.Flex, VM.Standard.E6.Flex, VM.Standard.x9-15."
  }
}

variable "cpu_core_count" {
  description = <<-EOT
    Cantidad de OCPUs para el DB System.
    En shapes Flex: mínimo 1, máximo según shape.
    En VM.Standard.x9-15: este valor es ignorado (la API fija 15 OCPUs).
    OCI Base Database requiere número par de cores en la mayoría de shapes.
  EOT
  type        = number
  default     = 2

  validation {
    condition     = var.cpu_core_count >= 1 && var.cpu_core_count <= 128
    error_message = "cpu_core_count debe estar entre 1 y 128."
  }
}

variable "memory_in_gbs" {
  description = <<-EOT
    RAM en GB para shapes Flex de Base Database.
    Ignorado en VM.Standard.x9-15 (RAM fija de 1 TB).
    OCI requiere entre 1 GB/OCPU y 64 GB/OCPU para E4/E5.
    E6: hasta 8 GB/OCPU. El módulo no valida el ratio exacto; OCI lo rechaza en apply.
  EOT
  type        = number
  default     = 16

  validation {
    condition     = var.memory_in_gbs >= 1 && var.memory_in_gbs <= 2048
    error_message = "memory_in_gbs debe estar entre 1 y 2048 GB."
  }
}

variable "db_admin_password" {
  description = "Contraseña de administrador de la base de datos (SYS)"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nombre de la Base de Datos (máx 8 caracteres alfanuméricos)"
  type        = string
  default     = "PRODDB"
  validation {
    condition     = length(var.db_name) > 0 && length(var.db_name) <= 8 && can(regex("^[a-zA-Z0-9]+$", var.db_name))
    error_message = "El nombre de la DB no debe exceder 8 caracteres alfanuméricos."
  }
}

variable "db_version" {
  description = <<-EOT
    Versión de Oracle Database. Versiones disponibles en Base Database:
      - "19.30.0.0"  ← versión Long-Term Support, recomendada
      - "21.0.0.0"   ← innovación, termina soporte 2026
      - "23.0.0.0"   ← Oracle DB 23ai, disponible en regiones seleccionadas
  EOT
  type        = string
  default     = "19.30.0.0"
}

variable "database_edition" {
  description = <<-EOT
    Edición de Oracle Database:
      - STANDARD_EDITION           — SE2, sin RAC ni DataGuard nativo
      - ENTERPRISE_EDITION         — EE, incluye DataGuard (recomendado para HA)
      - ENTERPRISE_EDITION_HIGH_PERFORMANCE  — EE HP, incluye Partitioning, etc.
      - ENTERPRISE_EDITION_EXTREME_PERFORMANCE — EE XP, incluye RAC, In-Memory, etc.
    Para usar DataGuard (módulo dataguard) se requiere mínimo ENTERPRISE_EDITION.
  EOT
  type        = string
  default     = "ENTERPRISE_EDITION"

  validation {
    condition = contains([
      "STANDARD_EDITION",
      "ENTERPRISE_EDITION",
      "ENTERPRISE_EDITION_HIGH_PERFORMANCE",
      "ENTERPRISE_EDITION_EXTREME_PERFORMANCE",
    ], var.database_edition)
    error_message = "database_edition debe ser STANDARD_EDITION, ENTERPRISE_EDITION, ENTERPRISE_EDITION_HIGH_PERFORMANCE o ENTERPRISE_EDITION_EXTREME_PERFORMANCE."
  }
}

variable "ssh_public_keys" {
  description = "Lista de llaves públicas SSH permitidas para el nodo OS"
  type        = list(string)
}

variable "timezone" {
  description = "Zona horaria del OS del nodo de la base de datos (ej. America/Bogota)"
  type        = string
  default     = "UTC"
}

variable "data_storage_size_in_gb" {
  description = "Tamaño de almacenamiento de datos en GB (mínimo 256)"
  type        = number
  default     = 256

  validation {
    condition     = var.data_storage_size_in_gb >= 256
    error_message = "data_storage_size_in_gb debe ser al menos 256 GB."
  }
}

variable "node_count" {
  description = "Cantidad de nodos (1 para Single Instance, 2 para RAC — requiere EE_EXTREME_PERFORMANCE)"
  type        = number
  default     = 1

  validation {
    condition     = contains([1, 2], var.node_count)
    error_message = "node_count debe ser 1 (Single Instance) o 2 (RAC)."
  }
}

variable "license_model" {
  description = <<-EOT
    Modelo de licenciamiento:
      - LICENSE_INCLUDED    — Licencia incluida en el costo por hora
      - BRING_YOUR_OWN_LICENSE — Usa licencias Oracle existentes (requiere compliance)
  EOT
  type        = string
  default     = "LICENSE_INCLUDED"

  validation {
    condition     = contains(["LICENSE_INCLUDED", "BRING_YOUR_OWN_LICENSE"], var.license_model)
    error_message = "license_model debe ser LICENSE_INCLUDED o BRING_YOUR_OWN_LICENSE."
  }
}

variable "nsg_ids" {
  description = "Lista de OCIDs de Network Security Groups a asignar al nodo de base de datos"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Diccionario de tags en formato libre"
  type        = map(string)
  default     = {}
}
