# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs de Terraform - OKE Observabilidad Completa                          ║
# ║  Valores exportados para integración y consumo posterior                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# output "cluster_id" {
#   description = "OCID del cluster OKE"
#   value       = oci_containerengine_cluster.oke_cluster.id
# }

# output "cluster_kubeconfig" {
#   description = "Kubeconfig del cluster para kubectl"
#   value       = oci_containerengine_cluster.oke_cluster.kube_config_expiration_date
#   sensitive   = true
# }

# output "monitoring_namespace" {
#   description = "Namespace donde está la pila de observabilidad"
#   value       = var.prometheus_namespace
# }

# output "prometheus_helm_release" {
#   description = "Nombre de la release de Helm de Prometheus"
#   value       = var.prometheus_helm_release_name
# }

# output "grafana_helm_release" {
#   description = "Nombre de la release de Helm de Grafana"
#   value       = var.grafana_helm_release_name
# }

# output "loki_helm_release" {
#   description = "Nombre de la release de Helm de Loki"
#   value       = var.loki_helm_release_name
# }

# output "prometheus_url" {
#   description = "URL de acceso a Prometheus (via port-forward)"
#   value       = "kubectl port-forward -n ${var.prometheus_namespace} svc/prometheus 9090:9090"
# }

# output "grafana_url" {
#   description = "URL de acceso a Grafana (via port-forward)"
#   value       = "kubectl port-forward -n ${var.grafana_namespace} svc/grafana 3000:80"
# }

# output "loki_url" {
#   description = "URL de acceso a Loki (via port-forward)"
#   value       = "kubectl port-forward -n ${var.loki_namespace} svc/loki 3100:3100"
# }

# output "prometheus_storage_size" {
#   description = "Tamaño del almacenamiento de Prometheus"
#   value       = "${var.prometheus_storage_size_gb}Gi"
# }

# output "loki_storage_size" {
#   description = "Tamaño del almacenamiento de Loki"
#   value       = "${var.loki_storage_size_gb}Gi"
# }

# output "retention_configuration" {
#   description = "Configuración de retención de datos"
#   value = {
#     prometheus_days = var.prometheus_retention_days
#     loki_days       = var.loki_retention_days
#   }
# }

# output "dashboards_imported" {
#   description = "Dashboards de Grafana disponibles"
#   value = [
#     "OKE Cluster Overview",
#     "Node Exporter (Host)",
#     "Prometheus",
#     "Pod Resources",
#     "Loki Logs"
#   ]
# }

# output "vcn_id" {
#   description = "OCID de la VCN"
#   value       = oci_core_vcn.oke_vcn.id
# }

# output "subnet_id" {
#   description = "OCID de la subnet"
#   value       = oci_core_subnet.oke_subnet.id
# }

# output "oci_monitoring_compartment" {
#   description = "Compartment para métricas de OCI Monitoring"
#   value       = var.oci_monitoring_compartment_id
# }
