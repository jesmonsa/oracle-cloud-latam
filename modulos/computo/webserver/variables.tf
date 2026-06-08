variable "compartment_id" {
  description = "OCID del compartment donde se crea la instancia"
  type        = string
}

variable "subnet_id" {
  description = "OCID de la subnet donde se conecta la instancia"
  type        = string
}

variable "ssh_public_key" {
  description = "Llave pública SSH para acceso a la instancia"
  type        = string
}

variable "proyecto" {
  description = "Nombre del proyecto (usado como prefijo)"
  type        = string
}

variable "ambiente" {
  description = "Ambiente de despliegue (desarrollo, produccion, etc.)"
  type        = string
}

variable "imagen_os" {
  description = "OCID de la imagen del sistema operativo"
  type        = string
}

variable "shape" {
  description = <<-EOT
    Shape de la instancia. Shapes Flex soportados:
      - VM.Standard.E4.Flex   — AMD EPYC Milan       (hasta 64 OCPU / 1024 GB RAM)
      - VM.Standard.E5.Flex   — AMD EPYC Genoa        (hasta 94 OCPU / 1049 GB RAM)
      - VM.Standard.E6.Flex   — AMD EPYC Turin        (hasta 128 OCPU / 1024 GB RAM)
      - VM.Standard.A1.Flex   — Ampere Altra ARM       (hasta 80 OCPU / 512 GB RAM)
      - VM.Standard3.Flex     — Intel Ice Lake         (hasta 32 OCPU / 512 GB RAM)
      - VM.Optimized3.Flex    — Intel Ice Lake HF      (hasta 18 OCPU / 288 GB RAM)
    Shapes de rendimiento fijo (sin shape_config):
      - VM.Standard.x9-15     — Intel Ice Lake X9      (15 OCPU, 1 TB RAM)
      - BM.Standard.x9-36     — Bare Metal X9         (36 OCPU, 2 TB RAM)
  EOT
  type        = string
  default     = "VM.Standard.E4.Flex"

  validation {
    condition = contains([
      # Familia E (AMD EPYC) — Flex
      "VM.Standard.E4.Flex",
      "VM.Standard.E5.Flex",
      "VM.Standard.E6.Flex",
      # Familia A1 (Ampere ARM) — Flex
      "VM.Standard.A1.Flex",
      # Familia Intel Flex
      "VM.Standard3.Flex",
      "VM.Optimized3.Flex",
      # Familia X9 (Intel Ice Lake, RAM fija)
      "VM.Standard.x9-15",
      "BM.Standard.x9-36",
    ], var.shape)
    error_message = "Shape no soportado. Usa uno de: VM.Standard.E4.Flex, VM.Standard.E5.Flex, VM.Standard.E6.Flex, VM.Standard.A1.Flex, VM.Standard3.Flex, VM.Optimized3.Flex, VM.Standard.x9-15, BM.Standard.x9-36."
  }
}

variable "ocpus" {
  description = <<-EOT
    Cantidad de OCPUs para shapes Flex. Ignorado en shapes de CPU fija (x9).
    Mínimo: 1. Máximos por shape:
      E4.Flex → 64 | E5.Flex → 94 | E6.Flex → 128
      A1.Flex → 80 | Standard3.Flex → 32 | Optimized3.Flex → 18
  EOT
  type        = number
  default     = 1

  validation {
    condition     = var.ocpus >= 1 && var.ocpus <= 128
    error_message = "ocpus debe estar entre 1 y 128."
  }
}

variable "memoria_gb" {
  description = <<-EOT
    RAM en GB para shapes Flex. Ignorado en shapes de CPU fija (x9).
    OCI requiere entre 1 GB/OCPU y 64 GB/OCPU (E4/E5/E6).
    A1.Flex: máx 6 GB/OCPU. El módulo no valida el ratio; OCI lo rechaza en plan/apply.
  EOT
  type        = number
  default     = 8

  validation {
    condition     = var.memoria_gb >= 1 && var.memoria_gb <= 1024
    error_message = "memoria_gb debe estar entre 1 y 1024 GB."
  }
}

variable "boot_volume_gb" {
  description = "Tamaño del Boot Volume en GB. Mínimo 50 GB, máximo 32768 GB."
  type        = number
  default     = 50

  validation {
    condition     = var.boot_volume_gb >= 50 && var.boot_volume_gb <= 32768
    error_message = "boot_volume_gb debe estar entre 50 y 32768 GB."
  }
}

variable "cantidad" {
  description = "Número de instancias a crear"
  type        = number
  default     = 1

  validation {
    condition     = var.cantidad >= 1 && var.cantidad <= 20
    error_message = "cantidad debe estar entre 1 y 20."
  }
}

variable "asignar_ip_publica" {
  description = "Asignar IP pública a la instancia"
  type        = bool
  default     = false
}

variable "nsg_ids" {
  description = "Lista de OCIDs de Network Security Groups a asignar"
  type        = list(string)
  default     = []
}

variable "availability_domain" {
  description = "Availability Domain específico (null = distribuir automáticamente entre los disponibles)"
  type        = string
  default     = null
}

variable "fault_domain" {
  description = "Fault Domain específico (null = asignado por OCI)"
  type        = string
  default     = null
}

variable "userdata_extra" {
  description = "Script cloud-init adicional a ejecutar tras el userdata base del módulo"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags en formato libre para los recursos"
  type        = map(string)
  default     = {}
}
