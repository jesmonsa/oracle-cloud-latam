# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs de Terraform - OKE Cluster Autoscaler                               ║
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

# output "node_pool_id" {
#   description = "OCID del node pool con autoscaling"
#   value       = oci_containerengine_node_pool.autoscaler_pool.id
# }

# output "node_pool_autoscaling_config" {
#   description = "Configuración de autoscaling del node pool"
#   value = {
#     min_nodes    = var.min_nodes
#     max_nodes    = var.max_nodes
#     initial_nodes = var.initial_node_count
#   }
# }

# output "cluster_autoscaler_release_name" {
#   description = "Nombre de la release de Helm de Cluster Autoscaler"
#   value       = var.autoscaler_helm_release_name
# }

# output "cluster_autoscaler_namespace" {
#   description = "Namespace donde está desplegado Cluster Autoscaler"
#   value       = var.autoscaler_namespace
# }

# output "metrics_server_status" {
#   description = "Estado de Metrics Server"
#   value       = "Deployado en ${var.metrics_server_namespace}"
# }

# output "hpa_example_deployment" {
#   description = "Nombre del deployment de ejemplo para HPA"
#   value       = "hpa-example"
# }

# output "autoscaler_configuration" {
#   description = "Parámetros de configuración del autoscaler"
#   value = {
#     scale_down_enabled           = var.scale_down_enabled
#     scale_down_delay_after_add   = "${var.scale_down_delay_after_add}m"
#     scale_down_utilization_threshold = var.scale_down_utilization_threshold
#     scale_down_unneeded_time     = "${var.scale_down_unneeded_time}m"
#   }
# }

# output "hpa_configuration" {
#   description = "Parámetros de HPA"
#   value = {
#     target_cpu_utilization    = "${var.hpa_target_cpu_utilization}%"
#     target_memory_utilization = "${var.hpa_target_memory_utilization}%"
#   }
# }

# output "vcn_id" {
#   description = "OCID de la VCN"
#   value       = oci_core_vcn.oke_vcn.id
# }

# output "subnet_id" {
#   description = "OCID de la subnet"
#   value       = oci_core_subnet.oke_subnet.id
# }

# output "prometheus_service_endpoint" {
#   description = "Endpoint del servicio Prometheus"
#   value       = try(kubernetes_service.prometheus[0].status[0].load_balancer[0].ingress[0].ip, "Pendiente de provisión")
# }
