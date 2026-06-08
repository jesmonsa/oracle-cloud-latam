output "ip_publica_load_balancer" {
  description = "IP pública del Load Balancer"
  value       = module.load_balancer.ip_publica
}

output "url_acceso_web" {
  description = "URL para acceder a la aplicación web"
  value       = "http://${module.load_balancer.ip_publica}"
}

output "comando_sesion_bastion_web1" {
  description = "Comando OCI CLI para crear sesión SSH contra webserver 1"
  value       = "oci bastion session create-managed-ssh --bastion-id ${module.bastion.bastion_id} --target-resource-id ${module.webserver_fd1.instancia_ids[0]} --target-os-username opc --session-ttl 3600"
}

output "comando_sesion_bastion_web2" {
  description = "Comando OCI CLI para crear sesión SSH contra webserver 2"
  value       = "oci bastion session create-managed-ssh --bastion-id ${module.bastion.bastion_id} --target-resource-id ${module.webserver_fd2.instancia_ids[0]} --target-os-username opc --session-ttl 3600"
}
