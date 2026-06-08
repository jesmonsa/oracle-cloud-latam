terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }

  # Backend remoto en OCI Object Storage
  # Descomenta y configura para usar estado remoto
  # backend "s3" {
  #   bucket         = "terraform-state-bucket"
  #   key            = "devops/devops-pipeline/terraform.tfstate"
  #   region         = "us-phoenix-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
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
