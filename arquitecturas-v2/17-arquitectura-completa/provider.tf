# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  17 - Arquitectura Completa — Integración total de servicios OCI           ║
# ║  Versión: 2.0 | Terraform >= 1.5 | OCI Provider >= 6.0                    ║
# ║  VCN + LB + Webservers + Vault + Logging + Monitoring + Events + Bastion   ║
# ║                                                                            ║
# ║  Inicializar:                                                              ║
# ║    terraform init                                                          ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0"
    }
  }

  backend "s3" {
    key = "v2/17-arquitectura-completa/terraform.tfstate"
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
