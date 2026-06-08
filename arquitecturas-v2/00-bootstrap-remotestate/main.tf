# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Main - Bucket + Customer Secret Key para Remote State                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  compartment_id = var.compartment_ocid != "" ? var.compartment_ocid : var.tenancy_ocid

  tags = {
    Proyecto    = var.proyecto
    Proposito   = "terraform-remote-state"
    Gestionado  = "terraform"
    CreadoPor   = "bootstrap"
    FechaCreado = formatdate("YYYY-MM-DD", timestamp())
  }
}

# ─── Namespace del Tenancy (requerido para S3 endpoint) ──────────────────────
data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.tenancy_ocid
}

# ─── Bucket para almacenar tfstate ───────────────────────────────────────────
resource "oci_objectstorage_bucket" "tfstate" {
  compartment_id = local.compartment_id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = var.bucket_name
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"
  freeform_tags  = local.tags

  # Versionado: mantiene historial de estados anteriores
  versioning = "Enabled"

  # Auto-eliminar versiones antiguas después de 30 días para ahorrar espacio
  # (dentro del free tier esto no tiene costo adicional)
}

# ─── Lifecycle Rule: limpiar versiones antiguas ──────────────────────────────
# NOTA: Requiere IAM policy para el service principal de Object Storage.
# Para habilitarla, crear en Identity > Policies:
#   Allow service objectstorage-<region> to manage object-family in tenancy
# Por ahora los state files son tan pequeños (~KB) que no es necesaria.
#
# resource "oci_objectstorage_object_lifecycle_policy" "cleanup" {
#   namespace  = data.oci_objectstorage_namespace.ns.namespace
#   bucket     = oci_objectstorage_bucket.tfstate.name
#   rules {
#     name        = "eliminar-versiones-antiguas"
#     action      = "DELETE"
#     is_enabled  = true
#     target      = "previous-object-versions"
#     time_amount = 90
#     time_unit   = "DAYS"
#   }
# }

# ─── Customer Secret Key (credenciales S3 para Terraform backend) ────────────
# Terraform usa el protocolo S3 para comunicarse con OCI Object Storage.
# Estas credenciales son el "access_key" y "secret_key" necesarios.
resource "oci_identity_customer_secret_key" "terraform_s3" {
  display_name = "terraform-remote-state-s3"
  user_id      = var.current_user_ocid
}

# ─── Generar archivo backend.hcl (para usar con -backend-config) ────────────
resource "local_file" "backend_config" {
  filename = "${path.module}/backend.hcl"
  content = join("\n", [
    "# Backend Config - Generado por 00-bootstrap-remotestate",
    "# Uso: terraform init -backend-config=../00-bootstrap-remotestate/backend.hcl",
    "bucket                      = \"${var.bucket_name}\"",
    "region                      = \"${var.region}\"",
    "endpoint                    = \"https://${data.oci_objectstorage_namespace.ns.namespace}.compat.objectstorage.${var.region}.oraclecloud.com\"",
    "shared_credentials_file     = \"${replace(path.module, "\\", "/")}/../00-bootstrap-remotestate/s3_credentials\"",
    "skip_region_validation      = true",
    "skip_credentials_validation = true",
    "skip_metadata_api_check     = true",
    "skip_requesting_account_id  = true",
    "use_path_style              = true",
    "encrypt                     = false",
    "",
  ])

  file_permission = "0600"
}

# ─── Generar archivo de credenciales S3 (formato AWS) ───────────────────────
resource "local_file" "s3_credentials" {
  filename = "${path.module}/s3_credentials"
  content = join("\n", [
    "[default]",
    "aws_access_key_id = ${oci_identity_customer_secret_key.terraform_s3.id}",
    "aws_secret_access_key = ${oci_identity_customer_secret_key.terraform_s3.key}",
    "",
  ])

  file_permission = "0600"
}
