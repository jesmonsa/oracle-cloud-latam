variable "region" {
  type = string
  default = "sa-saopaulo-1"
}

variable "compartment_id" {
  type = string
}

variable "instance_name" {
  type = string
  default = "gg-replication-server"
}

variable "source_db_host" {
  type = string
}

variable "source_db_port" {
  type = number
  default = 1521
}

variable "source_db_name" {
  type = string
}

variable "target_db_host" {
  type = string
}

variable "target_db_port" {
  type = number
  default = 1521
}

variable "target_db_name" {
  type = string
}

variable "vcn_id" {
  type = string
}

variable "subnet_id" {
  type = string
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
    Architecture = "datos-golden-gate"
  }
}
