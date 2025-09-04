output "instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = google_sql_database_instance.postgresql.name
}

output "instance_connection_name" {
  description = "Connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.postgresql.connection_name
}

output "private_ip_address" {
  description = "Private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.postgresql.private_ip_address
}

output "public_ip_address" {
  description = "Public IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.postgresql.public_ip_address
}

output "default_database_name" {
  description = "Name of the default database"
  value       = google_sql_database.default_database.name
}

output "default_user_name" {
  description = "Name of the default user"
  value       = google_sql_user.default_user.name
}

output "database_password_secret" {
  description = "Secret Manager secret name for database password"
  value       = google_secret_manager_secret.db_password.secret_id
}

output "additional_databases" {
  description = "Names of additional databases"
  value       = [for db in google_sql_database.additional_databases : db.name]
}

output "additional_users" {
  description = "Names of additional users"
  value       = [for user in google_sql_user.additional_users : user.name]
} 