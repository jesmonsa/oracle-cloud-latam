output "nsg_web_id" {
  description = "OCID del NSG Web (HTTP/HTTPS)"
  value       = var.habilitar_nsg_web ? oci_core_network_security_group.nsg_web[0].id : null
}

output "nsg_ssh_id" {
  description = "OCID del NSG SSH"
  value       = var.habilitar_nsg_ssh ? oci_core_network_security_group.nsg_ssh[0].id : null
}

output "nsg_db_id" {
  description = "OCID del NSG Base de Datos (puerto 1521)"
  value       = var.habilitar_nsg_db ? oci_core_network_security_group.nsg_db[0].id : null
}

output "nsg_nfs_id" {
  description = "OCID del NSG NFS (File Storage Service)"
  value       = var.habilitar_nsg_nfs ? oci_core_network_security_group.nsg_nfs[0].id : null
}

output "nsg_egress_id" {
  description = "OCID del NSG Egress General (salida a Internet/OCI Services)"
  value       = oci_core_network_security_group.nsg_egress.id
}

output "todos_nsg_ids" {
  description = "Lista de todos los NSGs creados (para asignar a instancias)"
  value = compact([
    var.habilitar_nsg_web ? oci_core_network_security_group.nsg_web[0].id : "",
    var.habilitar_nsg_ssh ? oci_core_network_security_group.nsg_ssh[0].id : "",
    var.habilitar_nsg_db ? oci_core_network_security_group.nsg_db[0].id : "",
    var.habilitar_nsg_nfs ? oci_core_network_security_group.nsg_nfs[0].id : "",
    oci_core_network_security_group.nsg_egress.id
  ])
}
