variable "tenancy_ocid" {
  type = string
}
variable "current_user_ocid" {
  type    = string
  default = ""
}
variable "region" {
  type    = string
  default = "us-ashburn-1"
}
variable "fingerprint" {
  type    = string
  default = ""
}
variable "private_key_path" {
  type    = string
  default = ""
}

variable "compartment_ocid" {
  description = "Compartment donde se crearán todos los recursos de esta arquitectura"
  type        = string
}

variable "proyecto" {
  description = "Prefijo usado en el nombre de todos los recursos. Sin espacios, máx 15 caracteres"
  type        = string
  default     = "miproyecto"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,14}$", var.proyecto))
    error_message = "El proyecto debe empezar con letra minúscula, tener solo letras minúsculas, números o guiones, y máximo 15 caracteres."
  }
}

variable "ambiente" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "desarrollo"
}

variable "propietario" {
  description = "E-mail o nombre del propietario de los recursos"
  type        = string
  default     = "admin"
}

variable "vcn_cidr" {
  description = "CIDR block para la Red Virtual (VCN)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_publica_cidr" {
  description = "CIDR block para la Subred Pública (Load Balancer)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_privada_cidr" {
  description = "CIDR block para la Subred Privada (Webservers)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_db_cidr" {
  description = "CIDR block exclusivo para la Subred Privada de Bases de Datos"
  type        = string
  default     = "10.0.3.0/24"
}

variable "shape_webserver" {
  description = "Shape Flex para Webserver: VM.Standard.E4.Flex | E5.Flex | E6.Flex | VM.Standard.x9-15"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "ocpus_webserver" {
  description = "OCPUs para el Webserver (shapes Flex)"
  type        = number
  default     = 1
}

variable "memoria_webserver_gb" {
  description = "RAM en GB para el Webserver (shapes Flex). Ignorado en x9-15."
  type        = number
  default     = 8
}

variable "shape_dbsystem" {
  description = "Shape Base Database: VM.Standard.E4.Flex | E5.Flex | E6.Flex | VM.Standard.x9-15"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "ocpus_dbsystem" {
  description = "OCPUs para el DB System (shapes Flex)"
  type        = number
  default     = 2
}

variable "memoria_dbsystem_gb" {
  description = "RAM en GB para el DB System (shapes Flex). Ignorado en x9-15 (1 TB fijo). Default: 16 GB."
  type        = number
  default     = 16
}

variable "db_password" {
  description = "Contraseña SYS de la Base de Datos (obligatorio)"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nombre de la Base de Datos (máx 8 caracteres alfanuméricos)"
  type        = string
  default     = "PRODDB"
}

variable "db_timezone" {
  description = "Zona horaria del Sistema de Base de Datos"
  type        = string
  default     = "America/Bogota"
}

variable "imagen_os" {
  description = "OCID de la imagen del sistema operativo de los Webservers"
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "Llave pública SSH para conectarse a las instancias mediante Bastion"
  type        = string
}

variable "ssh_cidr_permitido" {
  description = "Recomendado: restringe a tu IP pública. Ejemplo: 190.27.1.0/32. Usar 0.0.0.0/0 solo para pruebas"
  type        = string
  default     = "0.0.0.0/0"
}

variable "habilitar_nsg" {
  description = "Recomendado: NSG ofrece seguridad más granular que Security Lists"
  type        = bool
  default     = true
}

variable "habilitar_baseline_seguridad" {
  description = "Activa Cloud Guard, Data Safe y auditoría básica. Recomendado para producción"
  type        = bool
  default     = false
}

