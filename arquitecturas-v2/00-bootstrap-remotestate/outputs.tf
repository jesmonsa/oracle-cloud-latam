# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Outputs - Información necesaria para configurar el backend                 ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

output "bucket_name" {
  description = "Nombre del bucket creado para tfstate"
  value       = oci_objectstorage_bucket.tfstate.name
}

output "namespace" {
  description = "Namespace del tenancy OCI"
  value       = data.oci_objectstorage_namespace.ns.namespace
}

output "s3_endpoint" {
  description = "Endpoint S3-compatible para el backend de Terraform"
  value       = "https://${data.oci_objectstorage_namespace.ns.namespace}.compat.objectstorage.${var.region}.oraclecloud.com"
}

output "s3_access_key" {
  description = "Access Key ID para S3 (Customer Secret Key ID)"
  value       = oci_identity_customer_secret_key.terraform_s3.id
  sensitive   = true
}

output "s3_secret_key" {
  description = "Secret Access Key para S3 (solo visible en el primer apply)"
  value       = oci_identity_customer_secret_key.terraform_s3.key
  sensitive   = true
}

output "backend_config_path" {
  description = "Ruta al archivo backend.hcl generado"
  value       = local_file.backend_config.filename
}

output "instrucciones" {
  description = "Pasos para usar el remote state en las demás arquitecturas"
  value       = <<-EOT

    ╔══════════════════════════════════════════════════════════════════════╗
    ║  ✅ Remote State configurado exitosamente                          ║
    ╠══════════════════════════════════════════════════════════════════════╣
    ║                                                                    ║
    ║  Para usar en cada arquitectura:                                   ║
    ║                                                                    ║
    ║  1. Configura las variables de entorno:                            ║
    ║     set AWS_ACCESS_KEY_ID=<s3_access_key>                         ║
    ║     set AWS_SECRET_ACCESS_KEY=<s3_secret_key>                     ║
    ║                                                                    ║
    ║  2. Inicializa con el backend config:                              ║
    ║     terraform init \                                               ║
    ║       -backend-config=../00-bootstrap-remotestate/backend.hcl      ║
    ║                                                                    ║
    ║  Cada arquitectura define su propia "key" en el backend block.     ║
    ║  Ej: key = "v2/01-fundamentos/terraform.tfstate"                  ║
    ║                                                                    ║
    ╚══════════════════════════════════════════════════════════════════════╝
  EOT
}
