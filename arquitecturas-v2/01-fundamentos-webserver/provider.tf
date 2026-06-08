# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  01 - Fundamentos: Webserver Simple                                        ║
# ║  Versión: 2.0 | Terraform >= 1.5 | OCI Provider >= 6.0                    ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0"
    }
  }

  # ┌────────────────────────────────────────────────────────────────────────────┐
  # │ Backend remoto con OCI Object Storage (S3 Compatible)                     │
  # │                                                                           │
  # │ Prerequisito: ejecutar primero 00-bootstrap-remotestate                   │
  # │                                                                           │
  # │ Inicializar con:                                                          │
  # │   terraform init -backend-config=../00-bootstrap-remotestate/backend.hcl  │
  # │                                                                           │
  # │ Variables de entorno requeridas:                                          │
  # │   AWS_ACCESS_KEY_ID     = (output de 00-bootstrap)                       │
  # │   AWS_SECRET_ACCESS_KEY = (output de 00-bootstrap)                       │
  # └────────────────────────────────────────────────────────────────────────────┘
  backend "s3" {
    # "key" es lo único que cambia entre arquitecturas.
    # El resto viene de backend.hcl vía -backend-config
    key = "v2/01-fundamentos-webserver/terraform.tfstate"
  }
}

# ┌────────────────────────────────────────────────────────────────────────────┐
# │ Provider OCI - Autenticación                                              │
# │ Si usas OCI CLI config (~/.oci/config), puedes omitir estas variables.    │
# │ Resource Manager (ORM) las inyecta automáticamente.                       │
# └────────────────────────────────────────────────────────────────────────────┘
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
