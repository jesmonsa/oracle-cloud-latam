# ============================================================================
# Outputs for CRUD API
# ============================================================================

# TODO: Descomentar los siguientes outputs:

# # API Gateway
# output "api_endpoint" {
#   description = "Endpoint del API Gateway"
#   value       = oci_apigateway_deployment.crud_api.endpoint
# }

# # Database Connection
# output "database_id" {
#   description = "OCID de Autonomous Database"
#   value       = oci_database_autonomous_database.main.id
# }

# output "database_connection_string" {
#   description = "Connection string de base de datos"
#   value       = oci_database_autonomous_database.main.connection_strings[0].all_connection_strings
#   sensitive   = true
# }

# # Functions
# output "application_id" {
#   description = "OCID de Functions Application"
#   value       = oci_functions_application.crud_api.id
# }

# # Example Requests
# output "api_examples" {
#   description = "Ejemplos de uso de API"
#   value = {
#     list_items  = "curl '${oci_apigateway_deployment.crud_api.endpoint}/v1/items'"
#     get_item    = "curl '${oci_apigateway_deployment.crud_api.endpoint}/v1/items/1'"
#     create_item = "curl -X POST '${oci_apigateway_deployment.crud_api.endpoint}/v1/items' -d '{...}'"
#     update_item = "curl -X PUT '${oci_apigateway_deployment.crud_api.endpoint}/v1/items/1' -d '{...}'"
#     delete_item = "curl -X DELETE '${oci_apigateway_deployment.crud_api.endpoint}/v1/items/1'"
#   }
# }
