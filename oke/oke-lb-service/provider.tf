# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  OKE LOAD BALANCER SERVICE - PROVIDER CONFIGURATION                          ║
# ║  Arquitectura de Referencia OKE para Oracle Cloud Infrastructure             ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    oci = { source = "oracle/oci"; version = ">= 6.0.0" }
  }
  backend "s3" { key = "oke/oke-lb-service/terraform.tfstate" }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
