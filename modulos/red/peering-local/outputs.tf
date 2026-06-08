output "lpg_id_vcn1" {
  description = "OCID del Local Peering Gateway de VCN1 (Hub)"
  value       = oci_core_local_peering_gateway.lpg_vcn1.id
}

output "lpg_id_vcn2" {
  description = "OCID del Local Peering Gateway de VCN2 (Spoke)"
  value       = oci_core_local_peering_gateway.lpg_vcn2.id
}

output "estado_peering" {
  description = "Estado del peering entre VCN1 y VCN2"
  value       = oci_core_local_peering_gateway.lpg_vcn1.peering_status
}
