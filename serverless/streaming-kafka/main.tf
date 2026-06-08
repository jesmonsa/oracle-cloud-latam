# ============================================================================
# OCI Streaming - Kafka Compatible
# ============================================================================
# Arquitectura de streaming en tiempo real
#
# TODO: Implementar los siguientes recursos:
# - [ ] Stream (Kafka compatible)
# - [ ] Topics (events, transactions, etc)
# - [ ] Partitions
# - [ ] Functions Application
# - [ ] Consumer Functions
# - [ ] Archival a Object Storage (opcional)
# - [ ] Sink a Autonomous Database (opcional)
# - [ ] Logging y Monitoring
# - [ ] Consumer Group
# ============================================================================

# ============================================================================
# Data Sources
# ============================================================================

data "oci_identity_availability_domains" "available" {
  compartment_id = var.tenancy_ocid
}

# ============================================================================
# Storage for Archival
# ============================================================================

# TODO: Crear bucket para archival de streams
# resource "oci_objectstorage_bucket" "stream_archive" {
#   count          = var.archive_bucket_name != "" ? 1 : 0
#   compartment_id = var.compartment_ocid
#   namespace      = data.oci_objectstorage_namespace.ns.namespace
#   name           = var.archive_bucket_name
#   access_type    = "NoPublicAccess"
#   
#   tags = var.tags
# }

# ============================================================================
# IAM for Streaming
# ============================================================================

# TODO: Crear dynamic group para Functions consumers
# resource "oci_identity_dynamic_group" "streaming_functions" {
#   compartment_id = var.tenancy_ocid
#   name           = "${var.app_name}-streaming-dg"
#   description    = "Dynamic group para stream consumers"
#   matching_rule  = "resource.type = 'fnfunc' AND resource.compartment.id = '${var.compartment_ocid}'"
# }

# TODO: Crear policy para acceso a streaming
# resource "oci_identity_policy" "streaming_policy" {
#   compartment_id = var.compartment_ocid
#   name           = "${var.app_name}-streaming-policy"
#   
#   statements = [
#     "Allow dynamic-group ${oci_identity_dynamic_group.streaming_functions.name} to manage streams in compartment id ${var.compartment_ocid}",
#   ]
# }

# ============================================================================
# Logging
# ============================================================================

# TODO: Crear logs group
# resource "oci_logging_log_group" "stream_logs" {
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-stream-logs"
#   description    = "Logs para streaming architecture"
# }

# ============================================================================
# Streaming (Kafka)
# ============================================================================

# TODO: Crear Stream (Kafka endpoint)
# resource "oci_streaming_stream" "main" {
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-stream"
#   name           = replace(var.app_name, "-", "")
#   
#   partitions       = var.num_partitions
#   retention_in_hours = var.retention_hours
#   
#   tags = var.tags
# }

# TODO: Crear Topics dinámicamente
# resource "oci_streaming_stream_pool" "main" {
#   compartment_id = var.compartment_ocid
#   name           = "${var.app_name}-pool"
#   
#   # Kafka brokers automáticamente configurados
# }

# ============================================================================
# Functions Application and Consumers
# ============================================================================

# TODO: Crear Functions Application
# resource "oci_functions_application" "streaming_app" {
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-application"
#   
#   config = {
#     ENVIRONMENT    = var.environment
#     STREAM_ENDPOINT = oci_streaming_stream.main.messages_endpoint
#     BOOTSTRAP_SERVERS = oci_streaming_stream.main.messages_endpoint
#   }
# }

# TODO: Función Consumer 1 - Archive to Object Storage
# resource "oci_functions_function" "archive_consumer" {
#   count          = var.archive_bucket_name != "" ? 1 : 0
#   application_id = oci_functions_application.streaming_app.id
#   display_name   = "${var.app_name}-archive"
#   image          = "..."
#   image_digest   = ""
#   memory_in_mbs  = var.function_memory
#   timeout_in_secs = var.function_timeout
#   
#   environment_variables = {
#     BUCKET_NAME = oci_objectstorage_bucket.stream_archive[0].name
#     BATCH_SIZE  = "100"
#   }
# }

# TODO: Función Consumer 2 - Process Stream (default)
# resource "oci_functions_function" "process_consumer" {
#   application_id = oci_functions_application.streaming_app.id
#   display_name   = "${var.app_name}-process"
#   image          = "..."
#   image_digest   = ""
#   memory_in_mbs  = var.function_memory
#   timeout_in_secs = var.function_timeout
# }

# TODO: Función Consumer 3 - Database Sink (opcional)
# resource "oci_functions_function" "db_consumer" {
#   count          = var.enable_database_sink ? 1 : 0
#   application_id = oci_functions_application.streaming_app.id
#   display_name   = "${var.app_name}-db-sink"
#   image          = "..."
#   image_digest   = ""
#   memory_in_mbs  = var.function_memory
#   timeout_in_secs = var.function_timeout
# }

# ============================================================================
# Consumer Group (para reintento de fallidos)
# ============================================================================

# TODO: Crear Consumer Group
# Nota: Se crea automáticamente en OCI Streaming al conectarse
# 
# oci streaming consumer-group create \
#   --stream-id <stream-id> \
#   --name ${var.consumer_group_name} \
#   --initial-cursor TRIM_HORIZON

# ============================================================================
# Monitoring
# ============================================================================

# TODO: Crear alarma para consumer lag
# resource "oci_monitoring_alarm" "consumer_lag" {
#   count              = var.enable_monitoring ? 1 : 0
#   compartment_id     = var.compartment_ocid
#   display_name       = "${var.app_name}-consumer-lag"
#   metric_compartment_id = var.compartment_ocid
#   namespace          = "oci_streaming"
#   query              = "consumer_lag()"
#   threshold          = var.consumer_lag_threshold
#   severity           = "WARNING"
#   
#   tags = var.tags
# }

# TODO: Crear alarma para tasa de errores
# resource "oci_monitoring_alarm" "consumer_errors" {
#   count              = var.enable_monitoring ? 1 : 0
#   compartment_id     = var.compartment_ocid
#   display_name       = "${var.app_name}-consumer-errors"
#   metric_compartment_id = var.compartment_ocid
#   namespace          = "oci_functions"
#   query              = "errors.rate()"
#   severity           = "CRITICAL"
#   
#   tags = var.tags
# }

# ============================================================================
# Locals
# ============================================================================

locals {
  common_tags = merge(
    var.tags,
    {
      Name            = var.app_name
      CreatedAt       = timestamp()
      TerraformModule = "serverless-streaming-kafka"
    }
  )
}
