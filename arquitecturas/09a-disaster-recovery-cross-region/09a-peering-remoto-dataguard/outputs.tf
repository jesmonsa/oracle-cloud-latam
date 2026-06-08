output "ip_publica_load_balancer" {
  description = "IP pública del Load Balancer (Región Primaria)"
  value       = module.load_balancer.ip_publica
}

output "comando_sesion_bastion_web1" {
  description = "Comando OCI CLI para crear sesión SSH contra webserver fd1"
  value       = "oci bastion session create-managed-ssh --bastion-id ${module.bastion_r1.bastion_id} --target-resource-id ${module.webserver_fd1.instancia_ids[0]} --target-os-username opc --session-ttl 3600 --region ${var.region}"
}

output "comando_sesion_bastion_db_primary" {
  description = "Comando OCI CLI para tunel SSH a la BD Primaria a través de Bastion en Región 1"
  value       = "oci bastion session create-port-forwarding --bastion-id ${module.bastion_r1.bastion_id} --target-private-ip ${module.dbsystem_primary.node_ip} --target-port 1521 --session-ttl 3600 --region ${var.region}"
}

output "dbsystem_primary_id" {
  description = "OCID del DB System Primario aprovisionado"
  value       = module.dbsystem_primary.dbsystem_id
}

output "dbsystem_standby_id" {
  description = "OCID del DB System Standby aprovisionado en Región 2 remotamente"
  value       = module.dataguard_standby.peer_db_system_id
}

output "dataguard_association_id" {
  description = "OCID de la asociación de DataGuard OCI"
  value       = module.dataguard_standby.dataguard_association_id
}

output "estado_peering_r1" {
  description = "Estado de la interconexión RPC en la Región Primaria"
  value       = module.peering_remoto.estado_rpc_region1
}

output "estado_peering_r2" {
  description = "Estado de la interconexión RPC en la Región Secundaria"
  value       = module.peering_remoto.estado_rpc_region2
}
