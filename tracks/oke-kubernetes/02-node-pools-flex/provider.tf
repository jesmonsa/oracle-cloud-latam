# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Track OKE — Lección 02: Node Pools Flex (E4 x86 + A1 ARM)               ║
# ║  Versión: 2.0 | Terraform >= 1.5 | OCI Provider >= 6.0                    ║
# ║  OKE Cluster + 2 Node Pools heterogéneos + VCN 3-subnet                   ║
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
    key = "tracks/oke/02-node-pools-flex/terraform.tfstate"
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
