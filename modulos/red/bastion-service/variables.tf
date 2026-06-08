variable "compartment_id" {
  description = "OCID del compartment"
  type        = string
}

variable "subnet_id" {
  description = "Subnet objetivo donde están los servidores privados"
  type        = string
}

variable "proyecto" {
  description = "Nombre del proyecto"
  type        = string
}

variable "ambiente" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "cidr_permitidos" {
  description = "Lista de CIDRs permitidos para conexiones Bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tiempo_max_sesion_segundos" {
  description = "TTL máximo de sesiones Bastion en segundos (default 3h)"
  type        = number
  default     = 10800
}

variable "tags" {
  description = "Tags adicionales para los recursos"
  type        = map(string)
  default     = {}
}
