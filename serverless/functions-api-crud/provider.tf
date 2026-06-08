terraform {
  required_version = ">= 1.5"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0"
    }
  }

  # backend "s3" {
  #   bucket         = "terraform-state-latam"
  #   key            = "serverless/functions-api-crud/terraform.tfstate"
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
