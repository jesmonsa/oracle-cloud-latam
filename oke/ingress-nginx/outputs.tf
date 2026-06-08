# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  INGRESS NGINX - OUTPUTS (PLACEHOLDERS)                                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# OUTPUTS DEL CLÚSTER OKE
# ==============================================================================

# output "cluster_id" {
#   description = "ID del clúster OKE"
#   value       = oci_containerengine_cluster.oke_cluster.id
# }

# output "cluster_name" {
#   description = "Nombre del clúster OKE"
#   value       = oci_containerengine_cluster.oke_cluster.name
# }

# output "kubernetes_version" {
#   description = "Versión de Kubernetes del clúster"
#   value       = oci_containerengine_cluster.oke_cluster.kubernetes_version
# }

# output "cluster_endpoints" {
#   description = "Endpoints del clúster"
#   value       = oci_containerengine_cluster.oke_cluster.endpoints
# }

# ==============================================================================
# OUTPUTS DE LA VCN Y NETWORKING
# ==============================================================================

# output "vcn_id" {
#   description = "ID de la Virtual Cloud Network"
#   value       = oci_core_vcn.oke_vcn.id
# }

# output "vcn_cidr" {
#   description = "CIDR de la VCN"
#   value       = oci_core_vcn.oke_vcn.cidr_blocks
# }

# output "k8s_subnet_id" {
#   description = "ID de la subred de Kubernetes"
#   value       = oci_core_subnet.k8s_subnet.id
# }

# output "worker_subnet_id" {
#   description = "ID de la subred de nodos de trabajo"
#   value       = oci_core_subnet.worker_subnet.id
# }

# output "lb_subnet_id" {
#   description = "ID de la subred de Load Balancer"
#   value       = oci_core_subnet.lb_subnet.id
# }

# ==============================================================================
# OUTPUTS DEL NODE POOL
# ==============================================================================

# output "node_pool_id" {
#   description = "ID del pool de nodos"
#   value       = oci_containerengine_node_pool.oke_node_pool.id
# }

# output "node_pool_name" {
#   description = "Nombre del pool de nodos"
#   value       = oci_containerengine_node_pool.oke_node_pool.name
# }

# output "nodes_count" {
#   description = "Cantidad inicial de nodos"
#   value       = oci_containerengine_node_pool.oke_node_pool.initial_node_labels[0].value
# }

# ==============================================================================
# OUTPUTS DE NGINX INGRESS CONTROLLER
# ==============================================================================

# output "ingress_class" {
#   description = "Nombre de la clase de ingress"
#   value       = var.ingress_class
# }

# output "nginx_service_ip" {
#   description = "IP del servicio NGINX Ingress Controller"
#   value       = kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].ip
# }

# output "nginx_service_endpoint" {
#   description = "Endpoint del servicio NGINX"
#   value       = "http://${kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].ip}"
# }

# ==============================================================================
# OUTPUTS DEL LOAD BALANCER
# ==============================================================================

# output "load_balancer_id" {
#   description = "ID del Load Balancer de OCI"
#   value       = oci_load_balancer_load_balancer.ingress_lb[0].id
# }

# output "load_balancer_ip_address" {
#   description = "Dirección IP pública del Load Balancer"
#   value       = oci_load_balancer_load_balancer.ingress_lb[0].ip_address_details[0].ip_address
# }

# output "load_balancer_fqdn" {
#   description = "FQDN del Load Balancer"
#   value       = oci_load_balancer_load_balancer.ingress_lb[0].ip_address_details[0].public_ip_address
# }

# ==============================================================================
# OUTPUTS DE CERT-MANAGER Y CERTIFICADOS
# ==============================================================================

# output "cert_manager_namespace" {
#   description = "Namespace donde se desplegó cert-manager"
#   value       = kubernetes_namespace.cert_manager.metadata[0].name
# }

# output "cluster_issuer_name" {
#   description = "Nombre del ClusterIssuer de Let's Encrypt"
#   value       = kubernetes_manifest.letsencrypt_issuer.manifest.metadata.name
# }

# output "tls_certificate_secret" {
#   description = "Nombre del Secret con el certificado TLS"
#   value       = var.domain_name
# }

# output "certificate_renewal_date" {
#   description = "Fecha estimada de renovación del certificado"
#   value       = "Automático cada 90 días"
# }

# ==============================================================================
# OUTPUTS PARA CONFIGURACIÓN DE KUBECONFIG
# ==============================================================================

# output "kubeconfig_path" {
#   description = "Comando para actualizar kubeconfig"
#   value       = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.oke_cluster.id} --file $HOME/.kube/config --region ${var.region}"
# }

# output "kubectl_context" {
#   description = "Contexto de kubectl a usar"
#   value       = "context-${oci_containerengine_cluster.oke_cluster.id}"
# }

# ==============================================================================
# OUTPUTS DE MONITOREO Y LOGGING
# ==============================================================================

# output "monitoring_enabled" {
#   description = "Monitoreo de OCI habilitado"
#   value       = var.enable_monitoring
# }

# output "logging_enabled" {
#   description = "Logging de OCI habilitado"
#   value       = var.enable_logging
# }

# output "log_group_id" {
#   description = "ID del Log Group"
#   value       = oci_logging_log_group.cluster_logs[0].id
# }

# ==============================================================================
# OUTPUTS DE CONFIGURACIÓN GENERAL
# ==============================================================================

# output "environment" {
#   description = "Ambiente de despliegue"
#   value       = var.environment
# }

# output "region" {
#   description = "Región de OCI"
#   value       = var.region
# }

# output "tags" {
#   description = "Etiquetas aplicadas a los recursos"
#   value       = var.tags
# }
