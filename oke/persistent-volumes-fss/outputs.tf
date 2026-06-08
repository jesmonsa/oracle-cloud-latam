# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  PERSISTENT VOLUMES - FILE STORAGE SERVICE - OUTPUTS (PLACEHOLDERS)          ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# output "cluster_id" {
#   description = "ID del clúster OKE"
#   value       = oci_containerengine_cluster.oke_cluster.id
# }

# output "node_pool_id" {
#   description = "ID del pool de nodos"
#   value       = oci_containerengine_node_pool.oke_node_pool.id
# }

# output "file_system_id" {
#   description = "ID del File Storage Service"
#   value       = oci_file_storage_file_system.fss.id
# }

# output "file_system_availability_domain" {
#   description = "Dominio de disponibilidad del FSS"
#   value       = oci_file_storage_file_system.fss.availability_domain
# }

# output "mount_target_id" {
#   description = "ID del Mount Target"
#   value       = oci_file_storage_mount_target.mount_target.id
# }

# output "mount_target_ip_address" {
#   description = "Dirección IP del Mount Target"
#   value       = oci_file_storage_mount_target.mount_target.private_ip_addresses[0]
# }

# output "export_set_id" {
#   description = "ID del Export Set"
#   value       = oci_file_storage_export_set.export_set.id
# }

# output "export_path" {
#   description = "Ruta de exportación NFS"
#   value       = var.export_path
# }

# output "nfs_mount_command" {
#   description = "Comando de mount NFS"
#   value       = "mount -t nfs -o vers=3 ${oci_file_storage_mount_target.mount_target.private_ip_addresses[0]}:${var.export_path} /mnt/fss"
# }

# output "storage_class_name" {
#   description = "Nombre de la StorageClass"
#   value       = var.storage_class_name
# }

# output "fss_size_gb" {
#   description = "Tamaño inicial del FSS"
#   value       = var.fss_initial_size_gb
# }

# output "auto_expansion_enabled" {
#   description = "Auto-expansion habilitada"
#   value       = var.enable_auto_expansion
# }

# output "max_fss_size_gb" {
#   description = "Tamaño máximo del FSS"
#   value       = var.max_fss_size_gb
# }

# output "snapshots_enabled" {
#   description = "Snapshots habilitados"
#   value       = var.enable_fss_snapshots
# }

# output "snapshot_policy" {
#   description = "Política de snapshots"
#   value       = var.snapshot_policy
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
