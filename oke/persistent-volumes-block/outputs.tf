# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  PERSISTENT VOLUMES - BLOCK STORAGE - OUTPUTS (PLACEHOLDERS)                 ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# output "cluster_id" {
#   description = "ID del clúster OKE"
#   value       = oci_containerengine_cluster.oke_cluster.id
# }

# output "node_pool_id" {
#   description = "ID del pool de nodos"
#   value       = oci_containerengine_node_pool.oke_node_pool.id
# }

# output "csi_driver_version" {
#   description = "Versión del CSI driver instalado"
#   value       = var.csi_driver_version
# }

# output "storage_class_name" {
#   description = "Nombre de la StorageClass"
#   value       = var.storage_class_name
# }

# output "storage_size_gb" {
#   description = "Tamaño de volúmenes configurado"
#   value       = var.storage_size_gb
# }

# output "vpus_per_gb" {
#   description = "VPUs por GB configurados"
#   value       = var.vpus_per_gb
# }

# output "cross_ad_replication_enabled" {
#   description = "Replicación cross-AD habilitada"
#   value       = var.enable_cross_ad_replication
# }

# output "backup_enabled" {
#   description = "Backups automáticos habilitados"
#   value       = var.backup_enabled
# }

# output "backup_retention_days" {
#   description = "Días de retención de backups"
#   value       = var.backup_retention_days
# }

# output "backup_schedule" {
#   description = "Cronograma de backups"
#   value       = var.backup_schedule
# }

# output "encryption_enabled" {
#   description = "Encriptación de volúmenes habilitada"
#   value       = var.enable_volume_encryption
# }

# output "snapshots_enabled" {
#   description = "Snapshots de volúmenes habilitados"
#   value       = var.enable_volume_snapshots
# }

# output "disaster_recovery_enabled" {
#   description = "Configuración de DR habilitada"
#   value       = var.enable_disaster_recovery
# }

# output "kubeconfig_path" {
#   description = "Comando para obtener kubeconfig"
#   value       = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.oke_cluster.id} --file $HOME/.kube/config"
# }

# output "csi_namespace" {
#   description = "Namespace donde se instala CSI driver"
#   value       = "kube-system"
# }

# output "storage_reservation_gb" {
#   description = "Reserva de storage para operaciones"
#   value       = var.storage_reservation_gb
# }

# output "environment" {
#   description = "Ambiente de despliegue"
#   value       = var.environment
# }

# output "tags" {
#   description = "Etiquetas aplicadas a recursos"
#   value       = var.tags
# }
