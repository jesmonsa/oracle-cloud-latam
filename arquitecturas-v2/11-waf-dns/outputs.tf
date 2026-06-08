# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs — Arquitectura 11: WAF + DNS Zone                                 ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

output "lb_ip_publica" {
  description = "IP pública del Load Balancer"
  value       = module.load_balancer.ip_publica
}

output "lb_url" {
  description = "URL del Load Balancer"
  value       = "http://${module.load_balancer.ip_publica}"
}

output "waf_id" {
  description = "OCID del Web Application Firewall"
  value       = oci_waf_web_app_firewall.waf.id
}

output "waf_policy_id" {
  description = "OCID de la WAF Policy"
  value       = oci_waf_web_app_firewall_policy.waf_policy.id
}

output "dns_zone_id" {
  description = "OCID de la DNS Zone"
  value       = oci_dns_zone.zona.id
}

output "dns_zone_nameservers" {
  description = "Name servers de la zona DNS"
  value       = oci_dns_zone.zona.nameservers
}

output "dns_app_record" {
  description = "Registro DNS A para la aplicación"
  value       = "app.${var.dns_zone_name} → ${module.load_balancer.ip_publica}"
}

output "resumen" {
  description = "Resumen de la arquitectura"
  value       = <<-EOT

  ╔══════════════════════════════════════════════════════════════╗
  ║  Arquitectura 11 — WAF + DNS Zone                          ║
  ╠══════════════════════════════════════════════════════════════╣
  ║                                                            ║
  ║  Load Balancer:  ${module.load_balancer.ip_publica}
  ║  URL:            http://${module.load_balancer.ip_publica}
  ║                                                            ║
  ║  WAF:            Habilitado (modo ${var.waf_modo})
  ║    ├─ XSS Protection (CRS 941110)                          ║
  ║    └─ Rate Limit: 100 req/min                              ║
  ║                                                            ║
  ║  DNS Zone:       ${var.dns_zone_name}
  ║  App Record:     app.${var.dns_zone_name}
  ║                                                            ║
  ║  Webserver:      ${module.webserver.ips_privadas[0]} (privado)
  ║  Bastion:        ${var.proyecto}-${var.ambiente}-bastion
  ╚══════════════════════════════════════════════════════════════╝

  EOT
}
