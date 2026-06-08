# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs — Arquitectura 15: Observabilidad                                 ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

output "webserver_ip_publica" {
  description = "IP pública del webserver"
  value       = module.webserver.ips_publicas[0]
}

output "log_group_app_id" {
  description = "OCID del Log Group de aplicación"
  value       = oci_logging_log_group.app_logs.id
}

output "log_group_vcn_id" {
  description = "OCID del Log Group de VCN"
  value       = oci_logging_log_group.vcn_logs.id
}

output "alarm_cpu_id" {
  description = "OCID del Alarm de CPU alta"
  value       = oci_monitoring_alarm.cpu_alta.id
}

output "topic_alertas_id" {
  description = "OCID del Topic de notificaciones"
  value       = oci_ons_notification_topic.alertas.id
}

output "event_rule_id" {
  description = "OCID de la Event Rule"
  value       = oci_events_rule.instancia_cambio_estado.id
}

output "resumen" {
  value = <<-EOT

  ╔══════════════════════════════════════════════════════════════╗
  ║  Arquitectura 15 — Observabilidad                          ║
  ╠══════════════════════════════════════════════════════════════╣
  ║                                                            ║
  ║  Webserver:      ${module.webserver.ips_publicas[0]}
  ║                                                            ║
  ║  Logging:                                                  ║
  ║    Log Group App:  ${local.prefijo}-log-group-app
  ║    Custom Log:     ${local.prefijo}-custom-log
  ║    Log Group VCN:  ${local.prefijo}-log-group-vcn
  ║    VCN Flow Log:   ${local.prefijo}-vcn-flow-log
  ║                                                            ║
  ║  Monitoring:                                               ║
  ║    Alarm CPU:      CPU > 80% → ONS Topic
  ║    Alarm Status:   Instance health → ONS Topic
  ║                                                            ║
  ║  Events:           Instance state change → ONS Topic       ║
  ║  ONS Topic:        ${local.prefijo}-alertas
  ║  Email:            ${var.email_notificacion}
  ╚══════════════════════════════════════════════════════════════╝

  EOT
}
