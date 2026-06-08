# ============================================================================
# Outputs for Functions Basico Architecture
# ============================================================================

# TODO: Descomentar y completar los siguientes outputs:

# # VCN Outputs
# output "vcn_id" {
#   description = "OCID de la VCN principal"
#   value       = oci_core_vcn.main.id
# }

# output "vcn_cidr_block" {
#   description = "Bloque CIDR de la VCN"
#   value       = oci_core_vcn.main.cidr_block
# }

# # Subnet Outputs
# output "subnet_id" {
#   description = "OCID de la subnet pública"
#   value       = oci_core_subnet.public.id
# }

# output "subnet_cidr_block" {
#   description = "Bloque CIDR de la subnet"
#   value       = oci_core_subnet.public.cidr_block
# }

# # Functions Application Outputs
# output "application_id" {
#   description = "OCID de la aplicación de Functions"
#   value       = oci_functions_application.main.id
# }

# output "application_name" {
#   description = "Nombre de la aplicación"
#   value       = oci_functions_application.main.display_name
# }

# # Function Outputs
# output "function_id" {
#   description = "OCID de la función hello-world"
#   value       = oci_functions_function.hello_world.id
# }

# output "function_arn" {
#   description = "ARN de la función"
#   value       = oci_functions_function.hello_world.arn
#   sensitive   = false
# }

# output "function_invoke_endpoint" {
#   description = "Endpoint para invocar función directamente"
#   value       = oci_functions_function.hello_world.invoke_endpoint
#   sensitive   = false
# }

# # API Gateway Outputs
# output "api_gateway_id" {
#   description = "OCID del API Gateway"
#   value       = oci_apigateway_api.main.id
# }

# output "api_endpoint" {
#   description = "URL del endpoint del API Gateway"
#   value       = oci_apigateway_deployment.main.endpoint
#   sensitive   = false
# }

# output "api_gateway_hostname" {
#   description = "Hostname del API Gateway"
#   value       = oci_apigateway_deployment.main.hostname
#   sensitive   = false
# }

# # Logging Outputs
# output "log_group_id" {
#   description = "OCID del log group"
#   value       = oci_logging_log_group.function_logs.id
# }

# output "log_group_name" {
#   description = "Nombre del log group"
#   value       = oci_logging_log_group.function_logs.display_name
# }

# # Invocation Examples
# output "function_invocation_example" {
#   description = "Ejemplo de cómo invocar la función"
#   value       = "curl -s '${oci_apigateway_deployment.main.endpoint}/hello' | jq ."
#   sensitive   = false
# }

# output "function_invocation_with_name" {
#   description = "Ejemplo de invocación con parámetro"
#   value       = "curl -s '${oci_apigateway_deployment.main.endpoint}/hello?name=Oracle' | jq ."
#   sensitive   = false
# }

# # Logs Query Example
# output "view_logs_command" {
#   description = "Comando para ver logs de la función"
#   value       = "oci logging-search search-logs --log-group-id ${oci_logging_log_group.function_logs.id} --search-query 'search \"${var.function_name}\"'"
#   sensitive   = false
# }

# # Budget Information
# output "estimated_monthly_cost" {
#   description = "Costo mensual estimado en USD"
#   value       = "3.85"  # API Gateway base cost
#   sensitive   = false
# }

# output "cost_breakdown" {
#   description = "Desglose de costos por componente"
#   value = {
#     api_gateway = "3.65 USD/mes"
#     functions   = "0.00-1.80 USD/mes (según volumen)"
#     logging     = "0.00 USD/mes (10 GB gratis/mes)"
#     total       = "3.85-5.45 USD/mes"
#   }
#   sensitive   = false
# }

# # Resource Summary
# output "deployment_summary" {
#   description = "Resumen del despliegue"
#   value = {
#     region               = var.region
#     compartment_ocid     = var.compartment_ocid
#     app_name             = var.app_name
#     environment          = var.environment
#     function_memory_mb   = var.function_memory
#     function_timeout_sec = var.function_timeout
#     api_enabled          = "true"
#     monitoring_enabled   = var.enable_monitoring
#   }
#   sensitive   = false
# }
