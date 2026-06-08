# ============================================================================
# Outputs for Event-Driven Architecture
# ============================================================================

# TODO: Descomentar los siguientes outputs:

# # Functions Application
# output "application_id" {
#   description = "OCID de Functions Application"
#   value       = oci_functions_application.event_app.id
# }

# # Event Rules
# output "object_storage_rule_id" {
#   description = "OCID de Event Rule para Object Storage"
#   value       = oci_events_rule.object_storage_rule.id
# }

# # Storage Buckets
# output "events_bucket_name" {
#   description = "Nombre del bucket de eventos"
#   value       = oci_objectstorage_bucket.events.name
# }

# output "processed_bucket_name" {
#   description = "Nombre del bucket de procesados"
#   value       = oci_objectstorage_bucket.processed.name
# }

# # DLQ
# output "dlq_queue_id" {
#   description = "OCID de la Dead Letter Queue"
#   value       = var.enable_dlq ? oci_queue_queue.dlq[0].id : null
# }

# # Notifications
# output "notification_topic_id" {
#   description = "OCID del SNS Topic"
#   value       = var.enable_notifications ? oci_ons_notification_topic.event_notifications[0].id : null
# }

# # Example Commands
# output "upload_test_file" {
#   description = "Comando para probar arquitectura"
#   value       = "oci os object put -bn ${oci_objectstorage_bucket.events.name} -f test.txt"
# }

# output "view_dlq_messages" {
#   description = "Comando para ver mensajes en DLQ"
#   value       = var.enable_dlq ? "oci queue messages get --queue-id ${oci_queue_queue.dlq[0].id}" : null
# }
