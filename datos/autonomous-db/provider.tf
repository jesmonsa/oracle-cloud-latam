terraform {
  required_version = ">= 1.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state"
    key            = "datos/autonomous-db/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "oci" {
  region = var.region

  # Credentials from environment variables:
  # export TF_VAR_tenancy_ocid="ocid1.tenancy..."
  # export TF_VAR_user_ocid="ocid1.user..."
  # export TF_VAR_private_key="-----BEGIN..."
  # export TF_VAR_fingerprint="xx:xx:xx..."
}

# Configure OCI provider with explicit credentials if needed
# provider "oci" {
#   tenancy_ocid     = var.tenancy_ocid
#   user_ocid        = var.user_ocid
#   private_key      = var.private_key
#   fingerprint      = var.fingerprint
#   region           = var.region
# }
