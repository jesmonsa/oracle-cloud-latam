variable "primary_database_id" {
  description = "OCID de la Base de Datos primaria (obtenido del módulo dbsystem)"
  type        = string
}

variable "db_admin_password" {
  description = "Contraseña SYS de la Base de Datos primaria, obligatoria para asociar el DataGuard"
  type        = string
  sensitive   = true
}

variable "availability_domain" {
  description = "Availability Domain donde se creará el DB System Standby"
  type        = string
}

variable "subnet_id" {
  description = "OCID de la Subnet donde se conectará el DB System Standby"
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
    Shape del nodo de Base de Datos Standby. Debe coincidir con el shape de la primaria.
    Shapes Flex soportados por Base Database:
      - VM.Standard.E4.Flex   — AMD EPYC Milan       (1–64 OCPU)
      - VM.Standard.E5.Flex   — AMD EPYC Genoa        (1–94 OCPU) ← recomendado nuevos proyectos
      - VM.Standard.E6.Flex   — AMD EPYC Turin        (1–128 OCPU)
      - VM.Standard.x9-15     — Intel Ice Lake X9     (15 OCPU fijos, 1 TB RAM)
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
    error_message = "Shape de Standby no soportado. Usa: VM.Standard.E4.Flex, VM.Standard.E5.Flex, VM.Standard.E6.Flex, VM.Standard.x9-15."
  }
}

variable "cpu_core_count" {
  description = <<-EOT
    Cantidad de OCPUs para el DB System Standby.
    Debe coincidir con la primaria para garantizar la capacidad de failover.
    En VM.Standard.x9-15 este valor es ignorado (la API fija 15 OCPUs).
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
    RAM en GB para el DB System Standby (shapes Flex).
    Debe coincidir con la primaria.
    Ignorado en VM.Standard.x9-15 (RAM fija de 1 TB).
  EOT
  type        = number
  default     = 16

  validation {
    condition     = var.memory_in_gbs >= 1 && var.memory_in_gbs <= 2048
    error_message = "memory_in_gbs debe estar entre 1 y 2048 GB."
  }
}

variable "protection_mode" {
  description = <<-EOT
    Modo de protección del DataGuard:
      - MAXIMUM_PERFORMANCE  — Sin impacto en la primaria, RPO mayor (recomendado cross-region)
      - MAXIMUM_AVAILABILITY — Balance entre RPO y disponibilidad
      - MAXIMUM_PROTECTION   — Sin pérdida de datos, puede pausar la primaria si se pierde el Standby
  EOT
  type        = string
  default     = "MAXIMUM_PERFORMANCE"

  validation {
    condition     = contains(["MAXIMUM_PERFORMANCE", "MAXIMUM_AVAILABILITY", "MAXIMUM_PROTECTION"], var.protection_mode)
    error_message = "protection_mode debe ser MAXIMUM_PERFORMANCE, MAXIMUM_AVAILABILITY o MAXIMUM_PROTECTION."
  }
}

variable "transport_type" {
  description = <<-EOT
    Tipo de transporte del redo log al Standby:
      - ASYNC — Asíncrono, sin latencia en la primaria (recomendado para cross-region)
      - SYNC  — Síncrono, garantiza RPO=0 (recomendado para mismo datacenter)
  EOT
  type        = string
  default     = "ASYNC"

  validation {
    condition     = contains(["ASYNC", "SYNC"], var.transport_type)
    error_message = "transport_type debe ser ASYNC o SYNC."
  }
}

variable "delete_standby_db_home_on_delete" {
  description = "Si es true, elimina el DB Home del Standby al destruir el recurso con terraform destroy"
  type        = bool
  default     = true
}

variable "nsg_ids" {
  description = "Lista de OCIDs de Network Security Groups a asignar al nodo Standby"
  type        = list(string)
  default     = []
}
