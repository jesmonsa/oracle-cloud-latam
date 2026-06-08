variable "compartment_id_vcn1" {
  description = "OCID del compartment de VCN1 (Hub)"
  type        = string
}
variable "compartment_id_vcn2" {
  description = "OCID del compartment de VCN2 (Spoke)"
  type        = string
}
variable "vcn_id_1" {
  description = "OCID de la VCN1 (Hub)"
  type        = string
}
variable "vcn_id_2" {
  description = "OCID de la VCN2 (Spoke)"
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
