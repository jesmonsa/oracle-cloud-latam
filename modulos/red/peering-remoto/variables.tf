variable "compartment_id" {
  description = "OCID del compartment donde se crean los DRGs y RPCs"
  type        = string
}
variable "vcn_id_region1" {
  description = "OCID de la VCN en la Región 1"
  type        = string
}
variable "vcn_id_region2" {
  description = "OCID de la VCN en la Región 2"
  type        = string
}
variable "region1" {
  description = "Nombre de la Región 1 (ej. sa-santiago-1)"
  type        = string
}
variable "region2" {
  description = "Nombre de la Región 2 (ej. us-ashburn-1)"
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
variable "tags" {
  description = "Tags adicionales"
  type        = map(string)
  default     = {}
}
