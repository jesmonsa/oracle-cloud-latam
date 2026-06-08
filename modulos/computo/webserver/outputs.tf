output "instancia_ids" {
  description = "Lista de OCIDs de las instancias creadas"
  value       = oci_core_instance.web[*].id
}

output "ips_privadas" {
  description = "Lista de IPs privadas de las instancias"
  value       = oci_core_instance.web[*].private_ip
}

output "ips_publicas" {
  description = "Lista de IPs públicas de las instancias (vacío si no se asignaron)"
  value       = oci_core_instance.web[*].public_ip
}
