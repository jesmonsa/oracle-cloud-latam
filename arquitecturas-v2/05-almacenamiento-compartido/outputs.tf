# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs - Almacenamiento Compartido (FSS + NFS)                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

output "lb_ip_publica" {
  description = "IP pública del Load Balancer"
  value       = module.load_balancer.ip_publica
}

output "lb_url" {
  description = "URL HTTP del Load Balancer"
  value       = "http://${module.load_balancer.ip_publica}"
}

output "url_contenido_compartido" {
  description = "URL del contenido compartido NFS via LB"
  value       = "http://${module.load_balancer.ip_publica}/shared/shared.html"
}

output "ip_privada_webserver_1" {
  description = "IP privada del webserver 1"
  value       = try(module.webserver_ad1.ips_privadas[0], "N/A")
}

output "ip_privada_webserver_2" {
  description = "IP privada del webserver 2"
  value       = try(module.webserver_ad2.ips_privadas[0], "N/A")
}

output "nfs_mount_target_ip" {
  description = "IP del Mount Target NFS"
  value       = module.filesystem.ip_montaje
}

output "nfs_ruta_exportacion" {
  description = "Ruta de exportación NFS"
  value       = module.filesystem.ruta_montaje
}

output "nfs_comando_montaje" {
  description = "Comando para montar NFS manualmente"
  value       = "sudo mount -t nfs ${module.filesystem.ip_montaje}:${var.nfs_ruta_exportacion} /var/www/html/shared"
}

output "bastion_id" {
  description = "OCID del Bastion Service"
  value       = module.bastion.bastion_id
}

output "vcn_id" {
  description = "OCID de la VCN"
  value       = module.red.vcn_id
}

output "modo_ha" {
  description = "Modo de alta disponibilidad"
  value       = local.es_multi_ad ? "Multi-AD (AD1 + AD2)" : "Fault Domains (FD1 + FD2)"
}

output "resumen" {
  description = "Resumen de la arquitectura"
  value       = <<-EOT
    ╔══════════════════════════════════════════════════════════════╗
    ║  Arquitectura 05 - Almacenamiento Compartido NFS            ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  LB URL:     http://${module.load_balancer.ip_publica}
    ║  NFS Shared: http://${module.load_balancer.ip_publica}/shared/shared.html
    ║  WS1 (priv): ${try(module.webserver_ad1.ips_privadas[0], "N/A")} (${local.ad_instancia_1})
    ║  WS2 (priv): ${try(module.webserver_ad2.ips_privadas[0], "N/A")} (${local.ad_instancia_2})
    ║  NFS Mount:  ${module.filesystem.ip_montaje}:${var.nfs_ruta_exportacion}
    ║  Bastion:    ${module.bastion.bastion_name}
    ║  Modo:       ${local.es_multi_ad ? "Multi-AD" : "Fault Domains"}
    ╚══════════════════════════════════════════════════════════════╝
  EOT
}
