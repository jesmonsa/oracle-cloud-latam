variable "region" {
  description = "OCI Region"
  type        = string
  default     = "sa-saopaulo-1"
}

variable "compartment_id" {
  description = "Compartment OCID"
  type        = string
  sensitive   = false
}

variable "table_name" {
  description = "NoSQL Table name"
  type        = string
  default     = "application-data"
}

variable "capacity_mode" {
  description = "Capacity mode: ON_DEMAND or FIXED"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "FIXED"], var.capacity_mode)
    error_message = "Capacity mode must be ON_DEMAND or FIXED"
  }
}

variable "fixed_read_units" {
  description = "Fixed read units (if FIXED mode)"
  type        = number
  default     = 1000
}

variable "fixed_write_units" {
  description = "Fixed write units (if FIXED mode)"
  type        = number
  default     = 1000
}

variable "ttl_days" {
  description = "TTL in days (0 = no expiration)"
  type        = number
  default     = 0
}

variable "enable_replication" {
  description = "Enable multi-region replication"
  type        = bool
  default     = false
}

variable "replica_region" {
  description = "Replica region for replication"
  type        = string
  default     = "ca-montreal-1"
}

variable "enable_monitoring" {
  description = "Enable OCI Monitoring"
  type        = bool
  default     = true
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "mi-proyecto"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    CreatedBy = "Terraform"
    Architecture = "datos-nosql"
  }
}
