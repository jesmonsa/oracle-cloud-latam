# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables — Arquitectura 14: API Gateway                                  ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

variable "tenancy_ocid"      { type = string }
variable "compartment_ocid"  { type = string }
variable "current_user_ocid" { type = string }
variable "fingerprint"       { type = string }
variable "private_key_path"  { type = string }

variable "region" {
  type    = string
  default = "us-ashburn-1"
}

variable "proyecto" {
  type    = string
  default = "apigw"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,11}$", var.proyecto))
    error_message = "proyecto: solo minúsculas, números o guiones, máx 12 caracteres."
  }
}

variable "ambiente" {
  type    = string
  default = "desarrollo"
}

variable "propietario" {
  type    = string
  default = "admin"
}

variable "vcn_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_publica_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "subnet_privada_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "shape_webserver" {
  description = "Shape Flex para instancias. Compatible: VM.Standard.E4.Flex, VM.Standard.E5.Flex, VM.Standard.A1.Flex (ARM), VM.Optimized3.Flex, VM.Standard3.Flex"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "ocpus_webserver" {
  type    = number
  default = 1
}

variable "memoria_webserver_gb" {
  type    = number
  default = 8
}

variable "ssh_public_key" {
  type = string
}

variable "habilitar_nsg" {
  type    = bool
  default = true
}

variable "ssh_cidr_permitido" {
  type    = string
  default = "0.0.0.0/0"
}
