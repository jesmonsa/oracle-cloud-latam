# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables — Arquitectura 12: VPN Site-to-Site (IPSec)                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Autenticación OCI ──────────────────────────────────────────────────────────
variable "tenancy_ocid" {
  description = "OCID del tenancy"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID del compartment"
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

variable "region" {
  description = "Región OCI"
  type        = string
  default     = "us-ashburn-1"
}

# ─── Proyecto ─────────────────────────────────────────────────────────────────
variable "proyecto" {
  description = "Prefijo para los recursos"
  type        = string
  default     = "vpn-ipsec"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,11}$", var.proyecto))
    error_message = "proyecto: solo minúsculas, números o guiones, máx 12 caracteres."
  }
}

variable "ambiente" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "desarrollo"
}

variable "propietario" {
  description = "E-mail del propietario"
  type        = string
  default     = "admin"
}

# ─── Red OCI ──────────────────────────────────────────────────────────────────
variable "vcn_cidr" {
  description = "CIDR de la VCN en OCI"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_privada_cidr" {
  description = "CIDR subnet privada"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_publica_cidr" {
  description = "CIDR subnet pública (LB)"
  type        = string
  default     = "10.0.0.0/24"
}

# ─── VPN / CPE (simulado) ────────────────────────────────────────────────────────
variable "cpe_ip_address" {
  description = "IP pública del CPE on-premises (simulada para lab)"
  type        = string
  default     = "203.0.113.1"
}

variable "on_prem_cidr" {
  description = "CIDR de la red on-premises (simulada)"
  type        = string
  default     = "192.168.0.0/16"
}

variable "shared_secret" {
  description = "Pre-shared key para el túnel IPSec"
  type        = string
  # Sin default — el usuario DEBE definir su propio shared secret
  sensitive   = true
}

# ─── Cómputo ─────────────────────────────────────────────────────────────────
variable "shape_webserver" {
  description = "Shape Flex para instancias. Compatible: VM.Standard.E4.Flex, VM.Standard.E5.Flex, VM.Standard.A1.Flex (ARM), VM.Optimized3.Flex, VM.Standard3.Flex"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "ocpus_webserver" {
  description = "OCPUs"
  type        = number
  default     = 1
}

variable "memoria_webserver_gb" {
  description = "RAM en GB"
  type        = number
  default     = 8
}

variable "ssh_public_key" {
  description = "Llave pública SSH"
  type        = string
}

# ─── Seguridad ────────────────────────────────────────────────────────────────
variable "habilitar_nsg" {
  description = "Usar NSGs"
  type        = bool
  default     = true
}

variable "ssh_cidr_permitido" {
  description = "CIDR permitido para SSH"
  type        = string
  default     = "0.0.0.0/0"
}
