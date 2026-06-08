# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs - DataGuard HA (DB Primario + Standby + NFS + LB + Bastion)        ║
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

# ─── Base de Datos Primaria (AD1) ───────────────────────────────────────────
output "db_system_id" {
  description = "OCID del DB System primario"
  value       = module.database.dbsystem_id
}

output "db_node_ip" {
  description = "IP privada del nodo de BD primario"
  value       = module.database.node_ip
}

output "db_name" {
  description = "Nombre de la base de datos"
  value       = module.database.db_name
}

output "db_connection_string" {
  description = "Cadena de conexión a la BD primaria"
  value       = "${module.database.node_ip}:1521/${module.database.db_name}PDB"
}

output "db_home_id" {
  description = "OCID del DB Home primario"
  value       = module.database.db_home_id
}

# ─── DataGuard (Standby - AD2) ─────────────────────────────────────────────
output "dataguard_association_id" {
  description = "OCID de la asociación DataGuard"
  value       = module.dataguard.dataguard_association_id
}

output "standby_db_system_id" {
  description = "OCID del DB System Standby creado por DataGuard"
  value       = module.dataguard.peer_db_system_id
}

output "dataguard_role" {
  description = "Rol actual del DataGuard (PRIMARY en la asociación)"
  value       = module.dataguard.role
}

output "dataguard_protection_mode" {
  description = "Modo de protección DataGuard configurado"
  value       = var.dataguard_protection_mode
}

output "dataguard_transport_type" {
  description = "Tipo de transporte de redo logs"
  value       = var.dataguard_transport_type
}

# ─── Bastion ────────────────────────────────────────────────────────────────
output "bastion_id" {
  description = "OCID del Bastion Service"
  value       = module.bastion.bastion_id
}

output "comando_ssh_db_primario" {
  description = "Comando para crear sesión SSH al DB primario via Bastion"
  value       = "oci bastion session create-port-forwarding --bastion-id ${module.bastion.bastion_id} --target-private-ip ${module.database.node_ip} --target-port 22 --session-ttl 10800 --ssh-public-key-file <ruta_key.pub>"
}

# ─── General ────────────────────────────────────────────────────────────────
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
    ║  Arquitectura 07 - DataGuard HA (Alta Disponibilidad DB)    ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  LB URL:      http://${module.load_balancer.ip_publica}
    ║  NFS Shared:  http://${module.load_balancer.ip_publica}/shared/shared.html
    ║  WS1 (priv):  ${try(module.webserver_ad1.ips_privadas[0], "N/A")} (${local.ad_instancia_1})
    ║  WS2 (priv):  ${try(module.webserver_ad2.ips_privadas[0], "N/A")} (${local.ad_instancia_2})
    ║  DB Primario: ${module.database.node_ip} (${local.ad_instancia_1})
    ║  DB Name:     ${module.database.db_name} / ${module.database.db_name}PDB
    ║  DataGuard:   ${var.dataguard_protection_mode} / ${var.dataguard_transport_type}
    ║  Standby:     ${module.dataguard.peer_db_system_id} (${local.ad_instancia_2})
    ║  NFS Mount:   ${module.filesystem.ip_montaje}:${var.nfs_ruta_exportacion}
    ║  Bastion:     ${module.bastion.bastion_name}
    ║  Modo:        ${local.es_multi_ad ? "Multi-AD" : "Fault Domains"}
    ╚══════════════════════════════════════════════════════════════╝
  EOT
}
