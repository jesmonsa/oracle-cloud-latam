variable "compartment_id" {
  description = "OCID del compartment"
  type        = string
}

variable "subnet_id" {
  description = "OCID de la subnet pública donde se despliega el Load Balancer"
  type        = string
}

variable "backend_ips" {
  description = "Lista de IPs privadas de los backends"
  type        = list(string)
}

variable "proyecto" {
  description = "Nombre del proyecto"
  type        = string
}

variable "ambiente" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "shape" {
  description = "Shape del Load Balancer (flexible recomendado)"
  type        = string
  default     = "flexible"
}

variable "bandwidth_min_mbps" {
  description = "Ancho de banda mínimo en Mbps (solo para shape flexible)"
  type        = number
  default     = 10
}

variable "bandwidth_max_mbps" {
  description = "Ancho de banda máximo en Mbps (solo para shape flexible)"
  type        = number
  default     = 100
}

variable "puerto_backend" {
  description = "Puerto de los servidores backend"
  type        = number
  default     = 80
}

variable "puerto_listener" {
  description = "Puerto del listener del Load Balancer"
  type        = number
  default     = 80
}

variable "protocolo" {
  description = "Protocolo del listener y health check (HTTP o TCP)"
  type        = string
  default     = "HTTP"
}

variable "habilitar_https" {
  description = "Habilitar listener HTTPS (requiere certificado)"
  type        = bool
  default     = false
}

variable "nsg_ids" {
  description = "Lista de NSG IDs para el Load Balancer"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags adicionales para los recursos"
  type        = map(string)
  default     = {}
}
