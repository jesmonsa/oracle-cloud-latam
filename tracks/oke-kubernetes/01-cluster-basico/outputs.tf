# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs — Track OKE Lección 01: Cluster Básico (Flannel CNI)              ║
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
  description = "Endpoints del cluster (K8s API)"
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

output "kubeconfig_cmd" {
  description = "Comando para obtener el kubeconfig"
  value       = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.cluster.id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT"
}

output "resumen" {
  description = "Resumen de la lección"
  value       = <<-EOT

  ╔══════════════════════════════════════════════════════════════╗
  ║  Track OKE — Lección 01: Cluster Básico (Flannel CNI)      ║
  ╠══════════════════════════════════════════════════════════════╣
  ║                                                            ║
  ║  Cluster:        ${oci_containerengine_cluster.cluster.name}
  ║  K8s Version:    ${var.k8s_version}
  ║  Estado:         ${oci_containerengine_cluster.cluster.state}
  ║  CNI:            Flannel Overlay
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
  ║                                                            ║
  ║  Siguiente paso:                                           ║
  ║    Ejecuta el comando 'kubeconfig_cmd' para conectarte     ║
  ║    kubectl get nodes                                       ║
  ╚══════════════════════════════════════════════════════════════╝

  EOT
}
