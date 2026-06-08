# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs de Terraform - OKE Virtual Nodes                                    ║
# ║  Valores exportados para integración y consumo posterior                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# output "cluster_id" {
#   description = "OCID del cluster OKE ENHANCED"
#   value       = oci_containerengine_cluster.oke_cluster_enhanced.id
# }

# output "cluster_kubeconfig" {
#   description = "Kubeconfig del cluster para kubectl"
#   value       = oci_containerengine_cluster.oke_cluster_enhanced.kube_config_expiration_date
#   sensitive   = true
# }

# output "virtual_node_pool_id" {
#   description = "OCID del virtual node pool"
#   value       = oci_containerengine_virtual_node_pool.virtual_nodes.id
# }

# output "virtual_nodes_count" {
#   description = "Número de pods virtuales permitidos"
#   value       = var.virtual_node_count
# }

# output "pod_shape" {
#   description = "Shape de los pods virtuales"
#   value       = var.pod_shape
# }

# output "pod_resources" {
#   description = "Recursos por pod (OCPUs y memoria)"
#   value = {
#     ocpus  = var.pod_ocpus
#     memory = var.pod_memory_gb
#   }
# }

# output "container_instances_compartment" {
#   description = "Compartment para Container Instances backend"
#   value       = var.container_instances_compartment_id
# }

# output "app_namespace" {
#   description = "Namespace de Kubernetes para Virtual Workloads"
#   value       = var.app_namespace
# }

# output "virtual_node_taint" {
#   description = "Taint aplicado a Virtual Nodes"
#   value = {
#     key    = var.virtual_node_taint_key
#     value  = var.virtual_node_taint_value
#     effect = "NoSchedule"
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

# output "estimated_cost_per_pod_hour" {
#   description = "Costo estimado por hora de ejecución de un pod"
#   value       = "Aproximadamente USD $0.0003 por OCPU-hora"
# }
