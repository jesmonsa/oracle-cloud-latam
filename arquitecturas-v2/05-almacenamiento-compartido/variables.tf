# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables - Almacenamiento Compartido (FSS + NFS)                          ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Autenticación OCI ───────────────────────────────────────────────────────
variable "tenancy_ocid" {
  description = "OCID del tenancy"
  type        = string
}

variable "current_user_ocid" {
  description = "OCID del usuario"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint de la API key"
  type        = string
}

variable "private_key_path" {
  description = "Ruta al archivo PEM de la API key"
  type        = string
}

variable "region" {
  description = "Región OCI"
  type        = string
  default     = "us-ashburn-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.region))
    error_message = "Formato de región inválido."
  }
}

# ─── Proyecto ────────────────────────────────────────────────────────────────
variable "compartment_ocid" {
  description = "OCID del compartment"
  type        = string
}

variable "proyecto" {
  description = "Nombre del proyecto"
  type        = string
  default     = "fss-ha"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,15}$", var.proyecto))
    error_message = "Solo minúsculas, números y guiones. Máximo 15 caracteres."
  }
}

variable "ambiente" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "desarrollo"

  validation {
    condition     = contains(["desarrollo", "staging", "produccion"], var.ambiente)
    error_message = "Valores permitidos: desarrollo, staging, produccion"
  }
}

variable "propietario" {
  description = "Email del propietario"
  type        = string
  default     = "admin"
}

# ─── Red ─────────────────────────────────────────────────────────────────────
variable "vcn_cidr" {
  description = "CIDR block para la VCN"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vcn_cidr, 0))
    error_message = "CIDR inválido."
  }
}

variable "subnet_privada_ad1_cidr" {
  description = "CIDR para subnet privada AD1 (webservers + FSS mount target)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_privada_ad2_cidr" {
  description = "CIDR para subnet privada AD2 (webservers)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_lb_cidr" {
  description = "CIDR para subnet pública regional del Load Balancer"
  type        = string
  default     = "10.0.10.0/24"
}

# ─── Cómputo ────────────────────────────────────────────────────────────────
variable "shape_webserver" {
  description = "Shape Flex para instancias. Compatible: VM.Standard.E4.Flex, VM.Standard.E5.Flex, VM.Standard.A1.Flex (ARM), VM.Optimized3.Flex, VM.Standard3.Flex"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "ocpus_webserver" {
  description = "Número de OCPUs por instancia"
  type        = number
  default     = 1
}

variable "memoria_webserver_gb" {
  description = "Memoria en GB por instancia"
  type        = number
  default     = 8
}

variable "imagen_os" {
  description = "OCID de la imagen OS (vacío = última Oracle Linux 8)"
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "Llave pública SSH"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^ssh-(rsa|ed25519|ecdsa)", var.ssh_public_key))
    error_message = "La llave SSH debe comenzar con ssh-rsa, ssh-ed25519 o ssh-ecdsa."
  }
}

# ─── Load Balancer ──────────────────────────────────────────────────────────
variable "lb_bandwidth_min_mbps" {
  description = "Ancho de banda mínimo del LB en Mbps"
  type        = number
  default     = 10
}

variable "lb_bandwidth_max_mbps" {
  description = "Ancho de banda máximo del LB en Mbps"
  type        = number
  default     = 10
}

# ─── File Storage (NFS) ────────────────────────────────────────────────────
variable "nfs_ruta_exportacion" {
  description = "Ruta de exportación NFS"
  type        = string
  default     = "/shared"
}

variable "nfs_punto_montaje" {
  description = "Directorio de montaje local en los webservers"
  type        = string
  default     = "/mnt/shared"
}

# ─── Bastion ────────────────────────────────────────────────────────────────
variable "bastion_cidr_permitidos" {
  description = "CIDRs permitidos para Bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ─── Seguridad ───────────────────────────────────────────────────────────────
variable "habilitar_nsg" {
  description = "Usar Network Security Groups"
  type        = bool
  default     = true
}

variable "habilitar_baseline_seguridad" {
  description = "Habilitar Cloud Guard y auditoría"
  type        = bool
  default     = false
}
