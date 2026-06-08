# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  16 - Vault + Baselines — KMS, Cloud Guard y Security Zones                ║
# ║  Versión: 2.0 | Terraform >= 1.5 | OCI Provider >= 6.0                    ║
# ║  Vault (KMS) + Cloud Guard + Security Zone                                 ║
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
    key = "v2/16-vault-baselines/terraform.tfstate"
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
