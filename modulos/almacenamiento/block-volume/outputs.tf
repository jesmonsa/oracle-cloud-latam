output "volume_id" {
  description = "OCID del Block Volume creado"
  value       = oci_core_volume.bv.id
}

output "attachment_id" {
  description = "OCID del attachment del Block Volume a la instancia"
  value       = oci_core_volume_attachment.bv_attach.id
}

output "iqn" {
  description = "IQN iSCSI del volumen (necesario para el script de montaje)"
  value       = oci_core_volume_attachment.bv_attach.iqn
}

output "ipv4" {
  description = "IP iSCSI del volumen (necesario para el script de montaje)"
  value       = oci_core_volume_attachment.bv_attach.ipv4
}

output "punto_montaje" {
  description = "Punto de montaje configurado para el volumen"
  value       = var.punto_montaje
}
