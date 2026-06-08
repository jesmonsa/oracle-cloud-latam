terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }

  # Backend remoto en OCI Object Storage
  # Descomenta y configura para usar estado remoto
  # backend "s3" {
  #   bucket         = "terraform-state-bucket"
  #   key            = "devops/gitops-argocd/terraform.tfstate"
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

provider "kubernetes" {
  host                   = data.oci_containerengine_cluster.target.kubernetes_cluster_nodes[0].public_ip
  client_certificate     = base64decode(data.oci_containerengine_kubeconfig.target.content)
  client_key             = base64decode(data.oci_containerengine_kubeconfig.target.content)
  cluster_ca_certificate = base64decode(data.oci_containerengine_kubeconfig.target.content)
}

provider "helm" {
  kubernetes {
    host                   = data.oci_containerengine_cluster.target.kubernetes_cluster_nodes[0].public_ip
    client_certificate     = base64decode(data.oci_containerengine_kubeconfig.target.content)
    client_key             = base64decode(data.oci_containerengine_kubeconfig.target.content)
    cluster_ca_certificate = base64decode(data.oci_containerengine_kubeconfig.target.content)
  }
}

# Data source para obtener kubeconfig del cluster existente
data "oci_containerengine_cluster" "target" {
  cluster_id = var.oke_cluster_id
}

data "oci_containerengine_kubeconfig" "target" {
  cluster_id    = var.oke_cluster_id
  token_version = "2.0.0"
}
