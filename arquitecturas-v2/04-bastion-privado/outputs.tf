# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs - Bastion Service + Webservers Privados                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Load Balancer (punto de entrada principal) ─────────────────────────
output "lb_ip_publica" {
  description = "IP pública del Load Balancer (punto de entrada HTTP)"
  value       = module.load_balancer.ip_publica
}

output "lb_url" {
  description = "URL HTTP del Load Balancer"
  value       = "http://${module.load_balancer.ip_publica}"
}

# ─── Webservers (solo IPs privadas — sin IP pública) ─────────────────────
output "ip_privada_webserver_1" {
  description = "IP privada del webserver 1 (solo accesible via Bastion o LB)"
  value       = try(module.webserver_ad1.ips_privadas[0], "N/A")
}

output "ip_privada_webserver_2" {
  description = "IP privada del webserver 2 (solo accesible via Bastion o LB)"
  value       = try(module.webserver_ad2.ips_privadas[0], "N/A")
}

output "instancia_id_webserver_1" {
  description = "OCID de la instancia webserver 1 (para sesiones Bastion)"
  value       = try(module.webserver_ad1.instancia_ids[0], "N/A")
}

output "instancia_id_webserver_2" {
  description = "OCID de la instancia webserver 2 (para sesiones Bastion)"
  value       = try(module.webserver_ad2.instancia_ids[0], "N/A")
}

# ─── Bastion Service ────────────────────────────────────────────────────────
output "bastion_id" {
  description = "OCID del Bastion Service"
  value       = module.bastion.bastion_id
}

output "bastion_nombre" {
  description = "Nombre del Bastion Service"
  value       = module.bastion.bastion_name
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

# ─── Comandos SSH via Bastion ─────────────────────────────────────────────────
output "comando_ssh_ws1" {
  description = "Comando para crear sesión Bastion SSH al webserver 1"
  value       = <<-EOT
    # 1. Crear sesión SSH via Bastion (OCI CLI):
    oci bastion session create-managed-ssh \
      --bastion-id ${module.bastion.bastion_id} \
      --target-resource-id ${try(module.webserver_ad1.instancia_ids[0], "INSTANCE_OCID")} \
      --target-os-username opc \
      --key-type PUB \
      --ssh-public-key-file ~/.ssh/oci_webserver.pub \
      --session-ttl 3600

    # 2. Conectar con el comando SSH que devuelve la sesión
  EOT
}

output "comando_ssh_ws2" {
  description = "Comando para crear sesión Bastion SSH al webserver 2"
  value       = <<-EOT
    # 1. Crear sesión SSH via Bastion (OCI CLI):
    oci bastion session create-managed-ssh \
      --bastion-id ${module.bastion.bastion_id} \
      --target-resource-id ${try(module.webserver_ad2.instancia_ids[0], "INSTANCE_OCID")} \
      --target-os-username opc \
      --key-type PUB \
      --ssh-public-key-file ~/.ssh/oci_webserver.pub \
      --session-ttl 3600

    # 2. Conectar con el comando SSH que devuelve la sesión
  EOT
}

# ─── Resumen ──────────────────────────────────────────────────────────────────
output "resumen" {
  description = "Resumen de la arquitectura desplegada"
  value       = <<-EOT
    ╔════════════════════════════════════════════════════════════╗
    ║  Arquitectura 04 - Bastion + Webservers Privados            ║
    ╠════════════════════════════════════════════════════════════╣
    ║  LB URL:     http://${module.load_balancer.ip_publica}
    ║  WS1 (priv): ${try(module.webserver_ad1.ips_privadas[0], "N/A")} (${local.ad_instancia_1})
    ║  WS2 (priv): ${try(module.webserver_ad2.ips_privadas[0], "N/A")} (${local.ad_instancia_2})
    ║  Bastion:    ${module.bastion.bastion_name}
    ║  Modo:       ${local.es_multi_ad ? "Multi-AD" : "Fault Domains"}
    ║  SSH:        Via Bastion Service (sin puerto 22 expuesto)
    ║  NAT GW:     Habilitado (webservers acceden a internet)
    ╚════════════════════════════════════════════════════════════╝
  EOT
}
