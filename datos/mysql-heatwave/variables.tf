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

variable "cluster_name" {
  description = "MySQL HeatWave cluster name"
  type        = string
  default     = "myhw-cluster"
}

variable "admin_user" {
  description = "Admin user for MySQL"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Admin password (min 8 chars)"
  type        = string
  sensitive   = true
}

variable "mysql_version" {
  description = "MySQL version (8.0 or 8.1)"
  type        = string
  default     = "8.0"
  validation {
    condition     = contains(["8.0", "8.1"], var.mysql_version)
    error_message = "MySQL version must be 8.0 or 8.1"
  }
}

variable "mysql_shape" {
  description = "MySQL shape type"
  type        = string
  default     = "MySQL.HeatWave.VM.Standard"
}

variable "vpcpu_count" {
  description = "Number of vCPUs (2-16)"
  type        = number
  default     = 4
  validation {
    condition     = var.vpcpu_count >= 2 && var.vpcpu_count <= 16
    error_message = "vCPU must be between 2 and 16"
  }
}

variable "memory_gb" {
  description = "Memory in GB"
  type        = number
  default     = 32
}

variable "storage_gb" {
  description = "Storage in GB (min 50)"
  type        = number
  default     = 100
  validation {
    condition     = var.storage_gb >= 50
    error_message = "Storage must be at least 50 GB"
  }
}

variable "enable_heatwave" {
  description = "Enable HeatWave Analytics"
  type        = bool
  default     = true
}

variable "heatwave_node_count" {
  description = "Number of HeatWave nodes (1-32)"
  type        = number
  default     = 2
  validation {
    condition     = var.heatwave_node_count >= 1 && var.heatwave_node_count <= 32
    error_message = "HeatWave nodes must be 1-32"
  }
}

variable "vcn_id" {
  description = "VCN OCID"
  type        = string
}

variable "subnet_id" {
  description = "Private Subnet OCID"
  type        = string
}

variable "backup_retention_days" {
  description = "Backup retention days (1-35)"
  type        = number
  default     = 30
}

variable "enable_backup" {
  description = "Enable automatic backups"
  type        = bool
  default     = true
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
    Architecture = "datos-mysql-heatwave"
  }
}
