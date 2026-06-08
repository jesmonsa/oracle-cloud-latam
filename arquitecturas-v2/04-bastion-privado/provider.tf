# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  04 - Bastion Service + Webservers Privados                                 ║
# ║  Versión: 2.0 | Terraform >= 1.5 | OCI Provider >= 6.0                    ║
# ║  Webservers en subnets privadas, LB público, SSH via Bastion Service       ║
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
    key = "v2/04-bastion-privado/terraform.tfstate"
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
