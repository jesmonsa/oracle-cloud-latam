# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Variables de Terraform - OKE Observabilidad Completa                        ║
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
  default     = "oke-observabilidad-cluster"
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

variable "node_pool_name" {
  description = "Nombre del node pool"
  type        = string
  default     = "pool-observabilidad"
}

variable "initial_node_count" {
  description = "Número inicial de nodos"
  type        = number
  default     = 3
  validation {
    condition     = var.initial_node_count >= 1 && var.initial_node_count <= 100
    error_message = "El número de nodos debe estar entre 1 y 100."
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
  default     = 4
  validation {
    condition     = var.node_ocpus >= 1 && var.node_ocpus <= 64
    error_message = "Los OCPUs deben estar entre 1 y 64."
  }
}

variable "node_memory_gb" {
  description = "Memoria en GB para nodos Flex"
  type        = number
  default     = 32
  validation {
    condition     = var.node_memory_gb >= 1 && var.node_memory_gb <= 1024
    error_message = "La memoria debe estar entre 1 y 1024 GB."
  }
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE CONFIGURACIÓN VCN                                              │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "vcn_name" {
  description = "Nombre de la VCN"
  type        = string
  default     = "vcn-oke-observabilidad"
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
# │ VARIABLES DE PROMETHEUS                                                     │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "enable_prometheus" {
  description = "Habilitar Prometheus"
  type        = bool
  default     = true
}

variable "prometheus_namespace" {
  description = "Namespace para Prometheus"
  type        = string
  default     = "monitoring"
}

variable "prometheus_helm_release_name" {
  description = "Nombre de release de Helm para Prometheus"
  type        = string
  default     = "prometheus"
}

variable "prometheus_helm_chart_version" {
  description = "Versión del chart de Prometheus"
  type        = string
  default     = "25.3.1"
}

variable "prometheus_retention_days" {
  description = "Días de retención de datos en Prometheus"
  type        = number
  default     = 15
  validation {
    condition     = var.prometheus_retention_days >= 1 && var.prometheus_retention_days <= 365
    error_message = "La retención debe estar entre 1 y 365 días."
  }
}

variable "prometheus_storage_size_gb" {
  description = "Tamaño del almacenamiento persistente para Prometheus"
  type        = number
  default     = 50
  validation {
    condition     = var.prometheus_storage_size_gb >= 10 && var.prometheus_storage_size_gb <= 1000
    error_message = "El almacenamiento debe estar entre 10 y 1000 GB."
  }
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE GRAFANA                                                        │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "enable_grafana" {
  description = "Habilitar Grafana"
  type        = bool
  default     = true
}

variable "grafana_namespace" {
  description = "Namespace para Grafana"
  type        = string
  default     = "monitoring"
}

variable "grafana_helm_release_name" {
  description = "Nombre de release de Helm para Grafana"
  type        = string
  default     = "grafana"
}

variable "grafana_helm_chart_version" {
  description = "Versión del chart de Grafana"
  type        = string
  default     = "7.0.8"
}

variable "grafana_admin_password" {
  description = "Contraseña del admin de Grafana"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.grafana_admin_password) >= 8
    error_message = "La contraseña debe tener al menos 8 caracteres."
  }
}

variable "grafana_storage_size_gb" {
  description = "Tamaño del almacenamiento para Grafana"
  type        = number
  default     = 10
  validation {
    condition     = var.grafana_storage_size_gb >= 5 && var.grafana_storage_size_gb <= 100
    error_message = "El almacenamiento debe estar entre 5 y 100 GB."
  }
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE LOKI                                                           │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "enable_loki" {
  description = "Habilitar Loki (Log Aggregation)"
  type        = bool
  default     = true
}

variable "loki_namespace" {
  description = "Namespace para Loki"
  type        = string
  default     = "monitoring"
}

variable "loki_helm_release_name" {
  description = "Nombre de release de Helm para Loki"
  type        = string
  default     = "loki"
}

variable "loki_helm_chart_version" {
  description = "Versión del chart de Loki"
  type        = string
  default     = "5.41.2"
}

variable "loki_storage_size_gb" {
  description = "Tamaño del almacenamiento para Loki"
  type        = number
  default     = 30
  validation {
    condition     = var.loki_storage_size_gb >= 10 && var.loki_storage_size_gb <= 500
    error_message = "El almacenamiento debe estar entre 10 y 500 GB."
  }
}

variable "loki_retention_days" {
  description = "Días de retención de logs en Loki"
  type        = number
  default     = 7
  validation {
    condition     = var.loki_retention_days >= 1 && var.loki_retention_days <= 365
    error_message = "La retención debe estar entre 1 y 365 días."
  }
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE ALERTING (AlertManager)                                        │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "enable_alert_manager" {
  description = "Habilitar AlertManager"
  type        = bool
  default     = true
}

variable "alertmanager_storage_size_gb" {
  description = "Tamaño del almacenamiento para AlertManager"
  type        = number
  default     = 5
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE OCI MONITORING INTEGRATION                                    │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "oci_monitoring_enabled" {
  description = "Habilitar integración con OCI Monitoring"
  type        = bool
  default     = true
}

variable "oci_monitoring_namespace" {
  description = "OCID del namespace de OCI Monitoring"
  type        = string
  sensitive   = true
  default     = ""
}

variable "oci_monitoring_compartment_id" {
  description = "OCID del compartment para métricas"
  type        = string
  sensitive   = true
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE DASHBOARDS                                                     │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "enable_grafana_dashboards" {
  description = "Desplegar dashboards preconfigurados en Grafana"
  type        = bool
  default     = true
}

variable "grafana_dashboard_provider_namespace" {
  description = "Namespace para proveedores de dashboards"
  type        = string
  default     = "monitoring"
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE SERVICEMONITOR Y PODMONITOR                                    │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "enable_servicemonitor" {
  description = "Habilitar ServiceMonitor CRDs para autodiscovery"
  type        = bool
  default     = true
}

variable "enable_podmonitor" {
  description = "Habilitar PodMonitor CRDs para autodiscovery"
  type        = bool
  default     = true
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ VARIABLES DE ETIQUETADO Y METADATOS                                         │
# └──────────────────────────────────────────────────────────────────────────────┘

variable "tags" {
  description = "Etiquetas aplicadas a todos los recursos"
  type        = map(string)
  default = {
    ManagedBy    = "Terraform"
    Proyecto     = "OKE-Observabilidad"
    Ambiente     = "Producción"
    VersionArq   = "1.0"
    Observabilidad = "true"
  }
}

variable "freeform_tags" {
  description = "Tags de forma libre para clasificación"
  type        = map(string)
  default = {
    FinanceCenter  = "Engineering"
    CostCenter     = "Observability"
    Compliance     = "ISO27001"
    DataRetention  = "ISO"
  }
}
