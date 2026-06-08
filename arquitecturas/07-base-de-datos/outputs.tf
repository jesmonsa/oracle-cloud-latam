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
  value       = "oci bastion session create-managed-ssh --bastion-id ${module.bastion.bastion_id} --target-resource-id ${module.webserver_fd1.instancia_ids[0]} --target-os-username opc --session-ttl 3600"
}

output "comando_sesion_bastion_web2" {
  description = "Comando OCI CLI para crear sesión SSH contra webserver fd2"
  value       = "oci bastion session create-managed-ssh --bastion-id ${module.bastion.bastion_id} --target-resource-id ${module.webserver_fd2.instancia_ids[0]} --target-os-username opc --session-ttl 3600"
}

output "comando_sesion_bastion_db" {
  description = "Comando OCI CLI para crear un túnel de reenvío de puertos a la Base de Datos a través de Bastion"
  value       = "oci bastion session create-port-forwarding --bastion-id ${module.bastion.bastion_id} --target-private-ip ${module.dbsystem.node_ip} --target-port 1521 --session-ttl 3600"
}

output "dbsystem_id" {
  description = "OCID del DB System aprovisionado"
  value       = module.dbsystem.dbsystem_id
}

output "dbsystem_hostname" {
  description = "Hostname configurado en el DB System"
  value       = module.dbsystem.hostname
}
