# TODO: Implementar outputs para información importante de conexión
#
# Estos outputs deben ser generados después de crear la BD:

output "autonomous_db_id" {
  description = "OCID de la Autonomous Database"
  value       = "TODO: oci_database_autonomous_database.main.id"
  sensitive   = false
}

output "autonomous_db_name" {
  description = "Nombre de la base de datos"
  value       = "TODO: oci_database_autonomous_database.main.db_name"
}

output "autonomous_db_hostname" {
  description = "Hostname para conexión Private Endpoint (formato: {database-name}.{subdomain}.oraclecloud.com)"
  value       = "TODO: oci_database_autonomous_database.main.connection_strings[0].dedicated_connection_string"
}

output "autonomous_db_high_connection_string" {
  description = "Connection string HIGH (para conexiones de alta disponibilidad)"
  value       = "TODO: oci_database_autonomous_database.main.connection_strings[0].high_connection_string"
}

output "autonomous_db_low_connection_string" {
  description = "Connection string LOW (para conexiones normales)"
  value       = "TODO: oci_database_autonomous_database.main.connection_strings[0].low_connection_string"
}

output "autonomous_db_admin_user" {
  description = "Usuario administrativo de la BD"
  value       = "ADMIN"
}

output "autonomous_db_workload_type" {
  description = "Tipo de carga (OLTP o DW)"
  value       = "TODO: var.db_workload"
}

output "autonomous_db_ocpu_count" {
  description = "Número de OCPU asignados"
  value       = "TODO: oci_database_autonomous_database.main.cpu_core_count"
}

output "autonomous_db_storage_gb" {
  description = "Almacenamiento asignado en GB"
  value       = "TODO: oci_database_autonomous_database.main.data_storage_size_in_gb"
}

output "autonomous_db_status" {
  description = "Estado actual de la BD (AVAILABLE, PROVISIONING, etc.)"
  value       = "TODO: oci_database_autonomous_database.main.lifecycle_state"
}

output "autonomous_db_private_endpoint_ip" {
  description = "IP privada del endpoint (si está disponible)"
  value       = "TODO: oci_database_autonomous_database.main.private_endpoint_ip"
}

output "wallet_download_url" {
  description = "URL para descargar el wallet (válida por 30 días)"
  value       = "TODO: Si enable_wallet_download"
}

output "wallet_location" {
  description = "Ubicación local del archivo wallet.zip"
  value       = "TODO: local_file.wallet_zip[0].filename"
}

output "jdbc_connection_string" {
  description = "JDBC connection string para aplicaciones Java"
  value       = "TODO: jdbc:oracle:thin:@${hostname}:1522/${db_name}_high?TNS_ADMIN=/path/to/wallet"
}

output "sqlplus_connection_command" {
  description = "Comando para conectar con SQLPlus"
  value       = "TODO: export TNS_ADMIN=/path/to/wallet && sqlplus admin@{tns_alias}"
}

output "monitoring_namespace" {
  description = "OCI Monitoring namespace para queries de métricas"
  value       = "oci_database"
}

output "database_version" {
  description = "Versión de Oracle Database"
  value       = "TODO: oci_database_autonomous_database.main.database_version"
}

output "database_edition" {
  description = "Edición de la base de datos"
  value       = "TODO: var.database_edition"
}

output "license_model" {
  description = "Modelo de licencia en uso"
  value       = "TODO: var.license_model"
}

output "backup_retention_days" {
  description = "Período de retención de backups en días"
  value       = "TODO: var.backup_retention_days"
}

output "auto_scaling_enabled" {
  description = "Estado del auto-scaling"
  value       = "TODO: var.auto_scaling_enabled"
}

output "data_guard_enabled" {
  description = "Estado de Data Guard (HA)"
  value       = "TODO: var.data_guard_enabled"
}

output "subnet_id" {
  description = "Subnet ID donde está el Private Endpoint"
  value       = var.subnet_id
}

output "vcn_id" {
  description = "VCN ID donde está el Private Endpoint"
  value       = var.vcn_id
}

output "nsg_id" {
  description = "Network Security Group ID (si fue creado)"
  value       = "TODO: oci_core_network_security_group.autonomous_db_nsg.id"
}

output "compartment_id" {
  description = "Compartment ID donde está la BD"
  value       = var.compartment_id
}

output "created_timestamp" {
  description = "Timestamp de creación"
  value       = "TODO: oci_database_autonomous_database.main.time_created"
}

output "terraform_state_key" {
  description = "Clave de estado en S3 (para referencia)"
  value       = "datos/autonomous-db/terraform.tfstate"
}

output "connection_info_summary" {
  description = "Resumen de información de conexión"
  value = {
    admin_user               = "ADMIN"
    database_name            = "TODO: oci_database_autonomous_database.main.db_name"
    hostname                 = "TODO: connection hostname"
    port                     = 1522
    protocol                 = "TLS/1.2+"
    private_endpoint_enabled = true
    wallet_required          = true
    tns_admin_location       = "${var.wallet_download_path}/wallet"
  }
}

output "cost_estimate_monthly_usd" {
  description = "Estimación de costo mensual en USD (valor referencial)"
  value       = "OCPU: ${var.ocpu_count} × USD ${var.db_workload == \"OLTP\" ? 0.70 : 1.00} × 730h = USD ${var.ocpu_count * (var.db_workload == \"OLTP\" ? 0.70 : 1.00) * 730} + Storage: USD ${var.storage_gb * (var.db_workload == \"OLTP\" ? 0.02 : 0.01)}/mes"
}
