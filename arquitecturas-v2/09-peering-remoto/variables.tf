# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables — Arquitectura 09: Peering Remoto (Cross-Region DRG)            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Identidad y Autenticación ────────────────────────────────────────────────
variable "tenancy_ocid" {
  description = "OCID del tenancy"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID del compartment donde se crean los recursos"
  type        = string
}

variable "current_user_ocid" {
  description = "OCID del usuario actual"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint de la llave API"
  type        = string
}

variable "private_key_path" {
  description = "Ruta al archivo de llave privada API"
  type        = string
}

# ─── Regiones ───────────────────────────────────────────────────────────────
variable "region" {
  description = "Región primaria (Hub) — ej. us-ashburn-1"
  type        = string
  default     = "us-ashburn-1"
}

variable "region2" {
  description = "Región secundaria (Spoke) — ej. us-phoenix-1. Debe estar suscrita en el tenancy."
  type        = string
  default     = "us-phoenix-1"
}

# ─── Proyecto ─────────────────────────────────────────────────────────────────
variable "proyecto" {
  description = "Prefijo para los recursos (máx 6 chars, se combina con hub/spk)"
  type        = string
  default     = "rpc"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,5}$", var.proyecto))
    error_message = "proyecto: solo minúsculas, números o guiones, máx 6 caracteres."
  }
}

variable "ambiente" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "desarrollo"
}

variable "propietario" {
  description = "E-mail o nombre del propietario"
  type        = string
  default     = "admin"
}

# ─── Red — CIDRs ─────────────────────────────────────────────────────────────
variable "vcn_hub_cidr" {
  description = "CIDR de la VCN Hub (Región 1)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vcn_spoke_cidr" {
  description = "CIDR de la VCN Spoke (Región 2)"
  type        = string
  default     = "10.2.0.0/16"
}

variable "subnet_hub_publica_cidr" {
  description = "Subnet pública Hub — Load Balancer"
  type        = string
  default     = "10.0.0.0/24"
}

variable "subnet_hub_privada_cidr" {
  description = "Subnet privada Hub — Webserver"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_spoke_backend_cidr" {
  description = "Subnet privada Spoke — Backend"
  type        = string
  default     = "10.2.1.0/24"
}

# ─── Compute ──────────────────────────────────────────────────────────────────
variable "shape_webserver" {
  description = "Shape Flex para instancias. Compatible: VM.Standard.E4.Flex, VM.Standard.E5.Flex, VM.Standard.A1.Flex (ARM), VM.Optimized3.Flex, VM.Standard3.Flex"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "ocpus_webserver" {
  description = "OCPUs (shapes Flex)"
  type        = number
  default     = 1
}

variable "memoria_webserver_gb" {
  description = "RAM en GB (shapes Flex)"
  type        = number
  default     = 8
}

# ─── SSH y Seguridad ─────────────────────────────────────────────────────────
variable "ssh_public_key" {
  description = "Llave pública SSH"
  type        = string
}

variable "ssh_cidr_permitido" {
  description = "CIDR permitido para SSH (recomendado: tu IP/32)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "habilitar_nsg" {
  description = "Usar NSGs en lugar de Security Lists"
  type        = bool
  default     = true
}
