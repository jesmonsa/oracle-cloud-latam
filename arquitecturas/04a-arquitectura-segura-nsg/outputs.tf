output "ip_publica_load_balancer" {
  description = "IP pública del Load Balancer (único punto de entrada web)"
  value       = module.load_balancer.ip_publica
}

output "url_acceso_web" {
  description = "URL para acceder a la aplicación a través del Load Balancer"
  value       = "http://${module.load_balancer.ip_publica}"
}

output "comando_sesion_bastion_web1" {
  description = "Comando OCI CLI para crear sesión SSH contra el webserver fd1"
  value       = "oci bastion session create-managed-ssh --bastion-id ${module.bastion.bastion_id} --target-resource-id ${module.webserver_fd1.instancia_ids[0]} --target-os-username opc --session-ttl 3600"
}

output "comando_sesion_bastion_web2" {
  description = "Comando OCI CLI para crear sesión SSH contra el webserver fd2"
  value       = "oci bastion session create-managed-ssh --bastion-id ${module.bastion.bastion_id} --target-resource-id ${module.webserver_fd2.instancia_ids[0]} --target-os-username opc --session-ttl 3600"
}
