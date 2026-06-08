# ============================================================================
# Outputs for Streaming Architecture
# ============================================================================

# TODO: Descomentar los siguientes outputs:

# # Streaming Endpoints
# output "stream_id" {
#   description = "OCID del stream"
#   value       = oci_streaming_stream.main.id
# }

# output "messages_endpoint" {
#   description = "Endpoint para Kafka producers/consumers"
#   value       = oci_streaming_stream.main.messages_endpoint
#   sensitive   = false
# }

# output "bootstrap_servers" {
#   description = "Bootstrap servers para Kafka CLI"
#   value       = oci_streaming_stream.main.messages_endpoint
#   sensitive   = false
# }

# # Functions Application
# output "application_id" {
#   description = "OCID de Functions Application"
#   value       = oci_functions_application.streaming_app.id
# }

# # Consumer Functions
# output "archive_consumer_id" {
#   description = "OCID de Consumer Function (Archive)"
#   value       = var.archive_bucket_name != "" ? oci_functions_function.archive_consumer[0].id : null
# }

# output "process_consumer_id" {
#   description = "OCID de Consumer Function (Process)"
#   value       = oci_functions_function.process_consumer.id
# }

# # Storage
# output "archive_bucket_name" {
#   description = "Nombre del bucket de archival"
#   value       = var.archive_bucket_name != "" ? oci_objectstorage_bucket.stream_archive[0].name : null
# }

# # Usage Examples
# output "kafka_producer_example" {
#   description = "Ejemplo de código productor Kafka"
#   value       = <<-EOT
#     from confluent_kafka import Producer
#     
#     producer = Producer({
#         'bootstrap.servers': '${oci_streaming_stream.main.messages_endpoint}',
#         'security.protocol': 'SASL_SSL',
#         'sasl.username': 'YOUR_USER_OCID',
#         'sasl.password': 'YOUR_AUTH_TOKEN',
#         'sasl.mechanism': 'PLAIN'
#     })
#     
#     producer.produce('events', value=b'{"data": "..."}')
#     producer.flush()
#   EOT
# }

# output "kafka_consumer_example" {
#   description = "Ejemplo de código consumidor Kafka"
#   value       = <<-EOT
#     from confluent_kafka import Consumer
#     
#     consumer = Consumer({
#         'bootstrap.servers': '${oci_streaming_stream.main.messages_endpoint}',
#         'group.id': '${var.consumer_group_name}',
#         'auto.offset.reset': 'earliest',
#         'security.protocol': 'SASL_SSL',
#         'sasl.username': 'YOUR_USER_OCID',
#         'sasl.password': 'YOUR_AUTH_TOKEN'
#     })
#     
#     consumer.subscribe(['events'])
#     
#     while True:
#         msg = consumer.poll(timeout=1.0)
#         if msg:
#             print(f"Received: {msg.value()}")
#   EOT
# }
