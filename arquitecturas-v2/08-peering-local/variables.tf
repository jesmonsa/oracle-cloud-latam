# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables - Peering Local (Hub-Spoke)                                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Autenticación OCI ────────────────────────────────────────────────────────
variable "tenancy_ocid" { type = string }
variable "current_user_ocid" { type = string }
variable "fingerprint" { type = string }
variable "private_key_path" { type = string }
variable "region" { type = string }

# ─── Proyecto ─────────────────────────────────────────────────────────────────
variable "compartment_ocid" {
  description = "OCID del compartment donde se crean los recursos"
  type        = string
}

variable "proyecto" {
  description = "Prefijo para nombrar recursos (máx 8 chars por usar Hub/Spoke)"
  type        = string
  default     = "peer"

  validation {
    condition     = length(var.proyecto) <= 8
    error_message = "El proyecto debe tener máximo 8 caracteres (se combina con hub/spk)."
  }
}

variable "ambiente" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "desarrollo"
}

variable "propietario" {
  description = "Email del propietario"
  type        = string
  default     = ""
}

# ─── Red Hub ──────────────────────────────────────────────────────────────────
variable "vcn_hub_cidr" {
  description = "CIDR de la VCN Hub"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_hub_publica_cidr" {
  description = "CIDR de la subnet pública Hub (LB)"
  type        = string
  default     = "10.0.10.0/24"
}

variable "subnet_hub_privada_cidr" {
  description = "CIDR de la subnet privada Hub (webservers)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_hub_db_cidr" {
  description = "CIDR de la subnet privada Hub (DB)"
  type        = string
  default     = "10.0.3.0/24"
}

# ─── Red Spoke ────────────────────────────────────────────────────────────────
variable "vcn_spoke_cidr" {
  description = "CIDR de la VCN Spoke (NO debe solapar con Hub)"
  type        = string
  default     = "10.1.0.0/16"

  validation {
    condition     = can(cidrhost(var.vcn_spoke_cidr, 0))
    error_message = "vcn_spoke_cidr debe ser un CIDR válido."
  }
}

variable "subnet_spoke_backend_cidr" {
  description = "CIDR de la subnet privada Spoke (backend)"
  type        = string
  default     = "10.1.1.0/24"
}

# ─── Cómputo ─────────────────────────────────────────────────────────────────
variable "shape_webserver" {
  description = "Shape Flex para instancias. Compatible: VM.Standard.E4.Flex, VM.Standard.E5.Flex, VM.Standard.A1.Flex (ARM), VM.Optimized3.Flex, VM.Standard3.Flex"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "ocpus_webserver" {
  description = "OCPUs para webservers"
  type        = number
  default     = 1
}

variable "memoria_webserver_gb" {
  description = "Memoria en GB para webservers"
  type        = number
  default     = 8
}

variable "ssh_public_key" {
  description = "Clave pública SSH para las instancias"
  type        = string
}

# ─── Base de Datos ────────────────────────────────────────────────────────────
variable "db_admin_password" {
  description = "Contraseña SYS/SYSTEM para el DB System"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "HUBDB"
}

variable "db_version" {
  description = "Versión de Oracle Database"
  type        = string
  default     = "19.30.0.0"
}

variable "shape_db" {
  description = "Shape del DB System"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "cpu_core_count_db" {
  description = "OCPUs del DB System"
  type        = number
  default     = 2
}

variable "data_storage_size_in_gb" {
  description = "Almacenamiento de datos en GB"
  type        = number
  default     = 256
}

variable "database_edition" {
  description = "Edición de Oracle Database"
  type        = string
  default     = "ENTERPRISE_EDITION"
}

variable "license_model" {
  description = "Modelo de licencia"
  type        = string
  default     = "LICENSE_INCLUDED"
}

# ─── Load Balancer ────────────────────────────────────────────────────────────
variable "lb_bandwidth_min_mbps" {
  description = "Ancho de banda mínimo del LB"
  type        = number
  default     = 10
}

variable "lb_bandwidth_max_mbps" {
  description = "Ancho de banda máximo del LB"
  type        = number
  default     = 10
}

# ─── Bastion ──────────────────────────────────────────────────────────────────
variable "bastion_cidr_permitidos" {
  description = "CIDRs permitidos para el Bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ─── Seguridad ────────────────────────────────────────────────────────────────
variable "habilitar_nsg" {
  description = "Habilitar Network Security Groups"
  type        = bool
  default     = true
}

variable "habilitar_baseline_seguridad" {
  description = "Habilitar baselines de seguridad"
  type        = bool
  default     = false
}
