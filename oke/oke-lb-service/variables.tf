# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  OKE LOAD BALANCER SERVICE - VARIABLES DE CONFIGURACIÓN                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# VARIABLES DE AUTENTICACIÓN Y TENENCIA
# ==============================================================================

variable "tenancy_ocid" {
  description = "OCID de la tenencia de Oracle Cloud"
  type        = string
  sensitive   = true
}

variable "current_user_ocid" {
  description = "OCID del usuario actual"
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "Fingerprint de la clave pública API"
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Ruta a la clave privada API"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Región de Oracle Cloud"
  type        = string
  default     = "sa-santiago-1"
}

# ==============================================================================
# VARIABLES DE CONFIGURACIÓN DEL CLÚSTER OKE
# ==============================================================================

variable "cluster_name" {
  description = "Nombre del clúster OKE"
  type        = string
  default     = "oke-lb-service"
}

variable "cluster_version" {
  description = "Versión de Kubernetes"
  type        = string
  default     = "1.29"
}

variable "compartment_id" {
  description = "OCID del compartimiento"
  type        = string
}

variable "vcn_cidr_block" {
  description = "Bloque CIDR de la VCN"
  type        = string
  default     = "10.1.0.0/16"
}

variable "k8s_subnet_cidr" {
  description = "Bloque CIDR de la subred de Kubernetes"
  type        = string
  default     = "10.1.1.0/24"
}

variable "worker_subnet_cidr" {
  description = "Bloque CIDR de la subred de nodos de trabajo"
  type        = string
  default     = "10.1.2.0/24"
}

variable "lb_subnet_cidr" {
  description = "Bloque CIDR de la subred para Load Balancer"
  type        = string
  default     = "10.1.3.0/24"
}

variable "node_pool_size" {
  description = "Cantidad de nodos en el pool"
  type        = number
  default     = 3
}

variable "node_shape" {
  description = "Forma de los nodos"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "node_ocpus" {
  description = "Cantidad de OCPUs por nodo"
  type        = number
  default     = 2
}

variable "node_memory_gb" {
  description = "Memoria RAM en GB por nodo"
  type        = number
  default     = 8
}

# ==============================================================================
# VARIABLES DE LOAD BALANCER OCI
# ==============================================================================

variable "lb_shape" {
  description = "Forma del Load Balancer (flexible, 100Mbps, 400Mbps)"
  type        = string
  default     = "flexible"
  validation {
    condition     = contains(["flexible", "100Mbps", "400Mbps"], var.lb_shape)
    error_message = "Debe ser 'flexible', '100Mbps' o '400Mbps'"
  }
}

variable "lb_is_private" {
  description = "Load Balancer privado (true) o público (false)"
  type        = bool
  default     = false
}

variable "lb_min_bandwidth_mbps" {
  description = "Ancho de banda mínimo en Mbps (solo flexible)"
  type        = number
  default     = 10
  validation {
    condition     = var.lb_min_bandwidth_mbps >= 10 && var.lb_min_bandwidth_mbps <= 4000
    error_message = "Debe estar entre 10 y 4000 Mbps"
  }
}

variable "lb_max_bandwidth_mbps" {
  description = "Ancho de banda máximo en Mbps (solo flexible)"
  type        = number
  default     = 100
  validation {
    condition     = var.lb_max_bandwidth_mbps >= 10 && var.lb_max_bandwidth_mbps <= 4000
    error_message = "Debe estar entre 10 y 4000 Mbps"
  }
}

variable "ssl_certificate_ocid" {
  description = "OCID del certificado SSL en OCI Certificates"
  type        = string
  default     = null
}

variable "create_backend_health_checks" {
  description = "Crear health checks personalizados para backends"
  type        = bool
  default     = true
}

variable "health_check_interval_ms" {
  description = "Intervalo de health check en milisegundos"
  type        = number
  default     = 30000
  validation {
    condition     = var.health_check_interval_ms >= 1000 && var.health_check_interval_ms <= 300000
    error_message = "Debe estar entre 1000 y 300000 ms"
  }
}

variable "health_check_timeout_ms" {
  description = "Timeout de health check en milisegundos"
  type        = number
  default     = 3000
  validation {
    condition     = var.health_check_timeout_ms >= 1000 && var.health_check_timeout_ms <= 60000
    error_message = "Debe estar entre 1000 y 60000 ms"
  }
}

variable "health_check_healthy_threshold" {
  description = "Intentos exitosos necesarios para marcar como healthy"
  type        = number
  default     = 3
  validation {
    condition     = var.health_check_healthy_threshold >= 1 && var.health_check_healthy_threshold <= 10
    error_message = "Debe estar entre 1 y 10"
  }
}

variable "health_check_unhealthy_threshold" {
  description = "Intentos fallidos necesarios para marcar como unhealthy"
  type        = number
  default     = 3
  validation {
    condition     = var.health_check_unhealthy_threshold >= 1 && var.health_check_unhealthy_threshold <= 10
    error_message = "Debe estar entre 1 y 10"
  }
}

# ==============================================================================
# VARIABLES DE PERSISTENCIA DE SESIONES
# ==============================================================================

variable "enable_session_persistence" {
  description = "Habilitar persistencia de sesiones en Load Balancer"
  type        = bool
  default     = true
}

variable "session_persistence_timeout_seconds" {
  description = "Timeout de persistencia de sesiones en segundos"
  type        = number
  default     = 1800
  validation {
    condition     = var.session_persistence_timeout_seconds >= 1 && var.session_persistence_timeout_seconds <= 86400
    error_message = "Debe estar entre 1 y 86400 segundos (1 día)"
  }
}

# ==============================================================================
# VARIABLES DE SEGURIDAD
# ==============================================================================

variable "network_security_group_ids" {
  description = "IDs de Network Security Groups para el Load Balancer"
  type        = list(string)
  default     = []
}

variable "allowed_http_ports" {
  description = "Puertos HTTP permitidos"
  type        = list(number)
  default     = [80]
}

variable "allowed_https_ports" {
  description = "Puertos HTTPS permitidos"
  type        = list(number)
  default     = [443]
}

# ==============================================================================
# VARIABLES DE ETIQUETADO Y NOMENCLATURA
# ==============================================================================

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Nombre del proyecto para etiquetado"
  type        = string
  default     = "oke-lb-service"
}

variable "tags" {
  description = "Etiquetas de recursos"
  type        = map(string)
  default = {
    Architecture = "OKE-LoadBalancer-Service"
    Managed      = "Terraform"
    Purpose      = "Native-OCI-Load-Balancer"
  }
}

# ==============================================================================
# VARIABLES OPCIONALES AVANZADAS
# ==============================================================================

variable "enable_pod_security_policy" {
  description = "Habilitar Pod Security Policy"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Habilitar Network Policy"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Habilitar monitoreo con OCI Monitoring"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Habilitar logging con OCI Logging"
  type        = bool
  default     = true
}

variable "lb_algorithm" {
  description = "Algoritmo de balanceo de carga"
  type        = string
  default     = "ROUND_ROBIN"
  validation {
    condition     = contains(["ROUND_ROBIN", "LEAST_CONNECTIONS", "IP_HASH"], var.lb_algorithm)
    error_message = "Debe ser ROUND_ROBIN, LEAST_CONNECTIONS o IP_HASH"
  }
}
