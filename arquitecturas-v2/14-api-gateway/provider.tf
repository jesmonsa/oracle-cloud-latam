# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  14 - API Gateway — Exposición de APIs con backend HTTP                    ║
# ║  Versión: 2.0 | Terraform >= 1.5 | OCI Provider >= 6.0                    ║
# ║  API Gateway + Deployment + Rutas + Functions Application                  ║
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
    key = "v2/14-api-gateway/terraform.tfstate"
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
