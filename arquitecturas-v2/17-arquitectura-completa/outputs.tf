# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs — Arquitectura 17: Arquitectura Completa                          ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

output "lb_ip" {
  description = "IP pública del Load Balancer"
  value       = module.lb.ip_publica
}

output "vault_id" {
  description = "OCID del Vault"
  value       = oci_kms_vault.vault.id
}

output "vault_management_endpoint" {
  description = "Management endpoint del Vault"
  value       = oci_kms_vault.vault.management_endpoint
}

output "master_key_id" {
  description = "OCID de la Master Encryption Key"
  value       = oci_kms_key.master_key.id
}

output "webserver_ips" {
  description = "IPs privadas de los webservers"
  value       = module.webserver.ips_privadas
}

output "topic_alertas_id" {
  description = "OCID del Topic de alertas"
  value       = oci_ons_notification_topic.alertas.id
}

output "resumen" {
  value = <<-EOT

  ╔══════════════════════════════════════════════════════════════╗
  ║  Arquitectura 17 — Arquitectura Completa                   ║
  ╠══════════════════════════════════════════════════════════════╣
  ║                                                            ║
  ║  Load Balancer:  ${module.lb.ip_publica}
  ║                                                            ║
  ║  Webservers:                                               ║
  ║    Web-1:        ${module.webserver.ips_privadas[0]} (privado)
  ║    Web-2:        ${module.webserver.ips_privadas[1]} (privado)
  ║                                                            ║
  ║  Vault (KMS):    ${local.prefijo}-vault
  ║    Master Key:   AES-256
  ║                                                            ║
  ║  Logging:        VCN Flow Logs + Custom Logs               ║
  ║  Monitoring:     CPU > 80% → ONS → Email                  ║
  ║  Events:         Instance state → ONS → Email              ║
  ║  Bastion:        ${local.prefijo}-bastion
  ║  ONS Topic:      ${local.prefijo}-alertas
  ╚══════════════════════════════════════════════════════════════╝

  EOT
}
