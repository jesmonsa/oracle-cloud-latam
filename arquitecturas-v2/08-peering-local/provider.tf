# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  08 - Peering Local (Hub-Spoke VCN Interconnection)                         ║
# ║  Versión: 2.0 | Terraform >= 1.5 | OCI Provider >= 6.0                    ║
# ║  Hub VCN: LB + Webserver + DB System + Bastion                             ║
# ║  Spoke VCN: Backend server (accesible desde Hub via LPG)                   ║
# ║                                                                            ║
# ║  Inicializar:                                                              ║
# ║    terraform init -backend-config=../00-bootstrap-remotestate/backend.hcl  ║
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
    key = "v2/08-peering-local/terraform.tfstate"
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
