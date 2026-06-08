# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  00 - Bootstrap: Remote State Infrastructure                                ║
# ║  Crea bucket + credenciales S3 para almacenar tfstate de todas las arq.    ║
# ║  COSTO: $0.00/mes (dentro del free tier de OCI Object Storage)             ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0"
    }
  }

  # ⚠️  Este módulo usa state LOCAL a propósito.
  # Es el bootstrap - no puede depender de sí mismo.
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
