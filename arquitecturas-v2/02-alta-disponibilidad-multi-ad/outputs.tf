# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs - Alta Disponibilidad Multi-AD                                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

output "ip_publica_webserver_1" {
  description = "IP pública del webserver en AD1"
  value       = try(module.webserver_ad1.ips_publicas[0], "N/A")
}

output "ip_publica_webserver_2" {
  description = "IP pública del webserver en AD2"
  value       = try(module.webserver_ad2.ips_publicas[0], "N/A")
}

output "url_webserver_1" {
  description = "URL HTTP del webserver 1"
  value       = "http://${try(module.webserver_ad1.ips_publicas[0], "N/A")}"
}

output "url_webserver_2" {
  description = "URL HTTP del webserver 2"
  value       = "http://${try(module.webserver_ad2.ips_publicas[0], "N/A")}"
}

output "vcn_id" {
  description = "OCID de la VCN"
  value       = module.red.vcn_id
}

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

output "advertencia_seguridad" {
  description = "Advertencia si SSH está abierto"
  value       = local.ssh_abierto_al_mundo ? "⚠️  SSH abierto a 0.0.0.0/0. Restringe ssh_cidr_permitido." : "✅ SSH restringido a ${var.ssh_cidr_permitido}"
}
