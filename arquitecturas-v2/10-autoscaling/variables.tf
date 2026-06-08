# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables — Arquitectura 10: Autoscaling (Instance Pool)                  ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Autenticación OCI ────────────────────────────────────────────────────────
variable "tenancy_ocid" {
  description = "OCID del tenancy"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID del compartment donde se crean los recursos"
  type        = string
}

variable "current_user_ocid" {
  description = "OCID del usuario actual"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint de la llave API"
  type        = string
}

variable "private_key_path" {
  description = "Ruta al archivo de llave privada API"
  type        = string
}

variable "region" {
  description = "Región OCI — ej. us-ashburn-1"
  type        = string
  default     = "us-ashburn-1"
}

# ─── Proyecto ─────────────────────────────────────────────────────────────────
variable "proyecto" {
  description = "Prefijo para los recursos (máx 12 chars)"
  type        = string
  default     = "autoscale"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,11}$", var.proyecto))
    error_message = "proyecto: solo minúsculas, números o guiones, máx 12 caracteres."
  }
}

variable "ambiente" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "desarrollo"
}

variable "propietario" {
  description = "E-mail o nombre del propietario"
  type        = string
  default     = "admin"
}

# ─── Red ──────────────────────────────────────────────────────────────────────
variable "vcn_cidr" {
  description = "CIDR de la VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_publica_cidr" {
  description = "CIDR de la subnet pública (Load Balancer)"
  type        = string
  default     = "10.0.0.0/24"
}

variable "subnet_privada_cidr" {
  description = "CIDR de la subnet privada (Instance Pool)"
  type        = string
  default     = "10.0.1.0/24"
}

# ─── Cómputo ─────────────────────────────────────────────────────────────────
variable "shape_webserver" {
  description = "Shape Flex para instancias. Compatible: VM.Standard.E4.Flex, VM.Standard.E5.Flex, VM.Standard.A1.Flex (ARM), VM.Optimized3.Flex, VM.Standard3.Flex"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "ocpus_webserver" {
  description = "OCPUs por instancia (shapes Flex)"
  type        = number
  default     = 1
}

variable "memoria_webserver_gb" {
  description = "RAM en GB por instancia (shapes Flex)"
  type        = number
  default     = 8
}

variable "ssh_public_key" {
  description = "Llave pública SSH"
  type        = string
}

# ─── Autoscaling ──────────────────────────────────────────────────────────────
variable "pool_tamano_inicial" {
  description = "Número inicial de instancias en el pool"
  type        = number
  default     = 1
}

variable "pool_tamano_minimo" {
  description = "Número mínimo de instancias (scale-in)"
  type        = number
  default     = 1
}

variable "pool_tamano_maximo" {
  description = "Número máximo de instancias (scale-out)"
  type        = number
  default     = 3
}

variable "umbral_cpu_scale_out" {
  description = "% de CPU para scale-out (agregar instancias)"
  type        = number
  default     = 70
}

variable "umbral_cpu_scale_in" {
  description = "% de CPU para scale-in (reducir instancias)"
  type        = number
  default     = 30
}

variable "cooldown_segundos" {
  description = "Segundos de cooldown entre acciones de escalado"
  type        = number
  default     = 300
}

# ─── Seguridad ────────────────────────────────────────────────────────────────
variable "habilitar_nsg" {
  description = "Usar Network Security Groups"
  type        = bool
  default     = true
}

variable "ssh_cidr_permitido" {
  description = "CIDR permitido para SSH"
  type        = string
  default     = "0.0.0.0/0"
}
