# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs — Arquitectura 13: OKE (Kubernetes)                               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

output "cluster_id" {
  description = "OCID del cluster OKE"
  value       = oci_containerengine_cluster.cluster.id
}

output "cluster_name" {
  description = "Nombre del cluster"
  value       = oci_containerengine_cluster.cluster.name
}

output "cluster_state" {
  description = "Estado del cluster"
  value       = oci_containerengine_cluster.cluster.state
}

output "k8s_version" {
  description = "Versión de Kubernetes"
  value       = var.k8s_version
}

output "cluster_endpoints" {
  description = "Endpoints del cluster"
  value       = oci_containerengine_cluster.cluster.endpoints
}

output "nodepool_id" {
  description = "OCID del node pool"
  value       = oci_containerengine_node_pool.pool.id
}

output "nodepool_size" {
  description = "Tamaño del node pool"
  value       = var.node_pool_size
}

output "resumen" {
  description = "Resumen de la arquitectura"
  value       = <<-EOT

  ╔══════════════════════════════════════════════════════════════╗
  ║  Arquitectura 13 — OKE (Oracle Kubernetes Engine)          ║
  ╠══════════════════════════════════════════════════════════════╣
  ║                                                            ║
  ║  Cluster:        ${local.prefijo}-cluster
  ║  K8s Version:    ${var.k8s_version}
  ║  Estado:         ${oci_containerengine_cluster.cluster.state}
  ║                                                            ║
  ║  Node Pool:      ${var.node_pool_size} worker node(s)
  ║  Node Shape:     ${var.node_shape}
  ║  Node OCPUs:     ${var.node_ocpus} | RAM: ${var.node_memoria_gb} GB
  ║                                                            ║
  ║  Subnets:                                                  ║
  ║    API:          ${var.subnet_api_cidr} (pública)
  ║    LB Services:  ${var.subnet_lb_cidr} (pública)
  ║    Nodes:        ${var.subnet_nodepool_cidr} (privada)
  ║                                                            ║
  ║  Pod CIDR:       ${var.pods_cidr}
  ║  Service CIDR:   ${var.services_cidr}
  ║  CNI:            Flannel Overlay                           ║
  ╚══════════════════════════════════════════════════════════════╝

  EOT
}
