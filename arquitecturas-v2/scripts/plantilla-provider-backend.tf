# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  PLANTILLA: Provider + Backend S3 para nuevas arquitecturas                 ║
# ║  Copiar a cada nueva arquitectura y cambiar solo el valor de "key"          ║
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
  # │ O usando el script helper:                                                │
  # │   .\scripts\init-backend.ps1 -Arquitectura "XX-nombre-arquitectura"       │
  # └────────────────────────────────────────────────────────────────────────────┘
  backend "s3" {
    # ⚠️  CAMBIAR ESTE VALOR para cada arquitectura:
    key = "v2/XX-nombre-arquitectura/terraform.tfstate"
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
