variable "compartment_id" {
  description = "OCID del compartment donde se crean los NSGs"
  type        = string
}

variable "vcn_id" {
  description = "OCID de la VCN donde se crean los NSGs"
  type        = string
}

variable "proyecto" {
  description = "Nombre del proyecto (prefijo)"
  type        = string
}

variable "ambiente" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "habilitar_nsg_web" {
  description = "Habilitar NSG para tráfico HTTP/HTTPS"
  type        = bool
  default     = true
}

variable "habilitar_nsg_ssh" {
  description = "Habilitar NSG para tráfico SSH"
  type        = bool
  default     = true
}

variable "habilitar_nsg_db" {
  description = "Habilitar NSG para tráfico de base de datos (puerto 1521)"
  type        = bool
  default     = false
}

variable "habilitar_nsg_nfs" {
  description = "Habilitar NSG para tráfico NFS (File Storage Service)"
  type        = bool
  default     = false
}

variable "cidr_ssh_permitido" {
  description = "CIDR origen permitido para SSH. Restringe a tu IP pública en producción"
  type        = string
  default     = "0.0.0.0/0"
}

variable "cidr_red_interna" {
  description = "Lista de CIDRs de redes internas para reglas de DB y NFS (soporta múltiples CIDRs para peering multi-región)"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "tags" {
  description = "Tags adicionales para los recursos"
  type        = map(string)
  default     = {}
}
