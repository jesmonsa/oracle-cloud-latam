output "data_science_project_id" {
  description = "OCID del proyecto Data Science"
  value       = oci_datascience_project.main.id
}

output "data_science_project_name" {
  description = "Nombre del proyecto Data Science"
  value       = oci_datascience_project.main.display_name
}

output "notebook_session_id" {
  description = "OCID de Notebook Session"
  value       = try(oci_datascience_notebook_session.main[0].id, null)
}

output "notebook_session_url" {
  description = "URL de acceso a Notebook Session"
  value       = try(oci_datascience_notebook_session.main[0].notebook_session_url, null)
}

output "gpu_notebook_session_id" {
  description = "OCID de GPU Notebook Session"
  value       = try(oci_datascience_notebook_session.gpu[0].id, null)
}

output "gpu_notebook_session_url" {
  description = "URL de acceso a GPU Notebook"
  value       = try(oci_datascience_notebook_session.gpu[0].notebook_session_url, null)
}

output "object_storage_namespace" {
  description = "Object Storage namespace"
  value       = data.oci_objectstorage_namespace.main.namespace
}

output "object_storage_bucket_name" {
  description = "Nombre del bucket Object Storage"
  value       = oci_objectstorage_bucket.main.name
}

output "object_storage_bucket_uri" {
  description = "URI del bucket Object Storage"
  value       = "oci://${oci_objectstorage_bucket.main.name}@${data.oci_objectstorage_namespace.main.namespace}"
}
