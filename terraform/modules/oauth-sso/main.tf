# OAuth SSO Module
# This module sets up OAuth SSO configuration with Google Cloud Identity

# OAuth 2.0 Client for web application
resource "google_iap_client" "oauth_client" {
  display_name = "${var.environment} OAuth Client"
  brand        = google_iap_brand.oauth_brand.name
}

# OAuth Brand (required for OAuth clients)
resource "google_iap_brand" "oauth_brand" {
  support_email     = var.support_email
  application_title = var.application_title
  project           = var.project_id
}

# Identity-Aware Proxy for backend service
resource "google_iap_web_backend_service_iam_binding" "iap_users" {
  count   = var.enable_iap ? 1 : 0
  project = var.project_id
  web_backend_service = var.backend_service_name
  role    = "roles/iap.httpsResourceAccessor"
  members = var.iap_users
}

# Service Account for OAuth operations
resource "google_service_account" "oauth_service_account" {
  account_id   = "${var.environment}-oauth-sa"
  display_name = "OAuth Service Account for ${var.environment}"
  description  = "Service account for OAuth operations in ${var.environment}"
}

# IAM bindings for OAuth service account
resource "google_project_iam_member" "oauth_service_account_roles" {
  for_each = toset(var.oauth_service_account_roles)
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.oauth_service_account.email}"
}

# Secret Manager secrets for OAuth configuration
resource "google_secret_manager_secret" "oauth_client_id" {
  secret_id = "${var.environment}-oauth-client-id"
  
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "oauth_client_id_version" {
  secret      = google_secret_manager_secret.oauth_client_id.id
  secret_data = google_iap_client.oauth_client.client_id
}

resource "google_secret_manager_secret" "oauth_client_secret" {
  secret_id = "${var.environment}-oauth-client-secret"
  
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "oauth_client_secret_version" {
  secret      = google_secret_manager_secret.oauth_client_secret.id
  secret_data = google_iap_client.oauth_client.secret
}

# Additional OAuth clients for different services
resource "google_iap_client" "additional_oauth_clients" {
  for_each = var.additional_oauth_clients
  
  display_name = "${var.environment} ${each.key} OAuth Client"
  brand        = google_iap_brand.oauth_brand.name
}

# Kubernetes Service Account with Workload Identity
resource "google_service_account" "workload_identity_sa" {
  count        = var.enable_workload_identity ? 1 : 0
  account_id   = "${var.environment}-workload-identity-sa"
  display_name = "Workload Identity SA for ${var.environment}"
  description  = "Service account for Workload Identity in ${var.environment}"
}

# Workload Identity binding
resource "google_service_account_iam_binding" "workload_identity_binding" {
  count              = var.enable_workload_identity ? 1 : 0
  service_account_id = google_service_account.workload_identity_sa[0].name
  role               = "roles/iam.workloadIdentityUser"
  
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.kubernetes_namespace}/${var.kubernetes_service_account}]"
  ]
}

# IAM roles for Workload Identity service account
resource "google_project_iam_member" "workload_identity_roles" {
  for_each = var.enable_workload_identity ? toset(var.workload_identity_roles) : []
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.workload_identity_sa[0].email}"
}

# Cloud Endpoints service for API management
resource "google_endpoints_service" "api_service" {
  count       = var.enable_cloud_endpoints ? 1 : 0
  service_name = var.api_service_name
  project      = var.project_id

  openapi_config = var.openapi_config_content
}

# IAM policy for Cloud Endpoints
resource "google_endpoints_service_iam_binding" "api_service_users" {
  count        = var.enable_cloud_endpoints ? 1 : 0
  service_name = google_endpoints_service.api_service[0].service_name
  role         = "roles/servicemanagement.serviceController"
  members      = var.api_service_users
} 