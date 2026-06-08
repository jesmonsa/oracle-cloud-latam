# ============================================================================
# Outputs for Container Functions
# ============================================================================

# TODO: Descomentar los siguientes outputs:

# # OCIR Repository
# output "ocir_repository_url" {
#   description = "URL del repositorio en OCIR"
#   value       = "${var.ocir_region}.ocir.io/${var.ocir_namespace}/${oci_artifacts_container_repository.container_repo.display_name}"
# }

# # Functions
# output "application_id" {
#   description = "OCID de Functions Application"
#   value       = oci_functions_application.container_app.id
# }

# output "function_id" {
#   description = "OCID de la función container"
#   value       = oci_functions_function.container_function.id
# }

# output "function_invoke_endpoint" {
#   description = "Endpoint directo de función"
#   value       = oci_functions_function.container_function.invoke_endpoint
# }

# # API Gateway
# output "api_endpoint" {
#   description = "Endpoint del API Gateway"
#   value       = oci_apigateway_deployment.container_api.endpoint
# }

# # Build & Push Instructions
# output "build_and_push_commands" {
#   description = "Comandos para compilar y hacer push de la imagen"
#   value       = <<-EOT
#     # 1. Login a OCIR
#     echo $OCI_CLI_AUTH_TOKEN | docker login -u $OCI_USERNAME --password-stdin ${var.ocir_region}.ocir.io
#     
#     # 2. Build imagen
#     docker build -t ${var.ocir_region}.ocir.io/${var.ocir_namespace}/${local.docker_repo_name}:latest .
#     
#     # 3. Push a OCIR
#     docker push ${var.ocir_region}.ocir.io/${var.ocir_namespace}/${local.docker_repo_name}:latest
#     
#     # 4. Obtener digest para actualizar Terraform
#     docker inspect --format='{{.RepoDigests}}' \
#       ${var.ocir_region}.ocir.io/${var.ocir_namespace}/${local.docker_repo_name}:latest
#   EOT
# }

# # Test Invocation
# output "test_invocation_command" {
#   description = "Comando para probar la función"
#   value       = "curl -X POST '${oci_apigateway_deployment.container_api.endpoint}/' -H 'Content-Type: application/json' -d '{...}'"
# }

# # Estimated Monthly Cost
# output "estimated_monthly_cost" {
#   description = "Costo estimado mensual"
#   value       = "3.85 USD"
# }
