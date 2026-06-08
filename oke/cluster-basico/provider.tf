# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  OKE Cluster Básico — Arquitectura de Referencia                            ║
# ║  Oracle Cloud Infrastructure | Terraform >= 1.5 | OCI Provider >= 6.0      ║
# ║                                                                              ║
# ║  Despliegue empresarial de Kubernetes en OCI con configuración optimizada   ║
# ║  para seguridad, escalabilidad y mejor práctica de infraestructura.         ║
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
    key = "oke/cluster-basico/terraform.tfstate"
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
