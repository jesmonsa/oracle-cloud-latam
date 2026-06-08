output "documents_bucket_name" {
  description = "Nombre del bucket de documentos"
  value       = oci_objectstorage_bucket.documents.name
}

output "documents_bucket_uri" {
  description = "URI del bucket de documentos"
  value       = "oci://${oci_objectstorage_bucket.documents.name}@${data.oci_objectstorage_namespace.main.namespace}"
}

output "object_storage_namespace" {
  description = "Object Storage namespace"
  value       = data.oci_objectstorage_namespace.main.namespace
}

output "llm_model" {
  description = "Modelo LLM configurado"
  value       = var.llm_model
}

output "embedding_model" {
  description = "Modelo de embeddings configurado"
  value       = var.embedding_model
}

output "rag_enabled" {
  description = "RAG pipeline habilitado"
  value       = var.enable_rag
}

output "vector_db_type" {
  description = "Tipo de Vector Database"
  value       = var.vector_db_type
}
