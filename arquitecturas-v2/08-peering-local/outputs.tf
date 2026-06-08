# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs - Peering Local (Hub-Spoke)                                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

output "lb_ip_publica" {
  description = "IP pública del Load Balancer (Hub)"
  value       = module.load_balancer.ip_publica
}

output "lb_url" {
  description = "URL HTTP del Load Balancer"
  value       = "http://${module.load_balancer.ip_publica}"
}

output "ip_privada_webserver_hub" {
  description = "IP privada del webserver Hub"
  value       = module.webserver_hub.ips_privadas[0]
}

output "ip_privada_backend_spoke" {
  description = "IP privada del backend Spoke"
  value       = module.spoke_backend.ips_privadas[0]
}

# ─── Peering ────────────────────────────────────────────────────────────────
output "estado_peering" {
  description = "Estado del Local Peering Gateway"
  value       = module.peering_local.estado_peering
}

output "lpg_hub_id" {
  description = "OCID del LPG en Hub VCN"
  value       = module.peering_local.lpg_id_vcn1
}

output "lpg_spoke_id" {
  description = "OCID del LPG en Spoke VCN"
  value       = module.peering_local.lpg_id_vcn2
}

# ─── Base de Datos ──────────────────────────────────────────────────────────
output "db_system_id" {
  description = "OCID del DB System (Hub)"
  value       = module.database.dbsystem_id
}

output "db_node_ip" {
  description = "IP privada del nodo de BD"
  value       = module.database.node_ip
}

output "db_name" {
  description = "Nombre de la base de datos"
  value       = module.database.db_name
}

output "db_connection_string" {
  description = "Cadena de conexión a la BD"
  value       = "${module.database.node_ip}:1521/${module.database.db_name}PDB"
}

# ─── Bastion ────────────────────────────────────────────────────────────────
output "bastion_id" {
  description = "OCID del Bastion Service"
  value       = module.bastion.bastion_id
}

output "comando_ssh_webserver" {
  description = "SSH al webserver Hub via Bastion"
  value       = "oci bastion session create-port-forwarding --bastion-id ${module.bastion.bastion_id} --target-private-ip ${module.webserver_hub.ips_privadas[0]} --target-port 22 --session-ttl 10800 --ssh-public-key-file <ruta_key.pub>"
}

output "comando_ssh_db" {
  description = "SSH al DB System via Bastion"
  value       = "oci bastion session create-port-forwarding --bastion-id ${module.bastion.bastion_id} --target-private-ip ${module.database.node_ip} --target-port 22 --session-ttl 10800 --ssh-public-key-file <ruta_key.pub>"
}

output "comando_ssh_spoke_backend" {
  description = "SSH al backend Spoke via Bastion (cross-VCN via LPG)"
  value       = "oci bastion session create-port-forwarding --bastion-id ${module.bastion.bastion_id} --target-private-ip ${module.spoke_backend.ips_privadas[0]} --target-port 22 --session-ttl 10800 --ssh-public-key-file <ruta_key.pub>"
}

# ─── VCNs ───────────────────────────────────────────────────────────────────
output "vcn_hub_id" {
  description = "OCID de la VCN Hub"
  value       = module.red_hub.vcn_id
}

output "vcn_spoke_id" {
  description = "OCID de la VCN Spoke"
  value       = module.red_spoke.vcn_id
}

output "resumen" {
  description = "Resumen de la arquitectura"
  value       = <<-EOT
    ╔══════════════════════════════════════════════════════════════╗
    ║  Arquitectura 08 - Local Peering Gateway (Hub-Spoke)        ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  Hub VCN:   ${var.vcn_hub_cidr}
    ║  Spoke VCN: ${var.vcn_spoke_cidr}
    ║  Peering:   ${module.peering_local.estado_peering}
    ║  LB URL:    http://${module.load_balancer.ip_publica}
    ║  WS Hub:    ${module.webserver_hub.ips_privadas[0]} (Hub)
    ║  Backend:   ${module.spoke_backend.ips_privadas[0]} (Spoke)
    ║  DB (Hub):  ${module.database.node_ip}:1521/${module.database.db_name}PDB
    ║  Bastion:   ${module.bastion.bastion_name}
    ╚══════════════════════════════════════════════════════════════╝
  EOT
}
