output "ip_publica_servidor_web_1" {
  description = "IP pública del servidor web fd1"
  value       = module.webserver_fd1.ips_publicas[0]
}

output "ip_publica_servidor_web_2" {
  description = "IP pública del servidor web fd2"
  value       = module.webserver_fd2.ips_publicas[0]
}

output "url_acceso_web_1" {
  description = "URL web fd1"
  value       = "http://${module.webserver_fd1.ips_publicas[0]}"
}

output "url_acceso_web_2" {
  description = "URL web fd2"
  value       = "http://${module.webserver_fd2.ips_publicas[0]}"
}
