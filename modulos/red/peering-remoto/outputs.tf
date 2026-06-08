output "drg_id_region1" {
  description = "OCID del DRG en la Región 1"
  value       = oci_core_drg.drg_region1.id
}

output "drg_id_region2" {
  description = "OCID del DRG en la Región 2"
  value       = oci_core_drg.drg_region2.id
}

output "rpc_id_region1" {
  description = "OCID del Remote Peering Connection en la Región 1"
  value       = oci_core_remote_peering_connection.rpc_region1.id
}

output "rpc_id_region2" {
  description = "OCID del Remote Peering Connection en la Región 2"
  value       = oci_core_remote_peering_connection.rpc_region2.id
}

output "estado_conexion" {
  description = "Estado del peering RPC desde la Región 1 (PEERED = OK)"
  value       = oci_core_remote_peering_connection.rpc_region1.peering_status
}

output "estado_rpc_region1" {
  description = "Estado del peering RPC desde la Región 1 (alias de estado_conexion)"
  value       = oci_core_remote_peering_connection.rpc_region1.peering_status
}

output "estado_rpc_region2" {
  description = "Estado del peering RPC desde la Región 2"
  value       = oci_core_remote_peering_connection.rpc_region2.peering_status
}
