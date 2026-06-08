output "dbsystem_id" {
  description = "OCID del DB System"
  value       = oci_database_db_system.db_system.id
}

data "oci_database_db_nodes" "db_nodes" {
  compartment_id = var.compartment_id
  db_system_id   = oci_database_db_system.db_system.id
}

data "oci_core_vnic" "db_node_vnic" {
  vnic_id = data.oci_database_db_nodes.db_nodes.db_nodes[0].vnic_id
}

output "node_ip" {
  description = "Dirección IP privada del DB Node principal"
  value       = data.oci_core_vnic.db_node_vnic.private_ip_address
}

output "db_home_id" {
  description = "OCID del DB Home creado (útil para DataGuard u operaciones de parcheo)"
  value       = oci_database_db_system.db_system.db_home[0].id
}

output "database_id" {
  description = "OCID de la Base de Datos inicial creada dentro del DB Home"
  value       = oci_database_db_system.db_system.db_home[0].database[0].id
}

output "hostname" {
  description = "Hostname configurado en el DB System"
  value       = oci_database_db_system.db_system.hostname
}

output "db_name" {
  description = "Nombre de la base de datos (DB_NAME)"
  value       = oci_database_db_system.db_system.db_home[0].database[0].db_name
}
