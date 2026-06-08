# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs - Load Balancer + Alta Disponibilidad Multi-AD                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Load Balancer (punto de entrada principal) ─────────────────────────
output "lb_ip_publica" {
  description = "IP pública del Load Balancer (punto de entrada)"
  value       = module.load_balancer.ip_publica
}

output "lb_url" {
  description = "URL HTTP del Load Balancer"
  value       = "http://${module.load_balancer.ip_publica}"
}

output "lb_id" {
  description = "OCID del Load Balancer"
  value       = module.load_balancer.load_balancer_id
}

# ─── Webservers (backends del LB) ──────────────────────────────────────
output "ip_publica_webserver_1" {
  description = "IP pública del webserver en AD1 (acceso SSH directo)"
  value       = try(module.webserver_ad1.ips_publicas[0], "N/A")
}

output "ip_publica_webserver_2" {
  description = "IP pública del webserver en AD2 (acceso SSH directo)"
  value       = try(module.webserver_ad2.ips_publicas[0], "N/A")
}

output "ip_privada_webserver_1" {
  description = "IP privada del webserver 1 (backend del LB)"
  value       = try(module.webserver_ad1.ips_privadas[0], "N/A")
}

output "ip_privada_webserver_2" {
  description = "IP privada del webserver 2 (backend del LB)"
  value       = try(module.webserver_ad2.ips_privadas[0], "N/A")
}

# ─── Red ──────────────────────────────────────────────────────────────────────
output "vcn_id" {
  description = "OCID de la VCN"
  value       = module.red.vcn_id
}

# ─── Alta Disponibilidad ──────────────────────────────────────────────────────
output "modo_ha" {
  description = "Modo de alta disponibilidad utilizado"
  value       = local.es_multi_ad ? "Multi-AD (AD1 + AD2)" : "Fault Domains (FD1 + FD2 en mismo AD)"
}

output "availability_domains" {
  description = "ADs utilizados para las instancias"
  value = {
    webserver_1 = local.ad_instancia_1
    webserver_2 = local.ad_instancia_2
  }
}

output "backends_lb" {
  description = "IPs privadas registradas como backends del LB"
  value       = local.backend_private_ips
}

# ─── Seguridad ────────────────────────────────────────────────────────────────
output "advertencia_seguridad" {
  description = "Advertencia si SSH está abierto"
  value       = local.ssh_abierto_al_mundo ? "⚠️  SSH abierto a 0.0.0.0/0. Restringe ssh_cidr_permitido." : "✅ SSH restringido a ${var.ssh_cidr_permitido}"
}

# ─── Resumen ──────────────────────────────────────────────────────────────────
output "resumen" {
  description = "Resumen de la arquitectura desplegada"
  value       = <<-EOT
    ╔════════════════════════════════════════════════════════════╗
    ║  Arquitectura 03 - Load Balancer HA                         ║
    ╠════════════════════════════════════════════════════════════╣
    ║  LB URL:  http://${module.load_balancer.ip_publica}
    ║  WS1:     ${try(module.webserver_ad1.ips_publicas[0], "N/A")} (${local.ad_instancia_1})
    ║  WS2:     ${try(module.webserver_ad2.ips_publicas[0], "N/A")} (${local.ad_instancia_2})
    ║  Modo:    ${local.es_multi_ad ? "Multi-AD" : "Fault Domains"}
    ╚════════════════════════════════════════════════════════════╝
  EOT
}
