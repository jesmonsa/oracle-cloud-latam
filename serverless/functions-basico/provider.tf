terraform {
  required_version = ">= 1.5"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0"
    }
  }

  # Descomenta para usar S3-Compatible backend
  # backend "s3" {
  #   bucket         = "terraform-state-latam"
  #   key            = "serverless/functions-basico/terraform.tfstate"
  #   region         = "us-phoenix-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-lock"
  # }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
