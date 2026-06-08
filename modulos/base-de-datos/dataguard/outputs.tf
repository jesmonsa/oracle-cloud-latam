output "dataguard_association_id" {
  description = "OCID de la Asociación de DataGuard"
  value       = oci_database_data_guard_association.db_standby.id
}

output "peer_db_system_id" {
  description = "OCID del DB System Standby recién creado"
  value       = oci_database_data_guard_association.db_standby.peer_db_system_id
}

output "role" {
  description = "Rol actual (debe ser STANDBY o DISABLED tras la creación)"
  value       = oci_database_data_guard_association.db_standby.role
}
