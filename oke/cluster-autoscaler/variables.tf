# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables de Terraform - OKE Cluster Autoscaler                             ║
# ║  Definición centralizada de parámetros configurables                         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE AUTENTICACIÓN OCI                                              │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "tenancy_ocid" {
  description = "OCID del Tenancy de Oracle Cloud Infrastructure"
  type        = string
  sensitive   = true
}

variable "current_user_ocid" {
  description = "OCID del usuario IAM actual"
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "Fingerprint de la clave API del usuario"
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Ruta al archivo de clave privada PEM"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Región de OCI donde desplegar"
  type        = string
  default     = "sa-santiago-1"
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE CONFIGURACIÓN OKE                                              │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "cluster_name" {
  description = "Nombre del cluster OKE"
  type        = string
  default     = "oke-autoscaler-cluster"
  validation {
    condition     = length(var.cluster_name) >= 3 && length(var.cluster_name) <= 255
    error_message = "El nombre del cluster debe tener entre 3 y 255 caracteres."
  }
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes a desplegar"
  type        = string
  default     = "v1.29"
}

variable "enable_kubernetes_dashboard" {
  description = "Habilitar dashboard de Kubernetes"
  type        = bool
  default     = true
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE NODE POOL CON AUTOSCALING                                      │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "node_pool_name" {
  description = "Nombre del node pool con autoscaling"
  type        = string
  default     = "pool-autoscaler"
}

variable "min_nodes" {
  description = "Número mínimo de nodos"
  type        = number
  default     = 2
  validation {
    condition     = var.min_nodes >= 1 && var.min_nodes <= 100
    error_message = "Los nodos mínimos deben estar entre 1 y 100."
  }
}

variable "max_nodes" {
  description = "Número máximo de nodos"
  type        = number
  default     = 10
  validation {
    condition     = var.max_nodes >= 1 && var.max_nodes <= 100
    error_message = "Los nodos máximos deben estar entre 1 y 100."
  }
}

variable "initial_node_count" {
  description = "Número inicial de nodos (entre min y max)"
  type        = number
  default     = 3
  validation {
    condition     = var.initial_node_count >= 1 && var.initial_node_count <= 100
    error_message = "El número inicial debe estar entre 1 y 100."
  }
}

variable "node_shape" {
  description = "Shape de las instancias de nodos"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "node_ocpus" {
  description = "Número de OCPUs para nodos Flex"
  type        = number
  default     = 2
  validation {
    condition     = var.node_ocpus >= 1 && var.node_ocpus <= 64
    error_message = "Los OCPUs deben estar entre 1 y 64."
  }
}

variable "node_memory_gb" {
  description = "Memoria en GB para nodos Flex"
  type        = number
  default     = 16
  validation {
    condition     = var.node_memory_gb >= 1 && var.node_memory_gb <= 1024
    error_message = "La memoria debe estar entre 1 y 1024 GB."
  }
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE CLUSTER AUTOSCALER                                             │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "enable_cluster_autoscaler" {
  description = "Habilitar Cluster Autoscaler"
  type        = bool
  default     = true
}

variable "autoscaler_namespace" {
  description = "Namespace donde desplegar Cluster Autoscaler"
  type        = string
  default     = "kube-system"
}

variable "autoscaler_helm_release_name" {
  description = "Nombre de la release de Helm"
  type        = string
  default     = "cluster-autoscaler"
}

variable "autoscaler_helm_chart_version" {
  description = "Versión del chart de Helm para Cluster Autoscaler"
  type        = string
  default     = "9.29.0"
}

variable "autoscaler_replicas" {
  description = "Número de réplicas del Cluster Autoscaler"
  type        = number
  default     = 2
  validation {
    condition     = var.autoscaler_replicas >= 1 && var.autoscaler_replicas <= 5
    error_message = "El número de réplicas debe estar entre 1 y 5."
  }
}

variable "scale_down_enabled" {
  description = "Habilitar scale-down de nodos"
  type        = bool
  default     = true
}

variable "scale_down_delay_after_add" {
  description = "Minutos antes de considerar scale-down después de agregar un nodo"
  type        = number
  default     = 10
  validation {
    condition     = var.scale_down_delay_after_add >= 1 && var.scale_down_delay_after_add <= 60
    error_message = "El delay debe estar entre 1 y 60 minutos."
  }
}

variable "scale_down_delay_after_failure" {
  description = "Minutos antes de reintentar scale-down después de fallo"
  type        = number
  default     = 3
  validation {
    condition     = var.scale_down_delay_after_failure >= 1 && var.scale_down_delay_after_failure <= 30
    error_message = "El delay debe estar entre 1 y 30 minutos."
  }
}

variable "scale_down_utilization_threshold" {
  description = "Umbral de utilización (0.0-1.0) para considerar nodo infrautilizado"
  type        = number
  default     = 0.65
  validation {
    condition     = var.scale_down_utilization_threshold >= 0.1 && var.scale_down_utilization_threshold <= 0.9
    error_message = "El umbral debe estar entre 0.1 y 0.9."
  }
}

variable "scale_down_unneeded_time" {
  description = "Minutos que un nodo debe estar infrautilizado antes de ser candidato a escala"
  type        = number
  default     = 10
  validation {
    condition     = var.scale_down_unneeded_time >= 1 && var.scale_down_unneeded_time <= 60
    error_message = "El tiempo debe estar entre 1 y 60 minutos."
  }
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE METRICS SERVER Y HPA                                           │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "enable_metrics_server" {
  description = "Habilitar Metrics Server para HPA"
  type        = bool
  default     = true
}

variable "metrics_server_namespace" {
  description = "Namespace para Metrics Server"
  type        = string
  default     = "kube-system"
}

variable "enable_horizontal_pod_autoscaler_example" {
  description = "Desplegar ejemplo de HPA"
  type        = bool
  default     = true
}

variable "hpa_namespace" {
  description = "Namespace para el ejemplo de HPA"
  type        = string
  default     = "default"
}

variable "hpa_target_cpu_utilization" {
  description = "Utilización de CPU objetivo para HPA (%)"
  type        = number
  default     = 70
  validation {
    condition     = var.hpa_target_cpu_utilization >= 10 && var.hpa_target_cpu_utilization <= 100
    error_message = "La utilización debe estar entre 10 y 100%."
  }
}

variable "hpa_target_memory_utilization" {
  description = "Utilización de memoria objetivo para HPA (%)"
  type        = number
  default     = 80
  validation {
    condition     = var.hpa_target_memory_utilization >= 10 && var.hpa_target_memory_utilization <= 100
    error_message = "La utilización debe estar entre 10 y 100%."
  }
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE CONFIGURACIÓN VCN                                              │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "vcn_name" {
  description = "Nombre de la VCN"
  type        = string
  default     = "vcn-oke-autoscaler"
}

variable "vcn_cidr_block" {
  description = "Bloque CIDR de la VCN"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vcn_cidr_block, 0))
    error_message = "Debe ser un bloque CIDR válido."
  }
}

variable "subnet_cidr_block" {
  description = "Bloque CIDR de la subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE MONITOREO                                                      │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "enable_monitoring" {
  description = "Habilitar OCI Monitoring"
  type        = bool
  default     = true
}

variable "monitoring_namespace" {
  description = "Namespace para monitoreo"
  type        = string
  default     = "monitoring"
}

variable "enable_prometheus" {
  description = "Desplegar Prometheus con Cluster Autoscaler"
  type        = bool
  default     = true
}

variable "prometheus_retention_days" {
  description = "Días de retención de métricas en Prometheus"
  type        = number
  default     = 15
  validation {
    condition     = var.prometheus_retention_days >= 1 && var.prometheus_retention_days <= 365
    error_message = "La retención debe estar entre 1 y 365 días."
  }
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE ETIQUETADO Y METADATOS                                         │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "tags" {
  description = "Etiquetas aplicadas a todos los recursos"
  type        = map(string)
  default = {
    ManagedBy  = "Terraform"
    Proyecto   = "OKE-Autoscaler"
    Ambiente   = "Producción"
    VersionArq = "1.0"
    Autoscaling = "true"
  }
}

variable "freeform_tags" {
  description = "Tags de forma libre para clasificación"
  type        = map(string)
  default = {
    FinanceCenter = "Engineering"
    CostCenter    = "Autoscaling"
    Compliance    = "ISO27001"
  }
}
