# Staging Environment Outputs

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "Name of the VPC"
  value       = module.vpc.vpc_name
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = module.vpc.private_subnet_id
}

# GKE Outputs
output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.kubernetes.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint of the GKE cluster"
  value       = module.kubernetes.cluster_endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate of the GKE cluster"
  value       = module.kubernetes.cluster_ca_certificate
  sensitive   = true
}

output "gke_service_account_email" {
  description = "Email of the GKE service account"
  value       = module.kubernetes.service_account_email
}

# Database Outputs
output "database_instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = module.postgresql.instance_name
}

output "database_connection_name" {
  description = "Connection name of the Cloud SQL instance"
  value       = module.postgresql.instance_connection_name
}

output "database_private_ip" {
  description = "Private IP address of the Cloud SQL instance"
  value       = module.postgresql.private_ip_address
}

output "default_database_name" {
  description = "Name of the default database"
  value       = module.postgresql.default_database_name
}

output "database_password_secret" {
  description = "Secret Manager secret name for database password"
  value       = module.postgresql.database_password_secret
}

# OAuth/SSO Outputs
output "oauth_client_id_secret" {
  description = "Secret Manager secret name for OAuth client ID"
  value       = module.oauth_sso.oauth_client_id_secret_name
}

output "oauth_client_secret_secret" {
  description = "Secret Manager secret name for OAuth client secret"
  value       = module.oauth_sso.oauth_client_secret_secret_name
}

output "oauth_service_account_email" {
  description = "Email of the OAuth service account"
  value       = module.oauth_sso.oauth_service_account_email
}

output "workload_identity_service_account_email" {
  description = "Email of the Workload Identity service account"
  value       = module.oauth_sso.workload_identity_service_account_email
} 