# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  03 - Load Balancer + Alta Disponibilidad Multi-AD                          ║
# ║  Versión: 2.0 | Terraform >= 1.5 | OCI Provider >= 6.0                    ║
# ║  Load Balancer distribuyendo tráfico entre webservers en ADs diferentes    ║
# ║                                                                            ║
# ║  Inicializar:                                                              ║
# ║    terraform init -backend-config=../00-bootstrap-remotestate/backend.hcl  ║
# ║                                                                            ║
# ║  Variables de entorno requeridas (S3 backend con OCI Object Storage):      ║
# ║    AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY                                ║
# ║    AWS_REQUEST_CHECKSUM_CALCULATION=WHEN_REQUIRED                          ║
# ║    AWS_RESPONSE_CHECKSUM_VALIDATION=WHEN_REQUIRED                          ║
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
    key = "v2/03-load-balancer-ha/terraform.tfstate"
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
