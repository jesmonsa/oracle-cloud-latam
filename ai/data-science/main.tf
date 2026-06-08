# OCI Data Science Project
resource "oci_datascience_project" "main" {
  compartment_id = var.compartment_id
  display_name   = var.data_science_project_name
  description    = var.data_science_description

  freeform_tags = var.tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Notebook Session (CPU)
resource "oci_datascience_notebook_session" "main" {
  count                         = var.notebook_enabled ? 1 : 0
  project_id                    = oci_datascience_project.main.id
  compartment_id                = var.compartment_id
  display_name                  = var.notebook_display_name
  notebook_session_shape_config_details {
    ocpu           = var.notebook_ocpus
    memory_in_gbs  = var.notebook_memory_in_gbs
  }
  notebook_session_configuration_details {
    shape = var.notebook_shape
  }

  freeform_tags = var.tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Notebook Session (GPU - Optional)
resource "oci_datascience_notebook_session" "gpu" {
  count                         = var.gpu_notebook_enabled ? 1 : 0
  project_id                    = oci_datascience_project.main.id
  compartment_id                = var.compartment_id
  display_name                  = var.gpu_notebook_display_name
  notebook_session_shape_config_details {
    gpu = 1
  }
  notebook_session_configuration_details {
    shape = var.gpu_notebook_shape
  }

  freeform_tags = var.tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Object Storage Bucket
data "oci_objectstorage_namespace" "main" {
  compartment_id = var.compartment_id
}

resource "oci_objectstorage_bucket" "main" {
  compartment_id = var.compartment_id
  name           = var.object_storage_bucket
  namespace      = data.oci_objectstorage_namespace.main.namespace

  access_type           = "NoPublicAccess"
  versioning            = var.bucket_versioning_enabled ? "Enabled" : "Disabled"
  storage_tier          = "Standard"
  auto_tiering          = "InfrequentAccessAuto"
  object_events_enabled = true

  freeform_tags = var.tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# TODO: Agregar recursos adicionales
# - Model Catalog
# - Feature Store
# - Jobs
# - API Gateway para Model Deployment
