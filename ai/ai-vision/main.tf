# Object Storage Buckets
data "oci_objectstorage_namespace" "main" {
  compartment_id = var.compartment_id
}

resource "oci_objectstorage_bucket" "input" {
  compartment_id = var.compartment_id
  name           = var.input_bucket_name
  namespace      = data.oci_objectstorage_namespace.main.namespace

  access_type           = "NoPublicAccess"
  versioning            = var.bucket_versioning_enabled ? "Enabled" : "Disabled"
  storage_tier          = "Standard"
  object_events_enabled = true

  freeform_tags = var.tags
}

resource "oci_objectstorage_bucket" "results" {
  compartment_id = var.compartment_id
  name           = var.results_bucket_name
  namespace      = data.oci_objectstorage_namespace.main.namespace

  access_type           = "NoPublicAccess"
  versioning            = var.bucket_versioning_enabled ? "Enabled" : "Disabled"
  storage_tier          = "Standard"
  object_events_enabled = true

  freeform_tags = var.tags
}

# TODO: Agregar recursos
# - API Gateway para exponer Vision API
# - Authentication/Authorization
# - Function/Lambda para procesamiento automático
# - Monitoring y Logging
# - Custom Metrics
