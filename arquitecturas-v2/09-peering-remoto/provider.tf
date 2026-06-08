# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  09 - Peering Remoto (Cross-Region via DRG)                                ║
# ║  Versión: 2.0 | Terraform >= 1.5 | OCI Provider >= 6.0                    ║
# ║  Region 1 (Hub):   VCN + LB + Webserver + Bastion                         ║
# ║  Region 2 (Spoke): VCN + Backend server                                   ║
# ║  Interconexión: DRG + Remote Peering Connection (RPC)                      ║
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
    key = "v2/09-peering-remoto/terraform.tfstate"
  }
}

# ─── Proveedor Región 1 (Hub / Primary) ──────────────────────────────────
provider "oci" {
  alias            = "region1"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# ─── Proveedor Región 2 (Spoke / Secondary) ──────────────────────────────
provider "oci" {
  alias            = "region2"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region2
}
