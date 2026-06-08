# ============================================================================
# OCI Functions - Hello World Básico
# ============================================================================
# Arquitectura minimalista con Function y API Gateway
# 
# TODO: Implementar los siguientes recursos:
# - [ ] VCN (Virtual Cloud Network)
# - [ ] Subnet pública
# - [ ] Internet Gateway
# - [ ] Application de Functions
# - [ ] Function Python (hello-world)
# - [ ] IAM Role para Function
# - [ ] API Gateway
# - [ ] API Gateway Deployment
# - [ ] Logs Group
# - [ ] Monitoring Dashboard (opcional)
# - [ ] Budget Alert (opcional)
# ============================================================================

# ============================================================================
# Data Sources
# ============================================================================

# Obtener información de la región
data "oci_identity_regions" "current" {
  filter {
    name   = "name"
    values = [var.region]
  }
}

# ============================================================================
# Networking Resources
# ============================================================================

# TODO: Crear VCN con CIDR: var.vcn_cidr_block
# resource "oci_core_vcn" "main" {
#   compartment_id = var.compartment_ocid
#   cidr_block     = var.vcn_cidr_block
#   display_name   = "${var.app_name}-vcn"
#   dns_label      = replace(var.app_name, "-", "")
#   
#   tags = var.tags
# }

# TODO: Crear subnet pública con CIDR: var.subnet_cidr_block
# resource "oci_core_subnet" "public" {
#   compartment_id      = var.compartment_ocid
#   vcn_id              = oci_core_vcn.main.id
#   cidr_block          = var.subnet_cidr_block
#   display_name        = "${var.app_name}-public-subnet"
#   dns_label           = "public"
#   map_public_ip_on_launch = true
#   
#   tags = var.tags
# }

# TODO: Crear Internet Gateway
# resource "oci_core_internet_gateway" "main" {
#   compartment_id = var.compartment_ocid
#   vcn_id         = oci_core_vcn.main.id
#   display_name   = "${var.app_name}-igw"
#   enabled        = true
#   
#   tags = var.tags
# }

# TODO: Crear route table y agregar ruta a IGW
# resource "oci_core_route_table" "public" {
#   compartment_id = var.compartment_ocid
#   vcn_id         = oci_core_vcn.main.id
#   display_name   = "${var.app_name}-public-rt"
#   
#   route_rules {
#     destination       = "0.0.0.0/0"
#     destination_type  = "CIDR_BLOCK"
#     network_entity_id = oci_core_internet_gateway.main.id
#   }
#   
#   tags = var.tags
# }

# TODO: Asociar route table a subnet
# resource "oci_core_route_table_attachment" "public" {
#   subnet_id      = oci_core_subnet.public.id
#   route_table_id = oci_core_route_table.public.id
# }

# ============================================================================
# IAM Resources for Functions
# ============================================================================

# TODO: Crear IAM role para Function
# resource "oci_identity_dynamic_group" "function_dg" {
#   compartment_id = var.tenancy_ocid
#   name           = "${var.app_name}-functions-dg"
#   description    = "Dynamic group para functions en ${var.app_name}"
#   matching_rule  = "resource.type = 'fnfunc' AND resource.compartment.id = '${var.compartment_ocid}'"
#   
#   tags = var.tags
# }

# TODO: Crear policy para Function
# resource "oci_identity_policy" "function_policy" {
#   compartment_id = var.compartment_ocid
#   name           = "${var.app_name}-function-policy"
#   description    = "Policy para permisos de function"
#   
#   statements = [
#     "Allow dynamic-group ${oci_identity_dynamic_group.function_dg.name} to manage object-family in compartment id ${var.compartment_ocid}",
#     "Allow dynamic-group ${oci_identity_dynamic_group.function_dg.name} to manage logging-family in compartment id ${var.compartment_ocid}",
#   ]
#   
#   tags = var.tags
# }

# ============================================================================
# Logging Resources
# ============================================================================

# TODO: Crear logs group para función
# resource "oci_logging_log_group" "function_logs" {
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-logs"
#   description    = "Logs group para ${var.function_name}"
#   
#   tags = var.tags
# }

# TODO: Crear log (dentro del group) para capturar invocaciones
# resource "oci_logging_log" "function_invocations" {
#   display_name       = "${var.function_name}-invocations"
#   log_group_id       = oci_logging_log_group.function_logs.id
#   log_type           = "SERVICE"
#   source_service     = "functions"
#   source_resource    = oci_functions_function.hello_world.id
#   
#   tags = var.tags
# }

# ============================================================================
# Functions Resources
# ============================================================================

# TODO: Crear Application de Functions
# resource "oci_functions_application" "main" {
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-application"
#   subnet_ids     = [oci_core_subnet.public.id]
#   
#   config = {
#     "ENVIRONMENT" = var.environment
#   }
#   
#   tags = var.tags
# }

# TODO: Crear Function (hello-world)
# Nota: El código de la función debe estar en un ZIP
# Se asume que existe fn_func.zip en el directorio
# resource "oci_functions_function" "hello_world" {
#   application_id = oci_functions_application.main.id
#   display_name   = var.function_name
#   image          = "${data.oci_identity_regions.current.regions[0].key_name}.ocir.io/..."
#   image_digest   = ""
#   memory_in_mbs  = var.function_memory
#   timeout_in_secs = var.function_timeout
#   
#   environment_variables = {
#     "APP_NAME"    = var.app_name
#     "ENVIRONMENT" = var.environment
#   }
#   
#   provisioned_concurrency_config {
#     provisioned_concurrent_executions = var.function_provisioned_concurrency
#   }
#   
#   tags = var.tags
# }

# ============================================================================
# API Gateway Resources
# ============================================================================

# TODO: Crear API Gateway
# resource "oci_apigateway_api" "main" {
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-api"
#   
#   tags = var.tags
# }

# TODO: Crear API Gateway Deployment
# resource "oci_apigateway_deployment" "main" {
#   compartment_id = var.compartment_ocid
#   gateway_id     = oci_apigateway_api.main.id
#   path_prefix    = "/"
#   display_name   = "${var.app_name}-deployment"
#   
#   specification {
#     request_policies {
#       logging_policies {
#         access_log {
#           is_enabled = var.api_gateway_enable_metrics
#           log_group_id = oci_logging_log_group.function_logs.id
#         }
#       }
#     }
#     
#     routes {
#       path   = "/hello"
#       methods = ["GET"]
#       backend {
#         type = "ORACLE_FUNCTIONS_BACKEND"
#         function_id = oci_functions_function.hello_world.id
#       }
#     }
#   }
#   
#   tags = var.tags
# }

# ============================================================================
# Monitoring Resources
# ============================================================================

# TODO: Crear Monitoring Dashboard (si enable_monitoring = true)
# resource "oci_monitoring_alarm" "function_errors" {
#   count              = var.enable_monitoring ? 1 : 0
#   compartment_id     = var.compartment_ocid
#   display_name       = "${var.function_name}-error-alarm"
#   metric_compartment_id = var.compartment_ocid
#   namespace          = "oci_functions"
#   query              = "errors.rate()"
#   severity           = "CRITICAL"
#   destinations       = []  # TODO: Agregar SNS topic para notificaciones
#   
#   tags = var.tags
# }

# ============================================================================
# Budget Management
# ============================================================================

# TODO: Crear Budget Alert (si es necesario)
# resource "oci_budget_budget" "functions_budget" {
#   compartment_id = var.tenancy_ocid
#   amount         = var.budget_alert_amount
#   display_name   = "${var.app_name}-budget"
#   reset_period   = "MONTHLY"
#   
#   tags = var.tags
# }

# ============================================================================
# Locals para valores computados
# ============================================================================

locals {
  common_tags = merge(
    var.tags,
    {
      Name            = var.app_name
      CreatedAt       = timestamp()
      TerraformModule = "serverless-functions-basico"
    }
  )

  resource_name_prefix = "${var.app_name}-${var.environment}"
}
