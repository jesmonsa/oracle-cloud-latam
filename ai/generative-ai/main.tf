# Object Storage Buckets for Documents and Embeddings
data "oci_objectstorage_namespace" "main" {
  compartment_id = var.compartment_id
}

resource "oci_objectstorage_bucket" "documents" {
  compartment_id = var.compartment_id
  name           = var.documents_bucket_name
  namespace      = data.oci_objectstorage_namespace.main.namespace

  access_type           = "NoPublicAccess"
  versioning            = "Enabled"
  storage_tier          = "Standard"
  object_events_enabled = true

  freeform_tags = var.tags
}

# TODO: Agregar recursos
# - Vector Database (MySQL HeatWave / ADB / OpenSearch)
# - API Gateway para LLM endpoints
# - Fine-tuning Configuration
# - RAG Pipeline Orchestration
# - Conversation Storage & History
# - Custom Metrics para token usage
# - Logging para audit y debugging
# - Functions para processing asincrónico
