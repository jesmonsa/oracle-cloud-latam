# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs — Arquitectura 16: Vault + Baselines                              ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

output "vault_id" {
  description = "OCID del Vault"
  value       = oci_kms_vault.vault.id
}

output "vault_management_endpoint" {
  description = "Management endpoint del Vault"
  value       = oci_kms_vault.vault.management_endpoint
}

output "vault_crypto_endpoint" {
  description = "Crypto endpoint del Vault"
  value       = oci_kms_vault.vault.crypto_endpoint
}

output "master_key_id" {
  description = "OCID de la Master Encryption Key"
  value       = oci_kms_key.master_key.id
}

output "topic_seguridad_id" {
  description = "OCID del Topic de seguridad"
  value       = oci_ons_notification_topic.seguridad.id
}

output "resumen" {
  value = <<-EOT

  ╔══════════════════════════════════════════════════════════════╗
  ║  Arquitectura 16 — Vault + Baselines                       ║
  ╠══════════════════════════════════════════════════════════════╣
  ║                                                            ║
  ║  Vault (KMS):                                              ║
  ║    Vault:        ${local.prefijo}-vault
  ║    Master Key:   ${local.prefijo}-master-key (AES-256)
  ║    Management:   ${oci_kms_vault.vault.management_endpoint}
  ║                                                            ║
  ║  Cloud Guard:    (requiere tenancy admin)                   ║
  ║                                                            ║
  ║  Events:                                                   ║
  ║    Vault Events: Creación/Rotación de claves               ║
  ║    CG Events:    Problemas detectados (cuando habilitado)  ║
  ║                                                            ║
  ║  ONS Topic:      ${local.prefijo}-seguridad
  ║  Email:          ${var.email_notificacion}
  ╚══════════════════════════════════════════════════════════════╝

  EOT
}
