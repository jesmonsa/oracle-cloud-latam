# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs — OKE Cluster Básico — Arquitectura de Referencia                 ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

output "cluster_id" {
  description = "OCID del cluster OKE"
  value       = oci_containerengine_cluster.cluster.id
}

output "cluster_name" {
  description = "Nombre del cluster OKE"
  value       = oci_containerengine_cluster.cluster.name
}

output "cluster_state" {
  description = "Estado actual del cluster"
  value       = oci_containerengine_cluster.cluster.state
}

output "k8s_version" {
  description = "Versión de Kubernetes en el cluster"
  value       = var.k8s_version
}

output "cluster_endpoints" {
  description = "Endpoints del cluster (API, FQDN, etc.)"
  value       = oci_containerengine_cluster.cluster.endpoints
}

output "nodepool_id" {
  description = "OCID del node pool"
  value       = oci_containerengine_node_pool.pool.id
}

output "nodepool_name" {
  description = "Nombre del node pool"
  value       = oci_containerengine_node_pool.pool.name
}

output "nodepool_size" {
  description = "Cantidad de worker nodes"
  value       = var.node_pool_size
}

output "node_shape" {
  description = "Shape de los worker nodes"
  value       = var.node_shape
}

output "vcn_id" {
  description = "OCID de la VCN"
  value       = module.red.vcn_id
}

output "subnet_api_id" {
  description = "OCID de la subnet del API Endpoint"
  value       = oci_core_subnet.api.id
}

output "subnet_lb_id" {
  description = "OCID de la subnet del Load Balancer"
  value       = oci_core_subnet.lb.id
}

output "subnet_nodes_id" {
  description = "OCID de la subnet del Node Pool"
  value       = oci_core_subnet.nodes.id
}

output "kubeconfig_cmd" {
  description = "Comando para descargar el kubeconfig"
  value       = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.cluster.id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT"
}

output "resumen" {
  description = "Resumen de la infraestructura desplegada"
  value       = <<-EOT

  ╔══════════════════════════════════════════════════════════════╗
  ║  OKE Cluster Básico — Arquitectura de Referencia           ║
  ╠══════════════════════════════════════════════════════════════╣
  ║                                                             ║
  ║  CLUSTER KUBERNETES                                        ║
  ║  ─────────────────────                                     ║
  ║  Nombre:         ${oci_containerengine_cluster.cluster.name}
  ║  Versión K8s:    ${var.k8s_version}
  ║  Estado:         ${oci_containerengine_cluster.cluster.state}
  ║  CNI:            Flannel Overlay                           ║
  ║                                                             ║
  ║  NODE POOL                                                 ║
  ║  ──────────                                                ║
  ║  Nombre:         ${oci_containerengine_node_pool.pool.name}
  ║  Workers:        ${var.node_pool_size} nodos
  ║  Shape:          ${var.node_shape}
  ║  OCPUs/RAM:      ${var.node_ocpus} OCPU / ${var.node_memoria_gb} GB
  ║                                                             ║
  ║  RED VIRTUAL                                               ║
  ║  ───────────────                                           ║
  ║  VCN CIDR:       ${var.vcn_cidr}
  ║  Subnet API:     ${var.subnet_api_cidr} (pública)
  ║  Subnet LB:      ${var.subnet_lb_cidr} (pública)
  ║  Subnet Nodes:   ${var.subnet_nodepool_cidr} (privada)
  ║                                                             ║
  ║  REDES K8s                                                 ║
  ║  ───────────                                               ║
  ║  Pods CIDR:      ${var.pods_cidr}
  ║  Services CIDR:  ${var.services_cidr}
  ║                                                             ║
  ║  PRÓXIMOS PASOS                                            ║
  ║  ──────────────                                            ║
  ║  1. Descargar kubeconfig:                                  ║
  ║     ${trimspace(oci_containerengine_cluster.cluster.endpoints[0].kubernetes)}
  ║                                                             ║
  ║  2. Esperar a que el cluster esté ACTIVE                  ║
  ║                                                             ║
  ║  3. Verificar nodos:                                       ║
  ║     kubectl get nodes                                      ║
  ║                                                             ║
  ║  4. Verificar pods del sistema:                            ║
  ║     kubectl get pods -n kube-system                        ║
  ║                                                             ║
  ╚══════════════════════════════════════════════════════════════╝

  EOT
}
