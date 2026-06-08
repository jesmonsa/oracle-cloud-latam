# Outputs de Artifact Registry
# TODO: Completar con outputs reales de los recursos implementados

output "artifact_namespace" {
  description = "Namespace de Artifact Registry"
  value       = var.artifact_namespace
}

output "maven_releases_repo_id" {
  description = "OCID del repositorio Maven releases"
  value       = "TODO: Add Maven Releases Repository OCID"
}

output "maven_snapshots_repo_id" {
  description = "OCID del repositorio Maven snapshots"
  value       = "TODO: Add Maven Snapshots Repository OCID"
}

output "npm_repo_id" {
  description = "OCID del repositorio NPM"
  value       = "TODO: Add NPM Repository OCID"
}

output "container_registry_url" {
  description = "URL del Container Registry"
  value       = "TODO: Add Container Registry URL"
}

output "security_info" {
  description = "Información sobre configuración de seguridad"
  value = {
    image_scanning_enabled = var.enable_image_scanning
    encryption_enabled     = var.enable_encryption
    audit_logging_enabled  = var.enable_audit_logging
    replication_enabled    = var.enable_replication
    retention_days         = var.artifact_retention_days
  }
}
