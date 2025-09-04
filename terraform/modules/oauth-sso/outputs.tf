output "oauth_client_id" {
  description = "OAuth client ID"
  value       = google_iap_client.oauth_client.client_id
  sensitive   = true
}

output "oauth_client_secret" {
  description = "OAuth client secret"
  value       = google_iap_client.oauth_client.secret
  sensitive   = true
}

output "oauth_brand_name" {
  description = "OAuth brand name"
  value       = google_iap_brand.oauth_brand.name
}

output "oauth_service_account_email" {
  description = "Email of the OAuth service account"
  value       = google_service_account.oauth_service_account.email
}

output "oauth_client_id_secret_name" {
  description = "Secret Manager secret name for OAuth client ID"
  value       = google_secret_manager_secret.oauth_client_id.secret_id
}

output "oauth_client_secret_secret_name" {
  description = "Secret Manager secret name for OAuth client secret"
  value       = google_secret_manager_secret.oauth_client_secret.secret_id
}

output "additional_oauth_clients" {
  description = "Additional OAuth clients created"
  value = {
    for k, v in google_iap_client.additional_oauth_clients : k => {
      client_id = v.client_id
      secret    = v.secret
    }
  }
  sensitive = true
}

output "workload_identity_service_account_email" {
  description = "Email of the Workload Identity service account"
  value       = var.enable_workload_identity ? google_service_account.workload_identity_sa[0].email : null
}

output "api_service_name" {
  description = "Name of the Cloud Endpoints API service"
  value       = var.enable_cloud_endpoints ? google_endpoints_service.api_service[0].service_name : null
} 