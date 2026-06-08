output "ip_publica_servidor_web" {
  description = "IP pública del servidor web"
  value       = module.webserver.ips_publicas[0]
}

output "url_acceso" {
  description = "URL para acceder a la página web"
  value       = "http://${module.webserver.ips_publicas[0]}"
}

output "comando_ssh" {
  description = "Comando rápido para conexión SSH"
  value       = "ssh -i <ruta_tu_llave_privada> opc@${module.webserver.ips_publicas[0]}"
}
