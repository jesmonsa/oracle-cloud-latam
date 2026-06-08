# Outputs del DevOps Pipeline
# TODO: Completar con outputs reales de los recursos implementados

output "devops_project_id" {
  description = "OCID del proyecto DevOps"
  value       = "TODO: Add OCI DevOps Project OCID"
}

output "devops_project_name" {
  description = "Nombre del proyecto DevOps"
  value       = "TODO: Add OCI DevOps Project Name"
}

output "build_pipeline_id" {
  description = "OCID del pipeline de build"
  value       = "TODO: Add Build Pipeline OCID"
}

output "deploy_pipeline_id" {
  description = "OCID del pipeline de despliegue"
  value       = "TODO: Add Deploy Pipeline OCID"
}

output "repository_http_url" {
  description = "URL HTTPS del repositorio de código"
  value       = "TODO: Add Repository HTTP URL"
}

output "repository_ssh_url" {
  description = "URL SSH del repositorio de código"
  value       = "TODO: Add Repository SSH URL"
}

output "container_registry_url" {
  description = "URL del Container Registry"
  value       = "TODO: Add Container Registry URL"
}

output "container_repository_path" {
  description = "Ruta del repositorio de contenedores"
  value       = "TODO: Add Container Repository Path"
}

output "artifact_registry_repositories" {
  description = "Repositorios de artefactos creados"
  value       = "TODO: Add Artifact Registry Repositories"
}

output "notification_topic_id" {
  description = "OCID del tópico SNS para notificaciones"
  value       = "TODO: Add Notification Topic OCID"
}

output "oke_cluster_id" {
  description = "OCID del cluster OKE"
  value       = var.oke_cluster_id
}

output "oke_cluster_name" {
  description = "Nombre del cluster OKE"
  value       = var.oke_cluster_name
}

output "log_group_id" {
  description = "OCID del log group para agregación de logs"
  value       = "TODO: Add Log Group OCID"
}

output "devops_access_instructions" {
  description = "Instrucciones para acceder al proyecto DevOps"
  value = {
    console_url = "https://console.us-phoenix-1.oraclecloud.com/devops/projects"
    cli_command = "oci devops project list --compartment-id ${var.compartment_id}"
    next_steps = [
      "1. Acceder a la consola OCI DevOps",
      "2. Clonar el repositorio de código",
      "3. Configurar build_spec.yaml en el repositorio",
      "4. Hacer push a la rama 'main' para disparar el pipeline",
      "5. Monitorear el progreso en la consola DevOps"
    ]
  }
}

output "important_notes" {
  description = "Notas importantes sobre la configuración"
  value = {
    region                   = var.region
    environment              = var.environment
    compartment_id           = var.compartment_id
    project_name             = var.project_name
    app_name                 = var.app_name
    notifications_enabled    = var.enable_notifications
    monitoring_enabled       = var.enable_monitoring
    artifact_registry_enabled = var.enable_artifact_registry
    log_retention_days       = var.log_retention_days
  }
}
