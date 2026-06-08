variable "region" {
  type = string
  default = "sa-saopaulo-1"
}

variable "compartment_id" {
  type = string
}

variable "workspace_name" {
  type = string
  default = "data-integration-ws"
}

variable "project_name" {
  type = string
  default = "mi-proyecto"
}

variable "environment" {
  type = string
  default = "prod"
}

variable "common_tags" {
  type = map(string)
  default = {
    CreatedBy = "Terraform"
    Architecture = "datos-data-integration"
  }
}
