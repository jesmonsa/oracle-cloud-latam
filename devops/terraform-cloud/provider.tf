terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.50"
    }
  }

  # Backend remoto en Terraform Cloud
  # Descomenta y configura para usar Terraform Cloud
  # cloud {
  #   organization = "YOUR_ORG"
  #   workspaces {
  #     name = "YOUR_WORKSPACE"
  #   }
  # }

  # Backend local (desarrollo)
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region

  # Configuración de retry
  retry_duration_seconds = 30
}

provider "tfe" {
  token   = var.tfc_token
  version = "~> 0.50"
}
