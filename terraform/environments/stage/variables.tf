# Staging Environment Variables

# Project Configuration
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

# VPC Configuration
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.10.2.0/24"
}

variable "pods_cidr_range" {
  description = "CIDR block for GKE pods"
  type        = string
  default     = "10.11.0.0/16"
}

variable "services_cidr_range" {
  description = "CIDR block for GKE services"
  type        = string
  default     = "10.12.0.0/16"
}

# GKE Configuration (Cost-optimized for staging)
variable "min_node_count" {
  description = "Minimum number of nodes in the node pool"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes in the node pool"
  type        = number
  default     = 5
}

variable "node_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-medium"
}

variable "node_disk_size" {
  description = "Disk size for GKE nodes in GB"
  type        = number
  default     = 50
}

variable "use_preemptible_nodes" {
  description = "Whether to use preemptible nodes"
  type        = bool
  default     = true
}

variable "release_channel" {
  description = "Release channel for GKE cluster"
  type        = string
  default     = "REGULAR"
}

# Database Configuration (Cost-optimized for staging)
variable "database_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "POSTGRES_15"
}

variable "db_instance_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-f1-micro"
}

variable "db_availability_type" {
  description = "Availability type for the database instance"
  type        = string
  default     = "ZONAL"
}

variable "db_disk_type" {
  description = "Disk type for the database instance"
  type        = string
  default     = "PD_HDD"
}

variable "db_disk_size" {
  description = "Disk size for the database instance in GB"
  type        = number
  default     = 20
}

variable "db_deletion_protection" {
  description = "Enable deletion protection for database"
  type        = bool
  default     = false
}

variable "db_backup_retained_count" {
  description = "Number of database backups to retain"
  type        = number
  default     = 7
}

variable "additional_databases" {
  description = "List of additional databases to create"
  type        = list(string)
  default     = ["test_db"]
}

# OAuth/SSO Configuration
variable "support_email" {
  description = "Support email for OAuth brand"
  type        = string
}

variable "application_title" {
  description = "Application title for OAuth brand"
  type        = string
  default     = "Bro AI Staging"
}

variable "enable_iap" {
  description = "Enable Identity-Aware Proxy"
  type        = bool
  default     = false
}

variable "backend_service_name" {
  description = "Name of the backend service for IAP"
  type        = string
  default     = "stage-backend-service"
}

variable "iap_users" {
  description = "List of users/groups allowed to access IAP-protected resources"
  type        = list(string)
  default     = []
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity for Kubernetes"
  type        = bool
  default     = true
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for Workload Identity"
  type        = string
  default     = "staging"
}

variable "kubernetes_service_account" {
  description = "Kubernetes service account name for Workload Identity"
  type        = string
  default     = "workload-identity-sa"
} 