variable "compartment_id" {
  description = "OCID del compartment donde se creará la VCN"
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR de la VCN"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vcn_cidr))
    error_message = "El CIDR de la VCN no tiene formato válido. Ejemplo: 10.0.0.0/16"
  }
}

variable "proyecto" {
  description = "Nombre del proyecto (usado como prefijo)"
  type        = string
}

variable "ambiente" {
  description = "Ambiente de despliegue (produccion, desarrollo, etc.)"
  type        = string
}

variable "habilitar_nat_gateway" {
  description = "Habilitar NAT Gateway para subredes privadas"
  type        = bool
  default     = true
}

variable "habilitar_service_gateway" {
  description = "Habilitar Service Gateway para acceso a servicios de OCI sin salir a Internet"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags adicionales para los recursos"
  type        = map(string)
  default     = {}
}
