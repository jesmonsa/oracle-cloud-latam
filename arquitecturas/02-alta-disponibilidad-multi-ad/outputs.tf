output "ip_publica_servidor_web_1" {
  description = "IP pública del servidor web 1"
  value       = module.webserver_ad1.ips_publicas[0]
}

output "ip_publica_servidor_web_2" {
  description = "IP pública del servidor web 2"
  value       = module.webserver_ad2.ips_publicas[0]
}

output "url_acceso_web_1" {
  description = "URL para acceder a la página web 1"
  value       = "http://${module.webserver_ad1.ips_publicas[0]}"
}

output "url_acceso_web_2" {
  description = "URL para acceder a la página web 2"
  value       = "http://${module.webserver_ad2.ips_publicas[0]}"
}
