# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs — Track OKE Lección 02: Node Pools Flex (E4 x86 + A1 ARM)        ║
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

# ─── Node Pool x86 ───────────────────────────────────────────────────────────

output "np_x86_id" {
  description = "OCID del node pool x86 (E4 Flex)"
  value       = oci_containerengine_node_pool.np_x86.id
}

output "np_x86_name" {
  description = "Nombre del node pool x86"
  value       = oci_containerengine_node_pool.np_x86.name
}

# ─── Node Pool ARM ───────────────────────────────────────────────────────────

output "np_arm_id" {
  description = "OCID del node pool ARM (A1 Flex)"
  value       = oci_containerengine_node_pool.np_arm.id
}

output "np_arm_name" {
  description = "Nombre del node pool ARM"
  value       = oci_containerengine_node_pool.np_arm.name
}

# ─── Utilidades ──────────────────────────────────────────────────────────────

output "kubeconfig_cmd" {
  description = "Comando para obtener el kubeconfig"
  value       = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.cluster.id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT"
}

output "resumen" {
  description = "Resumen de la lección"
  value       = <<-EOT

  ╔══════════════════════════════════════════════════════════════╗
  ║  Track OKE — Lección 02: Node Pools Flex (E4 + A1)         ║
  ╠══════════════════════════════════════════════════════════════╣
  ║                                                            ║
  ║  Cluster:        ${oci_containerengine_cluster.cluster.name}
  ║  K8s Version:    ${var.k8s_version}
  ║  Estado:         ${oci_containerengine_cluster.cluster.state}
  ║  CNI:            Flannel Overlay
  ║                                                            ║
  ║  Node Pool x86:  ${oci_containerengine_node_pool.np_x86.name}
  ║    Shape:        ${var.np_x86_shape}
  ║    Workers:      ${var.np_x86_size} | OCPUs: ${var.np_x86_ocpus} | RAM: ${var.np_x86_memoria_gb} GB
  ║                                                            ║
  ║  Node Pool ARM:  ${oci_containerengine_node_pool.np_arm.name}
  ║    Shape:        ${var.np_arm_shape}
  ║    Workers:      ${var.np_arm_size} | OCPUs: ${var.np_arm_ocpus} | RAM: ${var.np_arm_memoria_gb} GB
  ║                                                            ║
  ║  Subnets:                                                  ║
  ║    API:          ${var.subnet_api_cidr} (pública)
  ║    LB Services:  ${var.subnet_lb_cidr} (pública)
  ║    Nodes:        ${var.subnet_nodepool_cidr} (privada)
  ║                                                            ║
  ║  Tip: Usa nodeSelector o tolerations para dirigir          ║
  ║  workloads a un pool específico (x86 vs ARM).              ║
  ║                                                            ║
  ║  Siguiente paso:                                           ║
  ║    kubectl get nodes -L kubernetes.io/arch                 ║
  ╚══════════════════════════════════════════════════════════════╝

  EOT
}
