# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  INGRESS NGINX - VARIABLES DE CONFIGURACIÓN                                  ║
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
  description = "Región de Oracle Cloud (ej: sa-santiago-1, sa-vinhedo-1)"
  type        = string
  default     = "sa-santiago-1"
}

# ==============================================================================
# VARIABLES DE CONFIGURACIÓN DEL CLÚSTER OKE
# ==============================================================================

variable "cluster_name" {
  description = "Nombre del clúster OKE"
  type        = string
  default     = "oke-ingress-nginx"
}

variable "cluster_version" {
  description = "Versión de Kubernetes"
  type        = string
  default     = "1.29"
}

variable "compartment_id" {
  description = "OCID del compartimiento donde se creará el clúster"
  type        = string
}

variable "vcn_cidr_block" {
  description = "Bloque CIDR de la VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "k8s_subnet_cidr" {
  description = "Bloque CIDR de la subred de Kubernetes"
  type        = string
  default     = "10.0.1.0/24"
}

variable "worker_subnet_cidr" {
  description = "Bloque CIDR de la subred de nodos de trabajo"
  type        = string
  default     = "10.0.2.0/24"
}

variable "lb_subnet_cidr" {
  description = "Bloque CIDR de la subred para Load Balancer"
  type        = string
  default     = "10.0.3.0/24"
}

variable "node_pool_size" {
  description = "Cantidad de nodos en el pool"
  type        = number
  default     = 3
}

variable "node_shape" {
  description = "Forma de los nodos (ej: VM.Standard.E4.Flex)"
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
# VARIABLES DE INGRESS NGINX Y CERT-MANAGER
# ==============================================================================

variable "ingress_class" {
  description = "Nombre de la clase de ingress"
  type        = string
  default     = "nginx"
}

variable "nginx_helm_version" {
  description = "Versión del chart de NGINX Ingress Controller"
  type        = string
  default     = "4.8.0"
}

variable "cert_manager_version" {
  description = "Versión del chart de cert-manager"
  type        = string
  default     = "v1.13.0"
}

variable "tls_enabled" {
  description = "Habilitar TLS automático con Let's Encrypt"
  type        = bool
  default     = true
}

variable "cert_manager_email" {
  description = "Email para registro de Let's Encrypt"
  type        = string
}

variable "domain_name" {
  description = "Nombre de dominio para los certificados"
  type        = string
}

variable "lets_encrypt_environment" {
  description = "Entorno de Let's Encrypt (production o staging)"
  type        = string
  default     = "production"
  validation {
    condition     = contains(["production", "staging"], var.lets_encrypt_environment)
    error_message = "Debe ser 'production' o 'staging'"
  }
}

variable "create_load_balancer" {
  description = "Crear Load Balancer de OCI para el ingress"
  type        = bool
  default     = true
}

variable "lb_shape" {
  description = "Forma del Load Balancer (flexible, 100Mbps, 400Mbps)"
  type        = string
  default     = "flexible"
}

variable "lb_is_private" {
  description = "Load Balancer privado (true) o público (false)"
  type        = bool
  default     = false
}

variable "lb_min_bandwidth_mbps" {
  description = "Ancho de banda mínimo en Mbps (solo para flexible)"
  type        = number
  default     = 10
}

variable "lb_max_bandwidth_mbps" {
  description = "Ancho de banda máximo en Mbps (solo para flexible)"
  type        = number
  default     = 100
}

# ==============================================================================
# VARIABLES DE ETIQUETADO Y NOMENCLATURA
# ==============================================================================

variable "environment" {
  description = "Ambiente de despliegue (prod, staging, dev)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Nombre del proyecto para etiquetado"
  type        = string
  default     = "oke-ingress-nginx"
}

variable "tags" {
  description = "Etiquetas de recursos"
  type        = map(string)
  default = {
    Architecture = "OKE-Ingress-NGINX"
    Managed      = "Terraform"
    Purpose      = "Production-Grade Ingress Controller"
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

variable "node_image_id" {
  description = "ID de imagen personalizada para los nodos (opcional)"
  type        = string
  default     = null
}

variable "additional_kube_proxy_config" {
  description = "Configuración adicional de kube-proxy"
  type        = map(string)
  default     = {}
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
