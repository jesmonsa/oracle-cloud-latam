output "nosql_table_id" {
  description = "NoSQL Table OCID"
  value       = "TODO"
}

output "nosql_table_name" {
  description = "NoSQL Table name"
  value       = var.table_name
}

output "capacity_mode" {
  description = "Capacity mode"
  value       = var.capacity_mode
}

output "api_endpoint" {
  description = "API endpoint for NoSQL"
  value       = "TODO"
}

output "estimated_monthly_cost" {
  description = "Estimated monthly cost"
  value       = var.capacity_mode == "ON_DEMAND" ? "USD ~$0.50-5.00/mes (variable)" : "USD ~$150-300/mes (fixed)"
}
