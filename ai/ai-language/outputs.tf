output "input_bucket_name" {
  description = "Nombre del bucket de entrada"
  value       = oci_objectstorage_bucket.input.name
}

output "input_bucket_uri" {
  description = "URI del bucket de entrada"
  value       = "oci://${oci_objectstorage_bucket.input.name}@${data.oci_objectstorage_namespace.main.namespace}"
}

output "results_bucket_name" {
  description = "Nombre del bucket de resultados"
  value       = oci_objectstorage_bucket.results.name
}

output "results_bucket_uri" {
  description = "URI del bucket de resultados"
  value       = "oci://${oci_objectstorage_bucket.results.name}@${data.oci_objectstorage_namespace.main.namespace}"
}

output "object_storage_namespace" {
  description = "Object Storage namespace"
  value       = data.oci_objectstorage_namespace.main.namespace
}

output "supported_languages" {
  description = "Idiomas soportados"
  value       = var.supported_languages
}
