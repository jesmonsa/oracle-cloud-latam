# Outputs de Terraform Cloud Configuration
# TODO: Completar con outputs reales de los recursos implementados

output "tfc_organization_name" {
  description = "Nombre de la organización en Terraform Cloud"
  value       = var.tfc_organization
}

output "tfc_workspace_id" {
  description = "ID del workspace en Terraform Cloud"
  value       = "TODO: Add Workspace ID"
}

output "tfc_workspace_name" {
  description = "Nombre del workspace"
  value       = var.workspace_name
}

output "terraform_cloud_url" {
  description = "URL para acceder a Terraform Cloud"
  value       = "https://app.terraform.io/app/${var.tfc_organization}/workspaces/${var.workspace_name}"
}

output "oci_state_bucket_name" {
  description = "Nombre del bucket Object Storage para estado"
  value       = "TODO: Add Bucket Name"
}

output "oci_state_bucket_namespace" {
  description = "Namespace del bucket"
  value       = "TODO: Add Namespace"
}

output "kms_key_id" {
  description = "OCID de la clave KMS para encriptación"
  value       = "TODO: Add KMS Key OCID"
}

output "execution_mode" {
  description = "Modo de ejecución del workspace"
  value       = var.execution_mode
}

output "terraform_version" {
  description = "Versión de Terraform configurada"
  value       = var.terraform_version
}

output "vcs_repository" {
  description = "Repositorio VCS conectado"
  value       = var.enable_vcs_integration ? var.vcs_repository : "No configurado"
}

output "vcs_branch" {
  description = "Rama de VCS monitoreada"
  value       = var.enable_vcs_integration ? var.vcs_branch : "No configurado"
}

output "auto_apply_enabled" {
  description = "Si el auto-apply está habilitado"
  value       = var.enable_auto_apply
}

output "cost_estimation_enabled" {
  description = "Si la estimación de costos está habilitada"
  value       = var.enable_cost_estimation
}

output "sentinel_policies_enabled" {
  description = "Si Policy as Code está habilitado"
  value       = var.enable_sentinel_policies
}

output "tfc_api_documentation" {
  description = "Documentación de API de Terraform Cloud"
  value = {
    api_base_url = "https://app.terraform.io/api/v2"
    authentication = "Bearer token (en header Authorization)"
    docs = "https://www.terraform.io/cloud/api-docs"
  }
}

output "terraform_cloud_setup_instructions" {
  description = "Instrucciones para configurar Terraform Cloud"
  value = {
    step_1 = "Crear cuenta en https://app.terraform.io"
    step_2 = "Crear organización o usar existente"
    step_3 = "Generar API token en Settings → Tokens"
    step_4 = "Conectar VCS provider (GitHub/GitLab)"
    step_5 = "Crear workspace seleccionando VCS repo"
    step_6 = "Configurar variables de Terraform y credenciales OCI"
    step_7 = "Hacer push a Git para disparar primer plan"
    step_8 = "Revisar plan en UI de Terraform Cloud"
  }
}

output "oci_backend_configuration" {
  description = "Configuración del backend OCI"
  value = {
    bucket_name = "TODO: ${local.bucket_name}"
    region      = var.region
    encryption  = var.enable_state_encryption ? "Enabled with KMS" : "Default"
    versioning  = "Enabled"
    state_locking = "Enabled (DynamoDB in Terraform Cloud)"
  }
}

output "security_configuration" {
  description = "Configuración de seguridad"
  value = {
    state_encryption  = var.enable_state_encryption
    kms_encryption    = var.kms_key_id != "" ? "Custom KMS Key" : "Default Encryption"
    require_approval  = var.require_approval
    rbac_enabled      = true
    audit_logging     = var.enable_audit_logging
    sentinel_policies = var.enable_sentinel_policies
  }
}

output "workspace_settings" {
  description = "Configuración del workspace"
  value = {
    execution_mode        = var.execution_mode
    terraform_version     = var.terraform_version
    auto_apply            = var.enable_auto_apply
    require_approval      = var.require_approval
    cost_estimation       = var.enable_cost_estimation
    vcs_integration       = var.enable_vcs_integration
    notifications_enabled = var.enable_notifications
  }
}

output "important_notes" {
  description = "Notas importantes"
  value = {
    note_1 = "Las credenciales OCI deben configurarse en el workspace como variables sensibles"
    note_2 = "No incluir credenciales en git - usar Terraform Cloud para almacenarlas"
    note_3 = "Habilitar state locking para evitar conflictos en ejecuciones concurrentes"
    note_4 = "Revisar y aprobar todos los plans antes de aplicar en producción"
    note_5 = "Mantener logs de auditoría para compliance y troubleshooting"
  }
}

output "cost_estimation_benefits" {
  description = "Beneficios de habilitar Cost Estimation"
  value = [
    "Estimar impacto de cambios antes de aplicar",
    "Detectar recursos costosos antes de crearlos",
    "Comparar costos entre diferentes configuraciones",
    "Policías de costo para limitar gastos",
    "Análisis de tendencias de costo"
  ]
}

output "next_steps" {
  description = "Próximos pasos después del despliegue"
  value = {
    step_1 = "Configurar variables de Terraform en el workspace"
    step_2 = "Configurar credenciales OCI (environment variables)"
    step_3 = "Hacer push a Git para disparar primer run"
    step_4 = "Revisar plan y aprobar cambios"
    step_5 = "Monitorear la ejecución en Terraform Cloud UI"
    step_6 = "Configurar webhooks para notificaciones"
    step_7 = "Crear políticas Sentinel para compliance"
    step_8 = "Documentar estándares de IaC para el equipo"
  }
}
