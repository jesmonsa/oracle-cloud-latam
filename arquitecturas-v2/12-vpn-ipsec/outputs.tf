# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs — Arquitectura 12: VPN Site-to-Site (IPSec)                       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

output "lb_ip_publica" {
  description = "IP pública del Load Balancer"
  value       = module.load_balancer.ip_publica
}

output "lb_url" {
  description = "URL del Load Balancer"
  value       = "http://${module.load_balancer.ip_publica}"
}

output "drg_id" {
  description = "OCID del DRG"
  value       = oci_core_drg.drg.id
}

output "cpe_id" {
  description = "OCID del CPE"
  value       = oci_core_cpe.cpe.id
}

output "ipsec_id" {
  description = "OCID de la conexión IPSec"
  value       = oci_core_ipsec.vpn.id
}

output "tunnel_1_ip" {
  description = "IP del endpoint OCI para Tunnel 1"
  value       = oci_core_ipsec_connection_tunnel_management.tunnel_1.vpn_ip
}

output "tunnel_1_status" {
  description = "Estado del Tunnel 1"
  value       = oci_core_ipsec_connection_tunnel_management.tunnel_1.status
}

output "tunnel_2_ip" {
  description = "IP del endpoint OCI para Tunnel 2"
  value       = oci_core_ipsec_connection_tunnel_management.tunnel_2.vpn_ip
}

output "tunnel_2_status" {
  description = "Estado del Tunnel 2"
  value       = oci_core_ipsec_connection_tunnel_management.tunnel_2.status
}

output "resumen" {
  description = "Resumen de la arquitectura"
  value       = <<-EOT

  ╔══════════════════════════════════════════════════════════════╗
  ║  Arquitectura 12 — VPN Site-to-Site (IPSec)                ║
  ╠══════════════════════════════════════════════════════════════╣
  ║                                                            ║
  ║  Load Balancer:  ${module.load_balancer.ip_publica}
  ║  Webserver:      ${module.webserver.ips_privadas[0]}
  ║                                                            ║
  ║  DRG:            ${oci_core_drg.drg.display_name}
  ║  CPE (on-prem):  ${var.cpe_ip_address}
  ║  Red on-prem:    ${var.on_prem_cidr}
  ║                                                            ║
  ║  Tunnel 1:       ${oci_core_ipsec_connection_tunnel_management.tunnel_1.vpn_ip} (${oci_core_ipsec_connection_tunnel_management.tunnel_1.status})
  ║  Tunnel 2:       ${oci_core_ipsec_connection_tunnel_management.tunnel_2.vpn_ip} (${oci_core_ipsec_connection_tunnel_management.tunnel_2.status})
  ║  IKE Version:    V2                                        ║
  ║  Routing:        Static                                    ║
  ║                                                            ║
  ║  Nota: Túneles DOWN — CPE simulado (sin equipo real)       ║
  ╚══════════════════════════════════════════════════════════════╝

  EOT
}
