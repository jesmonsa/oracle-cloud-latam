# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs de Terraform - OKE con OCIR Registry                                ║
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
#   description = "OCID del node pool"
#   value       = oci_containerengine_node_pool.worker_pool.id
# }

# output "ocir_repository_url" {
#   description = "URL del repositorio OCIR"
#   value       = "${var.region}.ocir.io/${var.registry_namespace}/${var.repository_name}"
# }

# output "ocir_repository_id" {
#   description = "OCID del repositorio OCIR"
#   value       = oci_artifacts_container_repository.ocir_repo.id
# }

# output "kubernetes_namespace_id" {
#   description = "ID del namespace de Kubernetes"
#   value       = kubernetes_namespace.ocir_workloads.id
# }

# output "image_pull_secret_name" {
#   description = "Nombre del secret para pull de imágenes"
#   value       = kubernetes_secret.ocir_pull_secret.metadata[0].name
# }

# output "vcn_id" {
#   description = "OCID de la VCN"
#   value       = oci_core_vcn.oke_vcn.id
# }

# output "subnet_id" {
#   description = "OCID de la subnet"
#   value       = oci_core_subnet.oke_subnet.id
# }

# output "load_balancer_ip" {
#   description = "IP pública del Load Balancer (si aplica)"
#   value       = try(oci_core_instance.lb_instance.public_ip, "No disponible")
# }
