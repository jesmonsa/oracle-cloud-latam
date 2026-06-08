output "mysql_cluster_id" {
  description = "MySQL Cluster OCID"
  value       = "TODO"
}

output "mysql_hostname" {
  description = "MySQL endpoint hostname"
  value       = "TODO"
}

output "mysql_port" {
  description = "MySQL port"
  value       = 3306
}

output "admin_user" {
  description = "Admin username"
  value       = var.admin_user
}

output "jdbc_connection_string" {
  description = "JDBC connection string"
  value       = "TODO: jdbc:mysql://{hostname}:3306/?useSSL=true"
}

output "mysql_connection_command" {
  description = "MySQL CLI connection command"
  value       = "TODO: mysql -h {hostname} -u ${var.admin_user} -p"
}
