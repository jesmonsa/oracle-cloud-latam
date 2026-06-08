output "cluster_name" {
  description = "Nombre del cluster GPU"
  value       = var.cluster_name
}

output "num_gpu_nodes" {
  description = "Número de nodos GPU"
  value       = var.num_gpu_nodes
}

output "gpu_shape" {
  description = "GPU shape configurada"
  value       = var.gpu_shape
}

output "filesystem_size_gb" {
  description = "Tamaño del file system en GB"
  value       = var.filesystem_size_gb
}

output "monitoring_enabled" {
  description = "Monitoring habilitado"
  value       = var.enable_monitoring
}

# TODO: Agregar outputs reales
# - master_node_private_ip
# - gpu_node_private_ips
# - fss_mount_point
# - slurm_controller_endpoint
# - grafana_dashboard_url
# - total_gpu_count
# - total_memory_gb
# - total_vcpu_count
