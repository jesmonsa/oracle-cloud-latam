# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs — Arquitectura 09: Peering Remoto (Cross-Region DRG)             ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Peering ────────────────────────────────────────────────────────────────
output "estado_peering" {
  description = "Estado del Remote Peering Connection (PEERED = OK)"
  value       = module.peering_remoto.estado_conexion
}

output "drg_hub_id" {
  description = "OCID del DRG en la Región 1 (Hub)"
  value       = module.peering_remoto.drg_id_region1
}

output "drg_spoke_id" {
  description = "OCID del DRG en la Región 2 (Spoke)"
  value       = module.peering_remoto.drg_id_region2
}

# ─── Red ────────────────────────────────────────────────────────────────────
output "vcn_hub_id" {
  description = "OCID de la VCN Hub (Región 1)"
  value       = module.red_hub.vcn_id
}

output "vcn_spoke_id" {
  description = "OCID de la VCN Spoke (Región 2)"
  value       = module.red_spoke.vcn_id
}

# ─── Load Balancer ──────────────────────────────────────────────────────────
output "lb_ip_publica" {
  description = "IP pública del Load Balancer (Hub)"
  value       = module.load_balancer.ip_publica
}

output "lb_url" {
  description = "URL del Load Balancer"
  value       = "http://${module.load_balancer.ip_publica}"
}

# ─── Instancias ──────────────────────────────────────────────────────────────
output "ip_privada_webserver_hub" {
  description = "IP privada del Webserver Hub (Región 1)"
  value       = module.webserver_hub.ips_privadas[0]
}

output "ip_privada_backend_spoke" {
  description = "IP privada del Backend Spoke (Región 2)"
  value       = module.spoke_backend.ips_privadas[0]
}

# ─── Bastion ────────────────────────────────────────────────────────────────
output "bastion_id" {
  description = "OCID del Bastion Service (Hub)"
  value       = module.bastion.bastion_id
}

output "comando_ssh_webserver" {
  description = "Comando SSH al Webserver Hub via Bastion"
  value       = "oci bastion session create-port-forwarding --bastion-id ${module.bastion.bastion_id} --target-private-ip ${module.webserver_hub.ips_privadas[0]} --target-port 22 --session-ttl 1800 --key-type PUB --ssh-public-key-file ~/.ssh/id_rsa.pub"
}

output "comando_ssh_spoke_backend" {
  description = "Comando SSH al Backend Spoke (cross-region via Bastion Hub → DRG → Spoke)"
  value       = "oci bastion session create-port-forwarding --bastion-id ${module.bastion.bastion_id} --target-private-ip ${module.spoke_backend.ips_privadas[0]} --target-port 22 --session-ttl 1800 --key-type PUB --ssh-public-key-file ~/.ssh/id_rsa.pub"
}

# ─── Resumen ────────────────────────────────────────────────────────────────
output "resumen" {
  description = "Resumen de la arquitectura desplegada"
  value       = <<-EOT

  ╔════════════════════════════════════════════════════════════╗
  ║  ARQUITECTURA 09 — PEERING REMOTO (Cross-Region DRG)       ║
  ╠════════════════════════════════════════════════════════════╣
  ║                                                            ║
  ║  Región 1 (Hub):   ${var.region}
  ║    VCN:            ${var.vcn_hub_cidr}
  ║    Webserver:      ${module.webserver_hub.ips_privadas[0]}
  ║    LB:             http://${module.load_balancer.ip_publica}
  ║    Bastion:        ${var.proyecto}-${var.ambiente}-bastion
  ║                                                            ║
  ║  Región 2 (Spoke): ${var.region2}
  ║    VCN:            ${var.vcn_spoke_cidr}
  ║    Backend:        ${module.spoke_backend.ips_privadas[0]}
  ║                                                            ║
  ║  Peering:          ${module.peering_remoto.estado_conexion}
  ║  Tipo:             DRG + Remote Peering Connection (RPC)   ║
  ╚════════════════════════════════════════════════════════════╝

  EOT
}
