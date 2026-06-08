variable "compartment_id" {
  description = "OCID del compartment donde se crea el File System"
  type        = string
}

variable "availability_domain" {
  description = "Availability Domain donde se crea el File System y Mount Target"
  type        = string
}

variable "subnet_id" {
  description = "OCID de la subnet donde se crea el Mount Target"
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

variable "ruta_exportacion" {
  description = "Ruta de exportación NFS (ej. /shared, /data)"
  type        = string
  default     = "/shared"
}

variable "opciones_nfs" {
  description = "Opciones NFS de montaje (informativo, aplicadas en el cliente)"
  type        = string
  default     = "rw,sync,no_subtree_check"
}

variable "cidr_permitido" {
  description = "CIDR de la red con acceso al File System vía NFS"
  type        = string
  default     = "10.0.0.0/16"
}

variable "nsg_ids" {
  description = "Lista de NSG IDs para asignar al Mount Target (ej. NSG NFS)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags en formato libre para los recursos"
  type        = map(string)
  default     = {}
}
