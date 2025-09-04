variable "environment" {
  description = "Environment name (prod, stage)"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "support_email" {
  description = "Support email for OAuth brand"
  type        = string
}

variable "application_title" {
  description = "Application title for OAuth brand"
  type        = string
}

variable "enable_iap" {
  description = "Enable Identity-Aware Proxy"
  type        = bool
  default     = false
}

variable "backend_service_name" {
  description = "Name of the backend service for IAP"
  type        = string
  default     = ""
}

variable "iap_users" {
  description = "List of users/groups allowed to access IAP-protected resources"
  type        = list(string)
  default     = []
}

variable "oauth_service_account_roles" {
  description = "List of IAM roles for OAuth service account"
  type        = list(string)
  default = [
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountTokenCreator"
  ]
}

variable "additional_oauth_clients" {
  description = "Map of additional OAuth clients to create"
  type        = map(object({
    description = string
  }))
  default = {}
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity for Kubernetes"
  type        = bool
  default     = true
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for Workload Identity"
  type        = string
  default     = "default"
}

variable "kubernetes_service_account" {
  description = "Kubernetes service account name for Workload Identity"
  type        = string
  default     = "workload-identity-sa"
}

variable "workload_identity_roles" {
  description = "List of IAM roles for Workload Identity service account"
  type        = list(string)
  default = [
    "roles/secretmanager.secretAccessor",
    "roles/cloudsql.client",
    "roles/storage.objectViewer"
  ]
}

variable "enable_cloud_endpoints" {
  description = "Enable Cloud Endpoints for API management"
  type        = bool
  default     = false
}

variable "api_service_name" {
  description = "Name of the API service for Cloud Endpoints"
  type        = string
  default     = ""
}

variable "openapi_config_content" {
  description = "OpenAPI configuration content for Cloud Endpoints"
  type        = string
  default     = ""
}

variable "api_service_users" {
  description = "List of users/groups allowed to use the API service"
  type        = list(string)
  default     = []
} 