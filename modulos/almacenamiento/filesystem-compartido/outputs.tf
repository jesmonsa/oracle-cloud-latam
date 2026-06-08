output "filesystem_id" {
  description = "OCID del File System compartido"
  value       = oci_file_storage_file_system.fs.id
}

output "mount_target_id" {
  description = "OCID del Mount Target"
  value       = oci_file_storage_mount_target.mt.id
}

output "export_set_id" {
  description = "OCID del Export Set"
  value       = oci_file_storage_export_set.es.id
}

output "ip_montaje" {
  description = "Dirección IP del Mount Target (usada para montar el sistema de archivos)"
  value       = oci_file_storage_mount_target.mt.ip_address
}

output "ruta_montaje" {
  description = "Ruta de exportación NFS configurada"
  value       = var.ruta_exportacion
}

output "comando_montaje" {
  description = "Comando NFS para montar el filesystem en los clientes"
  value       = "sudo mount -t nfs ${oci_file_storage_mount_target.mt.ip_address}:${var.ruta_exportacion} /mnt/shared"
}
