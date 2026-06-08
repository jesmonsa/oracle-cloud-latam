output "ip_publica_load_balancer" {
  description = "IP pública del Load Balancer (único punto de entrada web)"
  value       = module.load_balancer.ip_publica
}

output "url_acceso_web" {
  description = "URL para acceder a la aplicación web a través del Load Balancer"
  value       = "http://${module.load_balancer.ip_publica}"
}

output "comando_sesion_bastion_web1" {
  description = "Comando OCI CLI para crear sesión SSH contra webserver fd1"
  value       = "oci bastion session create-managed-ssh --bastion-id ${module.bastion.bastion_id} --target-resource-id ${module.webserver_fd1.instancia_ids[0]} --target-os-username opc --session-ttl 3600 --region ${var.region}"
}

output "comando_sesion_bastion_db" {
  description = "Comando OCI CLI para tunel SSH a la BD a través de Bastion"
  value       = "oci bastion session create-port-forwarding --bastion-id ${module.bastion.bastion_id} --target-private-ip ${module.dbsystem.node_ip} --target-port 1521 --session-ttl 3600 --region ${var.region}"
}

output "comando_sesion_bastion_spoke" {
  description = "Comando OCI CLI para tunel SSH al nodo backend en Región 2 a través de Bastion en Región 1"
  value       = "oci bastion session create-port-forwarding --bastion-id ${module.bastion.bastion_id} --target-private-ip ${module.spoke_backend_r2.ips_privadas[0]} --target-port 22 --session-ttl 3600 --region ${var.region}"
}

output "dbsystem_id" {
  description = "OCID del DB System aprovisionado"
  value       = module.dbsystem.dbsystem_id
}

output "estado_peering_r1" {
  description = "Estado de la interconexión RPC en la Región 1"
  value       = module.peering_remoto.estado_rpc_region1
}

output "estado_peering_r2" {
  description = "Estado de la interconexión RPC en la Región 2"
  value       = module.peering_remoto.estado_rpc_region2
}
