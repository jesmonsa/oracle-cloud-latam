output "bastion_id" {
  description = "OCID del servicio Bastion"
  value       = oci_bastion_bastion.bastion.id
}

output "bastion_endpoint" {
  description = "Endpoint del servicio Bastion (referencial — el endpoint real usa la región del tenancy)"
  value       = "host.bastion.${oci_bastion_bastion.bastion.id}.oci.oraclecloud.com"
}

output "bastion_name" {
  description = "Nombre del servicio Bastion"
  value       = oci_bastion_bastion.bastion.name
}
