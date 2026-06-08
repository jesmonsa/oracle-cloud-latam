# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  OKE LOAD BALANCER SERVICE - OUTPUTS (PLACEHOLDERS)                          ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# output "cluster_id" {
#   description = "ID del clúster OKE"
#   value       = oci_containerengine_cluster.oke_cluster.id
# }

# output "load_balancer_id" {
#   description = "ID del Load Balancer de OCI"
#   value       = oci_load_balancer_load_balancer.main_lb.id
# }

# output "load_balancer_ip_address" {
#   description = "Dirección IP del Load Balancer"
#   value       = oci_load_balancer_load_balancer.main_lb.ip_address_details[0].ip_address
# }

# output "load_balancer_shape" {
#   description = "Forma del Load Balancer"
#   value       = oci_load_balancer_load_balancer.main_lb.shape
# }

# output "vcn_id" {
#   description = "ID de la Virtual Cloud Network"
#   value       = oci_core_vcn.oke_vcn.id
# }

# output "k8s_subnet_id" {
#   description = "ID de la subred de Kubernetes"
#   value       = oci_core_subnet.k8s_subnet.id
# }

# output "worker_subnet_id" {
#   description = "ID de la subred de nodos de trabajo"
#   value       = oci_core_subnet.worker_subnet.id
# }

# output "node_pool_id" {
#   description = "ID del pool de nodos"
#   value       = oci_containerengine_node_pool.oke_node_pool.id
# }

# output "backend_set_name" {
#   description = "Nombre del Backend Set del Load Balancer"
#   value       = oci_load_balancer_backend_set.main.name
# }

# output "listener_http_id" {
#   description = "ID del listener HTTP"
#   value       = oci_load_balancer_listener.http.id
# }

# output "listener_https_id" {
#   description = "ID del listener HTTPS"
#   value       = oci_load_balancer_listener.https[0].id
# }

# output "kubeconfig_path" {
#   description = "Comando para obtener kubeconfig"
#   value       = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.oke_cluster.id} --file $HOME/.kube/config"
# }

# output "environment" {
#   description = "Ambiente de despliegue"
#   value       = var.environment
# }

# output "tags" {
#   description = "Etiquetas aplicadas"
#   value       = var.tags
# }
