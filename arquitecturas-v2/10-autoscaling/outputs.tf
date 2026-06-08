# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs — Arquitectura 10: Autoscaling (Instance Pool)                    ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ─── Load Balancer ────────────────────────────────────────────────────────────
output "lb_ip_publica" {
  description = "IP pública del Load Balancer"
  value       = oci_load_balancer_load_balancer.lb.ip_addresses[0]
}

output "lb_url" {
  description = "URL del Load Balancer"
  value       = "http://${oci_load_balancer_load_balancer.lb.ip_addresses[0]}"
}

# ─── Instance Pool ────────────────────────────────────────────────────────────
output "instance_pool_id" {
  description = "OCID del Instance Pool"
  value       = oci_core_instance_pool.pool.id
}

output "instance_pool_size" {
  description = "Tamaño actual del Instance Pool"
  value       = oci_core_instance_pool.pool.size
}

output "instance_config_id" {
  description = "OCID del Instance Configuration"
  value       = oci_core_instance_configuration.webserver.id
}

# ─── Autoscaling ──────────────────────────────────────────────────────────────
output "autoscaling_id" {
  description = "OCID de la Autoscaling Configuration"
  value       = oci_autoscaling_auto_scaling_configuration.autoscaling.id
}

output "autoscaling_habilitado" {
  description = "Estado del autoscaling"
  value       = oci_autoscaling_auto_scaling_configuration.autoscaling.is_enabled
}

# ─── Red ──────────────────────────────────────────────────────────────────────
output "vcn_id" {
  description = "OCID de la VCN"
  value       = module.red.vcn_id
}

# ─── Bastion ─────────────────────────────────────────────────────────────────
output "bastion_id" {
  description = "OCID del Bastion Service"
  value       = module.bastion.bastion_id
}

# ─── Resumen ──────────────────────────────────────────────────────────────────
output "resumen" {
  description = "Resumen de la arquitectura"
  value       = <<-EOT

  ╔══════════════════════════════════════════════════════════════╗
  ║  Arquitectura 10 — Autoscaling (Instance Pool)             ║
  ╠══════════════════════════════════════════════════════════════╣
  ║                                                            ║
  ║  Load Balancer:  ${oci_load_balancer_load_balancer.lb.ip_addresses[0]}
  ║  URL:            http://${oci_load_balancer_load_balancer.lb.ip_addresses[0]}
  ║                                                            ║
  ║  Instance Pool:  ${var.pool_tamano_inicial} instancia(s) inicial(es)
  ║  Rango:          ${var.pool_tamano_minimo} min — ${var.pool_tamano_maximo} max
  ║  Scale-out:      CPU > ${var.umbral_cpu_scale_out}% → +1 instancia
  ║  Scale-in:       CPU < ${var.umbral_cpu_scale_in}% → -1 instancia
  ║  Cooldown:       ${var.cooldown_segundos}s entre acciones
  ║                                                            ║
  ║  VCN:            ${var.vcn_cidr}
  ║  Subnet Pool:    ${var.subnet_privada_cidr} (privada)
  ║  Subnet LB:      ${var.subnet_publica_cidr} (pública)
  ║                                                            ║
  ║  Bastion:        ${var.proyecto}-${var.ambiente}-bastion
  ╚══════════════════════════════════════════════════════════════╝

  EOT
}
