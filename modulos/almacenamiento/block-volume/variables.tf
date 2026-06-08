variable "compartment_id" {
  description = "OCID del compartment donde se crea el Block Volume"
  type        = string
}

variable "availability_domain" {
  description = "Availability Domain donde se crea el volumen (debe coincidir con la instancia)"
  type        = string
}

variable "instancia_id" {
  description = "OCID de la instancia a la que se adjunta el volumen"
  type        = string
}

variable "proyecto" {
  description = "Nombre del proyecto (usado como prefijo)"
  type        = string
}

variable "ambiente" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "tamano_gb" {
  description = "Tamaño del Block Volume en GB"
  type        = number
  default     = 100
}

variable "punto_montaje" {
  description = "Punto de montaje del volumen en el sistema de archivos del OS"
  type        = string
  default     = "/u01"
}

variable "vpus_por_gb" {
  description = "VPUs por GB (0=Low, 10=Balanced, 20=High, 30-120=Ultra High Performance)"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags en formato libre para los recursos"
  type        = map(string)
  default     = {}
}
