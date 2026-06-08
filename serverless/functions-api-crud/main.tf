# ============================================================================
# OCI Functions - REST API CRUD con Autonomous Database
# ============================================================================
# Arquitectura serverless con CRUD completo
#
# TODO: Implementar los siguientes recursos:
# - [ ] VCN y Networking
# - [ ] Autonomous Database (Always Free)
# - [ ] Functions Application
# - [ ] Funciones CRUD (GET, POST, PUT, DELETE, LIST)
# - [ ] API Gateway con rutas CRUD
# - [ ] Network Security Groups (NSG)
# - [ ] Logs y Monitoring
# - [ ] Backups automáticos
# - [ ] IAM roles y policies
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

# TODO: Crear VCN para ADB y Functions
# resource "oci_core_vcn" "main" {
#   compartment_id = var.compartment_ocid
#   cidr_block     = "10.0.0.0/16"
#   display_name   = "${var.app_name}-vcn"
# }

# TODO: Crear subnet privada para ADB
# resource "oci_core_subnet" "database" {
#   vcn_id               = oci_core_vcn.main.id
#   cidr_block           = "10.0.1.0/24"
#   compartment_id       = var.compartment_ocid
#   display_name         = "${var.app_name}-db-subnet"
#   map_public_ip_on_launch = false
# }

# TODO: Crear subnet pública para Functions
# resource "oci_core_subnet" "functions" {
#   vcn_id               = oci_core_vcn.main.id
#   cidr_block           = "10.0.2.0/24"
#   compartment_id       = var.compartment_ocid
#   display_name         = "${var.app_name}-fn-subnet"
#   map_public_ip_on_launch = true
# }

# TODO: Crear NSG para ADB
# resource "oci_core_network_security_group" "adb_nsg" {
#   compartment_id = var.compartment_ocid
#   vcn_id         = oci_core_vcn.main.id
#   display_name   = "${var.app_name}-adb-nsg"
# }

# TODO: Agregar rules al NSG para acceso desde Functions
# resource "oci_core_network_security_group_security_rule" "adb_ingress" {
#   network_security_group_id = oci_core_network_security_group.adb_nsg.id
#   direction                  = "INGRESS"
#   protocol                   = "6"  # TCP
#   source                     = "10.0.2.0/24"  # Subnet de Functions
#   destination_port_range {
#     min = 1521
#     max = 1522
#   }
# }

# ============================================================================
# Autonomous Database
# ============================================================================

# TODO: Crear Autonomous Database (Always Free)
# resource "oci_database_autonomous_database" "main" {
#   compartment_id           = var.compartment_ocid
#   db_name                  = replace(var.app_name, "-", "")
#   admin_password           = var.database_admin_password
#   workload_type            = var.database_workload_type
#   database_edition         = "ENTERPRISE_EDITION"
#   is_free_tier             = true
#   
#   storage_size_in_tbs      = var.database_storage_gb / 1024
#   ocpu_count               = var.database_cpu_count
#   
#   db_version               = var.database_version
#   
#   enable_auto_scaling      = false
#   auto_backup_enabled      = var.enable_auto_backup
#   backup_retention_period_in_days = var.backup_retention_days
#   
#   tags = var.tags
# }

# TODO: Crear usuario de aplicación en ADB
# Se ejecutaría con script SQL después de crear ADB

# TODO: Crear tabla ITEMS
# CREATE TABLE items (
#   id NUMBER PRIMARY KEY,
#   name VARCHAR2(255) NOT NULL,
#   description CLOB,
#   price NUMBER(10,2),
#   quantity NUMBER,
#   status VARCHAR2(50) DEFAULT 'ACTIVE',
#   created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
#   updated_at TIMESTAMP DEFAULT SYSTIMESTAMP
# );

# ============================================================================
# IAM for Functions
# ============================================================================

# TODO: Crear dynamic group para Functions
# resource "oci_identity_dynamic_group" "functions" {
#   compartment_id = var.tenancy_ocid
#   name           = "${var.app_name}-functions-dg"
#   description    = "Dynamic group para CRUD functions"
#   matching_rule  = "resource.type = 'fnfunc' AND resource.compartment.id = '${var.compartment_ocid}'"
# }

# TODO: Crear policy para acceso a ADB
# resource "oci_identity_policy" "functions_adb" {
#   compartment_id = var.compartment_ocid
#   name           = "${var.app_name}-functions-adb-policy"
#   
#   statements = [
#     "Allow dynamic-group ${oci_identity_dynamic_group.functions.name} to use autonomous-databases in compartment id ${var.compartment_ocid}",
#   ]
# }

# ============================================================================
# Logging
# ============================================================================

# TODO: Crear logs group
# resource "oci_logging_log_group" "api_logs" {
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-logs"
#   description    = "Logs para CRUD API"
# }

# ============================================================================
# Functions Application and Functions
# ============================================================================

# TODO: Crear Functions Application
# resource "oci_functions_application" "crud_api" {
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-application"
#   subnet_ids     = [oci_core_subnet.functions.id]
#   
#   config = {
#     ENVIRONMENT     = var.environment
#     DATABASE_URL    = oci_database_autonomous_database.main.connection_strings[0].high_availability_connection_string
#     DB_USER         = "app_user"
#     DB_PASSWORD     = var.database_admin_password
#   }
# }

# TODO: Función GET /items (List with pagination)
# resource "oci_functions_function" "get_items" {
#   application_id = oci_functions_application.crud_api.id
#   display_name   = "${var.app_name}-get-items"
#   image          = "..."  # Push a OCIR primero
#   image_digest   = ""
#   memory_in_mbs  = var.function_memory
#   timeout_in_secs = var.function_timeout
# }

# TODO: Función GET /items/:id (Get by ID)
# resource "oci_functions_function" "get_item_by_id" {
#   application_id = oci_functions_application.crud_api.id
#   display_name   = "${var.app_name}-get-item-by-id"
#   image          = "..."
#   image_digest   = ""
#   memory_in_mbs  = var.function_memory
#   timeout_in_secs = var.function_timeout
# }

# TODO: Función POST /items (Create)
# resource "oci_functions_function" "create_item" {
#   application_id = oci_functions_application.crud_api.id
#   display_name   = "${var.app_name}-create-item"
#   image          = "..."
#   image_digest   = ""
#   memory_in_mbs  = var.function_memory
#   timeout_in_secs = var.function_timeout
# }

# TODO: Función PUT /items/:id (Update)
# resource "oci_functions_function" "update_item" {
#   application_id = oci_functions_application.crud_api.id
#   display_name   = "${var.app_name}-update-item"
#   image          = "..."
#   image_digest   = ""
#   memory_in_mbs  = var.function_memory
#   timeout_in_secs = var.function_timeout
# }

# TODO: Función DELETE /items/:id (Delete)
# resource "oci_functions_function" "delete_item" {
#   application_id = oci_functions_application.crud_api.id
#   display_name   = "${var.app_name}-delete-item"
#   image          = "..."
#   image_digest   = ""
#   memory_in_mbs  = var.function_memory
#   timeout_in_secs = var.function_timeout
# }

# ============================================================================
# API Gateway
# ============================================================================

# TODO: Crear API Gateway
# resource "oci_apigateway_api" "crud_api" {
#   compartment_id = var.compartment_ocid
#   display_name   = "${var.app_name}-api"
# }

# TODO: Crear deployment de API Gateway con rutas CRUD
# resource "oci_apigateway_deployment" "crud_api" {
#   compartment_id = var.compartment_ocid
#   gateway_id     = oci_apigateway_api.crud_api.id
#   path_prefix    = "/v1"
#   display_name   = "${var.app_name}-deployment"
#   
#   specification {
#     routes {
#       path    = "/items"
#       methods = ["GET"]
#       backend {
#         type        = "ORACLE_FUNCTIONS_BACKEND"
#         function_id = oci_functions_function.get_items.id
#       }
#     }
#     
#     routes {
#       path    = "/items/{id}"
#       methods = ["GET"]
#       backend {
#         type        = "ORACLE_FUNCTIONS_BACKEND"
#         function_id = oci_functions_function.get_item_by_id.id
#       }
#     }
#     
#     routes {
#       path    = "/items"
#       methods = ["POST"]
#       backend {
#         type        = "ORACLE_FUNCTIONS_BACKEND"
#         function_id = oci_functions_function.create_item.id
#       }
#     }
#     
#     routes {
#       path    = "/items/{id}"
#       methods = ["PUT"]
#       backend {
#         type        = "ORACLE_FUNCTIONS_BACKEND"
#         function_id = oci_functions_function.update_item.id
#       }
#     }
#     
#     routes {
#       path    = "/items/{id}"
#       methods = ["DELETE"]
#       backend {
#         type        = "ORACLE_FUNCTIONS_BACKEND"
#         function_id = oci_functions_function.delete_item.id
#       }
#     }
#   }
# }

# ============================================================================
# Monitoring
# ============================================================================

# TODO: Crear alarmas para Functions
# resource "oci_monitoring_alarm" "function_errors" {
#   count              = var.enable_monitoring ? 1 : 0
#   compartment_id     = var.compartment_ocid
#   display_name       = "${var.app_name}-errors"
#   metric_compartment_id = var.compartment_ocid
#   namespace          = "oci_functions"
#   query              = "errors.rate()"
#   severity           = "CRITICAL"
# }

# TODO: Crear alarmas para ADB
# resource "oci_monitoring_alarm" "database_cpu" {
#   count              = var.enable_monitoring ? 1 : 0
#   compartment_id     = var.compartment_ocid
#   display_name       = "${var.app_name}-db-cpu"
#   metric_compartment_id = var.compartment_ocid
#   namespace          = "oci_database"
#   query              = "cpu_utilization()"
#   severity           = "WARNING"
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
      TerraformModule = "serverless-functions-api-crud"
    }
  )
}
