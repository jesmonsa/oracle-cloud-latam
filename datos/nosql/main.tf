# TODO: Implementar NoSQL Database
# - oci_nosql_table: Crear tabla NoSQL
# - oci_nosql_index: Crear índices
# - oci_monitoring_alarm: Alertas para RU/WU/Storage
# - oci_logging_log_group: Audit logs

locals {
  display_name = "${var.project_name}-${var.table_name}-${var.environment}"
  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Project     = var.project_name
      CreatedDate = formatdate("YYYY-MM-DD", timestamp())
    }
  )
}

# Placeholder for NoSQL resources
