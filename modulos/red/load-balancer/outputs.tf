output "load_balancer_id" {
  description = "OCID del Load Balancer"
  value       = oci_load_balancer_load_balancer.lb.id
}

output "ip_publica" {
  description = "IP pública del Load Balancer"
  value       = oci_load_balancer_load_balancer.lb.ip_address_details[0].ip_address
}

output "backend_set_name" {
  description = "Nombre del Backend Set"
  value       = oci_load_balancer_backend_set.bset.name
}

output "listener_name" {
  description = "Nombre del Listener"
  value       = oci_load_balancer_listener.listener.name
}
