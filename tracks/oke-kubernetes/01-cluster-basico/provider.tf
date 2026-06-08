# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Track OKE — Lección 01: Cluster Básico (Flannel CNI)                     ║
# ║  Versión: 2.0 | Terraform >= 1.5 | OCI Provider >= 6.0                    ║
# ║  OKE Cluster + Node Pool + VCN 3-subnet (API, LB, Nodes)                  ║
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
    key = "tracks/oke/01-cluster-basico/terraform.tfstate"
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
