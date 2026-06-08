variable "compartment_id" {
  description = "OCID del compartment"
  type        = string
}
variable "tenancy_ocid" {
  description = "OCID del tenancy"
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
variable "habilitar_cloud_guard" {
  description = "Habilitar Cloud Guard"
  type        = bool
  default     = true
}
variable "habilitar_data_safe" {
  description = "Habilitar Data Safe"
  type        = bool
  default     = false
}
variable "database_id_data_safe" {
  description = "OCID de la base de datos para Data Safe"
  type        = string
  default     = null
}
variable "habilitar_vulnerability_scan" {
  description = "Habilitar Vulnerability Scanning"
  type        = bool
  default     = true
}
variable "retention_logs_dias" {
  description = "Retención de logs en días"
  type        = number
  default     = 90
}
variable "tags" {
  description = "Tags adicionales"
  type        = map(string)
  default     = {}
}
