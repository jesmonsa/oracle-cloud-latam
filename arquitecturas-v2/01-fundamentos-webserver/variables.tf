# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables - 01 Fundamentos Webserver                                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Autenticación OCI ────────────────────────────────────────────────────────
variable "tenancy_ocid" {
  description = "OCID del Tenancy de OCI"
  type        = string
}

variable "current_user_ocid" {
  description = "OCID del usuario. Vacío si se usa Instance Principal o Resource Manager"
  type        = string
  default     = ""
}

variable "region" {
  description = "Región de OCI donde se despliegan los recursos"
  type        = string
  default     = "us-ashburn-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.region))
    error_message = "La región debe tener el formato: xx-nombre-N (ej: us-ashburn-1, sa-saopaulo-1)."
  }
}

variable "fingerprint" {
  description = "Fingerprint de la API Key. Vacío si se usa Instance Principal"
  type        = string
  default     = ""
}

variable "private_key_path" {
  description = "Ruta a la llave privada PEM. Vacío si se usa Instance Principal"
  type        = string
  default     = ""
}

# ─── Proyecto ─────────────────────────────────────────────────────────────────
variable "compartment_ocid" {
  description = "OCID del Compartment donde se crearán todos los recursos"
  type        = string
}

variable "proyecto" {
  description = "Prefijo para nombrar todos los recursos. Minúsculas, máx 15 caracteres"
  type        = string
  default     = "fundamentos"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,14}$", var.proyecto))
    error_message = "Debe empezar con letra minúscula, solo letras/números/guiones, máximo 15 caracteres."
  }
}

variable "ambiente" {
  description = "Ambiente de despliegue (desarrollo, staging, produccion)"
  type        = string
  default     = "desarrollo"

  validation {
    condition     = contains(["desarrollo", "staging", "produccion"], var.ambiente)
    error_message = "Valores permitidos: desarrollo, staging, produccion."
  }
}

variable "propietario" {
  description = "E-mail o nombre del responsable de los recursos"
  type        = string
  default     = "admin"
}

# ─── Red ──────────────────────────────────────────────────────────────────────
variable "vcn_cidr" {
  description = "CIDR block para la VCN. Rango privado RFC1918 recomendado"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vcn_cidr, 0))
    error_message = "Debe ser un CIDR válido (ej: 10.0.0.0/16)."
  }
}

variable "subnet_publica_cidr" {
  description = "CIDR block para la Subred Pública. Debe estar dentro del rango de la VCN"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.subnet_publica_cidr, 0))
    error_message = "Debe ser un CIDR válido (ej: 10.0.1.0/24)."
  }
}

# ─── Cómputo ──────────────────────────────────────────────────────────────────
variable "shape_webserver" {
  description = "Shape Flex para instancias. Compatible: VM.Standard.E4.Flex, VM.Standard.E5.Flex, VM.Standard.A1.Flex (ARM), VM.Optimized3.Flex, VM.Standard3.Flex"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "ocpus_webserver" {
  description = "Cantidad de OCPUs (1 OCPU = Always Free Tier elegible)"
  type        = number
  default     = 1

  validation {
    condition     = var.ocpus_webserver >= 1 && var.ocpus_webserver <= 128
    error_message = "Debe estar entre 1 y 128 OCPUs."
  }
}

variable "memoria_webserver_gb" {
  description = "RAM en GB. Ratio válido: 1-64 GB por OCPU en shapes AMD"
  type        = number
  default     = 8

  validation {
    condition     = var.memoria_webserver_gb >= 1 && var.memoria_webserver_gb <= 1024
    error_message = "Debe estar entre 1 y 1024 GB."
  }
}

variable "imagen_os" {
  description = "OCID de la imagen OS. Vacío = última Oracle Linux 8 disponible"
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "Llave pública SSH para acceso a las instancias"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^ssh-(rsa|ed25519|ecdsa)", var.ssh_public_key))
    error_message = "Debe ser una llave SSH válida (ssh-rsa, ssh-ed25519 o ssh-ecdsa)."
  }
}

# ─── Seguridad ────────────────────────────────────────────────────────────────
variable "ssh_cidr_permitido" {
  description = "CIDR permitido para SSH. NUNCA usar 0.0.0.0/0 en producción. Ejemplo: 190.27.1.100/32"
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.ssh_cidr_permitido, 0))
    error_message = "Debe ser un CIDR válido (ej: 190.27.1.100/32)."
  }
}

variable "habilitar_nsg" {
  description = "Usar Network Security Groups (recomendado) en lugar de Security Lists"
  type        = bool
  default     = true
}

variable "habilitar_baseline_seguridad" {
  description = "Activa Cloud Guard y auditoría. Recomendado para producción"
  type        = bool
  default     = false
}
