# TODO: Implementar recursos de Autonomous Database
#
# Este archivo debe contener:
# 1. oci_database_autonomous_database - Instancia ATP/ADW
# 2. oci_database_autonomous_database_wallet - Gestión del wallet
# 3. oci_monitoring_alarm - Alertas de CPU, Storage, Conexiones
# 4. oci_logging_log_group - Logs de auditoría
# 5. oci_core_network_security_group - NSG para Private Endpoint
# 6. oci_core_network_security_group_security_rule - Reglas de tráfico
# 7. oci_notifications_notification_topic - Topic SNS para alertas
#
# Estructura base:

locals {
  db_display_name = "${var.project_name}-${var.db_name}-${var.environment}"
  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Project     = var.project_name
      Workload    = var.db_workload
      CreatedDate = formatdate("YYYY-MM-DD", timestamp())
    }
  )
}

# =============================================================================
# AUTONOMOUS DATABASE INSTANCE
# =============================================================================

resource "oci_database_autonomous_database" "main" {
  # TODO: Crear instancia de Autonomous Database
  # Required parameters:
  # - compartment_id
  # - db_name
  # - admin_password
  # - db_workload (OLTP|DW)
  # - is_free_tier
  #
  # Optional parameters:
  # - cpu_core_count
  # - data_storage_size_in_gb
  # - subnet_id (para Private Endpoint)
  # - whitelisted_ips
  # - backup_retention_period_in_days
  # - auto_scaling_enabled
  # - is_auto_scaling_in_free_tier
  # - data_guard_enabled
  # - database_edition
  # - license_model
  # - freeform_tags
  # - defined_tags

  depends_on = [
    oci_core_network_security_group.autonomous_db_nsg
  ]
}

# =============================================================================
# NETWORK SECURITY GROUP
# =============================================================================

resource "oci_core_network_security_group" "autonomous_db_nsg" {
  # TODO: Crear NSG para Autonomous Database Private Endpoint
  # - Nombre: ${local.db_display_name}-nsg
  # - VCN ID: var.vcn_id
  # - Description: NSG for ATP/ADW Private Endpoint

  depends_on = []
}

resource "oci_core_network_security_group_security_rule" "autonomous_db_inbound" {
  # TODO: Crear regla inbound para puerto 1522 (TLS)
  # - network_security_group_id
  # - direction: INGRESS
  # - protocol: 6 (TCP)
  # - destination_type: NETWORK_SECURITY_GROUP
  # - destination: var.subnet_id
  # - destination_port_range: min=1522, max=1522
  # - stateless: false

  depends_on = [oci_core_network_security_group.autonomous_db_nsg]
}

# =============================================================================
# MONITORING & ALERTING
# =============================================================================

resource "oci_monitoring_alarm" "cpu_utilization" {
  # TODO: Crear alerta para CPU > 80%
  # - compartment_id
  # - display_name: "${local.db_display_name}-high-cpu"
  # - metric_name: "cpuUtilization"
  # - namespace: "oci_database"
  # - statistic: "MEAN"
  # - threshold: 80
  # - comparison_operator: "GREATER_THAN"
  # - evaluation_periods: 1
  # - frequency_in_minutes: 5
  # - severity: "WARNING"

  count = var.enable_monitoring ? 1 : 0

  depends_on = [oci_database_autonomous_database.main]
}

resource "oci_monitoring_alarm" "storage_utilization" {
  # TODO: Crear alerta para Storage > 90%
  # - Similar a cpu_utilization pero para metric "storageUtilization"
  # - threshold: 90

  count = var.enable_monitoring ? 1 : 0

  depends_on = [oci_database_autonomous_database.main]
}

resource "oci_monitoring_alarm" "database_connections" {
  # TODO: Crear alerta para conexiones > 200
  # - metric_name: "databaseConnections"
  # - threshold: 200

  count = var.enable_monitoring ? 1 : 0

  depends_on = [oci_database_autonomous_database.main]
}

# =============================================================================
# LOGGING & AUDIT
# =============================================================================

resource "oci_logging_log_group" "autonomous_db_logs" {
  # TODO: Crear Log Group para auditoría
  # - compartment_id
  # - display_name: "${local.db_display_name}-logs"
  # - description: "Unified Audit Trail and Database Activity Monitoring"

  count = var.enable_audit_logging ? 1 : 0
}

# =============================================================================
# WALLET MANAGEMENT
# =============================================================================

resource "oci_database_autonomous_database_wallet" "wallet" {
  # TODO: Crear wallet de la BD
  # - autonomous_database_id: oci_database_autonomous_database.main.id
  # - password: (generar password seguro o usar input)
  # - base64_encode_content: true

  depends_on = [oci_database_autonomous_database.main]
}

# =============================================================================
# LOCAL FILE FOR WALLET STORAGE
# =============================================================================

resource "local_file" "wallet_zip" {
  # TODO: Guardar wallet localmente
  # - filename: "${var.wallet_download_path}/wallet.zip"
  # - content_base64: oci_database_autonomous_database_wallet.wallet.content
  # - file_permission: "0600"

  count = var.enable_wallet_download ? 1 : 0

  depends_on = [oci_database_autonomous_database_wallet.wallet]
}

# =============================================================================
# NOTIFICATIONS
# =============================================================================

resource "oci_notifications_notification_topic" "alerts" {
  # TODO: Crear SNS Topic para alertas
  # - compartment_id
  # - name: "${local.db_display_name}-alerts"
  # - description: "Alerts and notifications for ATP/ADW"

  count = var.enable_monitoring && var.monitoring_email != "" ? 1 : 0
}

resource "oci_notifications_subscription" "email_alerts" {
  # TODO: Suscribir email a topic
  # - topic_id: oci_notifications_notification_topic.alerts[0].id
  # - endpoint: var.monitoring_email
  # - protocol: "EMAIL"

  count = var.enable_monitoring && var.monitoring_email != "" ? 1 : 0

  depends_on = [oci_notifications_notification_topic.alerts]
}

# =============================================================================
# DATA SOURCES (Información de recursos existentes)
# =============================================================================

data "oci_core_subnet" "selected" {
  subnet_id = var.subnet_id
}

data "oci_core_vcn" "selected" {
  vcn_id = var.vcn_id
}
