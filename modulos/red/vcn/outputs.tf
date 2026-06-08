output "vcn_id" {
  description = "OCID de la VCN"
  value       = oci_core_vcn.vcn.id
}

output "internet_gateway_id" {
  description = "OCID del Internet Gateway"
  value       = oci_core_internet_gateway.ig.id
}

output "nat_gateway_id" {
  description = "OCID del NAT Gateway"
  value       = var.habilitar_nat_gateway ? oci_core_nat_gateway.nat[0].id : null
}

output "service_gateway_id" {
  description = "OCID del Service Gateway"
  value       = var.habilitar_service_gateway ? oci_core_service_gateway.sgw[0].id : null
}

output "route_table_publica_id" {
  description = "OCID de la Route Table Pública"
  value       = oci_core_route_table.publica.id
}

output "route_table_privada_id" {
  description = "OCID de la Route Table Privada"
  value       = oci_core_route_table.privada.id
}
