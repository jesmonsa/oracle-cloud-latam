# ============================================================================
# OCI Functions - Container-Based Functions
# ============================================================================
# Arquitectura con funciones basadas en Docker
#
# TODO: Implementar los siguientes recursos:
# - [ ] OCIR Repository
# - [ ] Functions Application
# - [ ] Container Function
# - [ ] API Gateway
# - [ ] Logging
# - [ ] IAM roles para OCIR access
# - [ ] Monitoring
# ============================================================================

# ============================================================================
# Data Sources
# ============================================================================

data "oci_identity_availability_domains" "available" {
  compartment_id = var.tenancy_ocid
}

# ============================================================================
# OCIR Repository
# ============================================================================

# TODO: Crear repositorio en OCIR
# resource "oci_artifacts_container_repository" "container_repo" {
#   compartment_id = var.compartment_ocid
#   display_name   = var.ocir_repository_name != "" ? var.ocir_repository_name : var.app_name
#   repository_type = "PRIVATE"
#   
#   is_immutable = true  # Prevenir sobrescritura de tags
#   
#   tags = var.tags
# }

# ============================================================================
# IAM for Functions
# ============================================================================

# TODO: Crear dynamic group para Functions
# resource "oci_identity_dynamic_group" "container_functions" {
#   compartment_id = var.tenancy_ocid
#   name           = "${var.app_name}-container-dg"
#   description    = "Dynamic group para container functions"
#   matching_rule  = "resource.type = 'fnfunc' AND resource.compartment.id = '${var.compartment_ocid}'"
# }

# TODO: Crear policy para acceso a OCIR
# resource "oci_identity_policy" "container_policy" {
#   compartment_id = var.compartment_ocid
#   name           = "${var.app_name}-container-policy"
#   
#   statements = [
#     "Allow dynamic-group ${oci_identity_dynamic_group.container_functions.name} to pull from repository ${oci_artifacts_container_repository.container_repo.display_name} in compartment id ${var.compartment_ocid}",
#   ]
# }

# ============================================================================
# Logging
# ============================================================================

# TODO: Crear logs group
# resource "oci_logging_log_group" "container_logs" {
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-container-logs"
#   description    = "Logs para container functions"
# }

# ============================================================================
# Functions Application
# ============================================================================

# TODO: Crear Functions Application
# resource "oci_functions_application" "container_app" {
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-application"
#   
#   config = merge(
#     var.function_environment_variables,
#     {
#       ENVIRONMENT = var.environment
#     }
#   )
#   
#   tags = var.tags
# }

# ============================================================================
# Container Function
# ============================================================================

# TODO: Crear función basada en imagen Docker
# resource "oci_functions_function" "container_function" {
#   application_id = oci_functions_application.container_app.id
#   display_name   = var.function_name
#   
#   # Usar imagen Docker del OCIR
#   image           = var.docker_image_url
#   image_digest    = var.image_digest != "" ? var.image_digest : null
#   
#   memory_in_mbs  = var.function_memory
#   timeout_in_secs = var.function_timeout
#   
#   # Configuración de recursos
#   provisioned_concurrency_config {
#     provisioned_concurrent_executions = 0  # Usar auto-scaling
#   }
#   
#   # Variables de entorno
#   environment_variables = var.function_environment_variables
#   
#   tags = var.tags
# }

# ============================================================================
# API Gateway (para exponer función)
# ============================================================================

# TODO: Crear API Gateway
# resource "oci_apigateway_api" "container_api" {
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-api"
#   
#   tags = var.tags
# }

# TODO: Crear deployment de API Gateway
# resource "oci_apigateway_deployment" "container_api" {
#   compartment_id = var.compartment_ocid
#   gateway_id     = oci_apigateway_api.container_api.id
#   path_prefix    = "/v1"
#   display_name   = "${var.app_name}-deployment"
#   
#   specification {
#     routes {
#       path    = "/"
#       methods = ["GET", "POST", "PUT", "DELETE"]
#       backend {
#         type        = "ORACLE_FUNCTIONS_BACKEND"
#         function_id = oci_functions_function.container_function.id
#       }
#     }
#   }
#   
#   tags = var.tags
# }

# ============================================================================
# Monitoring
# ============================================================================

# TODO: Crear alarma para errores de función
# resource "oci_monitoring_alarm" "function_errors" {
#   count              = var.enable_monitoring ? 1 : 0
#   compartment_id     = var.compartment_ocid
#   display_name       = "${var.function_name}-errors"
#   metric_compartment_id = var.compartment_ocid
#   namespace          = "oci_functions"
#   query              = "errors.rate()"
#   severity           = "CRITICAL"
#   
#   tags = var.tags
# }

# TODO: Crear alarma para duración de función
# resource "oci_monitoring_alarm" "function_duration" {
#   count              = var.enable_monitoring ? 1 : 0
#   compartment_id     = var.compartment_ocid
#   display_name       = "${var.function_name}-duration"
#   metric_compartment_id = var.compartment_ocid
#   namespace          = "oci_functions"
#   query              = "duration_p99()"
#   threshold          = var.function_timeout * 1000 * 0.8  # 80% del timeout
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
      TerraformModule = "serverless-functions-container"
    }
  )
  
  # Extraer información de docker_image_url
  docker_image_parts = split("/", var.docker_image_url)
  docker_repo_name = var.ocir_repository_name != "" ? var.ocir_repository_name : local.docker_image_parts[length(local.docker_image_parts) - 1]
}
