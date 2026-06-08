# TODO: Implementar MySQL HeatWave DB System
# - oci_mysql_mysql_db_system: Cluster principal
# - oci_mysql_heatwave_cluster: HeatWave nodes
# - oci_monitoring_alarm: Alertas
# - oci_core_network_security_group: NSG para puerto 3306

locals {
  db_display_name = "${var.project_name}-${var.cluster_name}-${var.environment}"
  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Project     = var.project_name
      CreatedDate = formatdate("YYYY-MM-DD", timestamp())
    }
  )
}

# Placeholder for MySQL HeatWave resources
