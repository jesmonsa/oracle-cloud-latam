# ============================================================================
# OCI Functions - Event-Driven Architecture
# ============================================================================
# Arquitectura orientada a eventos con OCI Events Service
#
# TODO: Implementar los siguientes recursos:
# - [ ] Functions Application
# - [ ] Funciones handlers (process, notify, error)
# - [ ] Object Storage bucket para eventos
# - [ ] Events Rules (disparadores)
# - [ ] SNS Topic para notificaciones
# - [ ] Queue para DLQ
# - [ ] Logging groups
# - [ ] IAM roles y policies
# - [ ] Monitoring dashboards
# ============================================================================

# ============================================================================
# Data Sources
# ============================================================================

data "oci_identity_availability_domains" "available" {
  compartment_id = var.tenancy_ocid
}

# ============================================================================
# Networking
# ============================================================================

# TODO: Crear VCN si es necesario
# resource "oci_core_vcn" "main" {
#   compartment_id = var.compartment_ocid
#   cidr_block     = "10.0.0.0/16"
#   display_name   = "${var.app_name}-vcn"
# }

# ============================================================================
# Storage for Event Processing
# ============================================================================

# TODO: Crear Object Storage bucket para eventos
# resource "oci_objectstorage_bucket" "events" {
#   compartment_id = var.compartment_ocid
#   namespace      = data.oci_objectstorage_namespace.ns.namespace
#   name           = "${var.app_name}-events"
#   access_type    = "NoPublicAccess"
# }

# TODO: Crear bucket para resultados procesados
# resource "oci_objectstorage_bucket" "processed" {
#   compartment_id = var.compartment_ocid
#   namespace      = data.oci_objectstorage_namespace.ns.namespace
#   name           = "${var.app_name}-processed"
#   access_type    = "NoPublicAccess"
# }

# ============================================================================
# IAM for Functions
# ============================================================================

# TODO: Crear dynamic group para Functions
# resource "oci_identity_dynamic_group" "event_functions" {
#   compartment_id = var.tenancy_ocid
#   name           = "${var.app_name}-event-functions-dg"
#   description    = "Dynamic group para event-driven functions"
#   matching_rule  = "resource.type = 'fnfunc' AND resource.compartment.id = '${var.compartment_ocid}'"
# }

# TODO: Crear policy para acceso a Object Storage
# resource "oci_identity_policy" "event_policy" {
#   compartment_id = var.compartment_ocid
#   name           = "${var.app_name}-event-policy"
#   
#   statements = [
#     "Allow dynamic-group ${oci_identity_dynamic_group.event_functions.name} to use object-family in compartment id ${var.compartment_ocid}",
#     "Allow dynamic-group ${oci_identity_dynamic_group.event_functions.name} to use logging-family in compartment id ${var.compartment_ocid}",
#   ]
# }

# ============================================================================
# Logging
# ============================================================================

# TODO: Crear logs group
# resource "oci_logging_log_group" "event_logs" {
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-event-logs"
#   description    = "Logs para arquitectura event-driven"
# }

# ============================================================================
# Functions Application
# ============================================================================

# TODO: Crear Functions Application
# resource "oci_functions_application" "event_app" {
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-application"
#   
#   config = {
#     ENVIRONMENT = var.environment
#   }
# }

# TODO: Función para procesar eventos
# resource "oci_functions_function" "process_event" {
#   application_id = oci_functions_application.event_app.id
#   display_name   = "${var.app_name}-process"
#   image          = "..."
#   image_digest   = ""
#   memory_in_mbs  = var.function_memory
#   timeout_in_secs = var.function_timeout
# }

# TODO: Función para notificar
# resource "oci_functions_function" "notify_event" {
#   application_id = oci_functions_application.event_app.id
#   display_name   = "${var.app_name}-notify"
#   image          = "..."
#   image_digest   = ""
#   memory_in_mbs  = var.function_memory
#   timeout_in_secs = var.function_timeout
# }

# TODO: Función para manejar errores (DLQ)
# resource "oci_functions_function" "handle_error" {
#   application_id = oci_functions_application.event_app.id
#   display_name   = "${var.app_name}-error-handler"
#   image          = "..."
#   image_digest   = ""
#   memory_in_mbs  = var.function_memory
#   timeout_in_secs = var.function_timeout
# }

# ============================================================================
# Notifications
# ============================================================================

# TODO: Crear SNS Topic si enable_notifications = true
# resource "oci_ons_notification_topic" "event_notifications" {
#   count          = var.enable_notifications ? 1 : 0
#   compartment_id = var.compartment_ocid
#   name           = "${var.app_name}-notifications"
#   description    = "Topic para notificaciones de eventos"
# }

# TODO: Suscribir email a topic
# resource "oci_ons_subscription" "event_email" {
#   count           = var.enable_notifications ? 1 : 0
#   topic_id        = oci_ons_notification_topic.event_notifications[0].id
#   protocol        = "EMAIL"
#   endpoint        = var.notification_email
# }

# ============================================================================
# Event Rules
# ============================================================================

# TODO: Crear Event Rule para Object Storage eventos
# resource "oci_events_rule" "object_storage_rule" {
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-object-storage-rule"
#   description    = "Disparar función al detectar objetos en Object Storage"
#   
#   is_enabled = true
#   
#   event_condition {
#     actions = ["com.oraclecloud.objectstorage.createobject"]
#     
#     data_filter {
#       comparator = "EQUALS"
#       key        = "compartmentName"
#       value      = var.compartment_ocid
#     }
#   }
#   
#   actions {
#     actions_type = "FAAS"
#     function_id  = oci_functions_function.process_event.id
#   }
#   
#   tags = var.tags
# }

# TODO: Crear Event Rule para reintentos en DLQ
# resource "oci_events_rule" "dlq_retry_rule" {
#   count          = var.enable_dlq ? 1 : 0
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-dlq-retry"
#   description    = "Reintentar eventos que fallaron"
#   
#   is_enabled = true
#   
#   # Disparar cada var.retry_delay_seconds
#   actions {
#     actions_type = "FAAS"
#     function_id  = oci_functions_function.process_event.id
#   }
#   
#   tags = var.tags
# }

# ============================================================================
# Dead Letter Queue
# ============================================================================

# TODO: Crear Queue para DLQ si enable_dlq = true
# resource "oci_queue_queue" "dlq" {
#   count          = var.enable_dlq ? 1 : 0
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-dlq"
#   
#   retention_in_seconds = 86400 * 7  # 7 días
#   
#   tags = var.tags
# }

# ============================================================================
# Monitoring
# ============================================================================

# TODO: Crear alarma para eventos fallidos
# resource "oci_monitoring_alarm" "event_errors" {
#   count              = var.enable_monitoring ? 1 : 0
#   compartment_id     = var.compartment_ocid
#   display_name       = "${var.app_name}-event-errors"
#   metric_compartment_id = var.compartment_ocid
#   namespace          = "oci_functions"
#   query              = "errors.rate()"
#   severity           = "CRITICAL"
#   
#   tags = var.tags
# }

# TODO: Crear alarma para eventos acumulados en DLQ
# resource "oci_monitoring_alarm" "dlq_depth" {
#   count              = var.enable_dlq && var.enable_monitoring ? 1 : 0
#   compartment_id     = var.compartment_ocid
#   display_name       = "${var.app_name}-dlq-depth"
#   metric_compartment_id = var.compartment_ocid
#   namespace          = "oci_queue"
#   query              = "messages_in_queue()"
#   severity           = "WARNING"
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
      TerraformModule = "serverless-event-driven"
    }
  )
}
