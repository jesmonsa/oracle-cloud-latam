# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs - Información útil post-despliegue                                ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Acceso al Webserver ─────────────────────────────────────────────────────
output "ip_publica_servidor_web" {
  description = "IP pública del servidor web"
  value       = module.webserver.ips_publicas[0]
}

output "url_acceso" {
  description = "URL para acceder a la página web"
  value       = "http://${module.webserver.ips_publicas[0]}"
}

output "comando_ssh" {
  description = "Comando para conexión SSH al servidor"
  value       = "ssh -i <ruta_llave_privada> opc@${module.webserver.ips_publicas[0]}"
}

# ─── Red ──────────────────────────────────────────────────────────────────────
output "vcn_id" {
  description = "OCID de la VCN creada"
  value       = module.red.vcn_id
}

output "subnet_publica_id" {
  description = "OCID de la subnet pública"
  value       = oci_core_subnet.publica.id
}

# ─── Instancia ────────────────────────────────────────────────────────────────
output "instancia_id" {
  description = "OCID de la instancia del webserver"
  value       = module.webserver.instancia_ids[0]
}

output "ip_privada" {
  description = "IP privada del webserver"
  value       = module.webserver.ips_privadas[0]
}

# ─── Información del Tenancy ─────────────────────────────────────────────────
output "tenancy_namespace" {
  description = "Namespace del tenancy (útil para Object Storage)"
  value       = data.oci_identity_tenancy.tenancy.name
}

# ─── Advertencia de Seguridad ────────────────────────────────────────────────
output "advertencia_seguridad" {
  description = "Advertencia si SSH está abierto al mundo"
  value       = local.ssh_abierto_al_mundo ? "⚠️  ADVERTENCIA: SSH abierto a 0.0.0.0/0. Restringe ssh_cidr_permitido para producción." : "✅ SSH restringido a ${var.ssh_cidr_permitido}"
}
