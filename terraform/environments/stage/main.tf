# Staging Environment Configuration
# This file orchestrates all infrastructure modules for staging

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  # Backend configuration for remote state
  backend "gcs" {
    bucket = "YOUR_PROJECT_ID-terraform-state"
    prefix = "environments/stage"
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Local values for consistent naming
locals {
  environment = "stage"
  common_labels = {
    environment = local.environment
    managed_by  = "terraform"
    project     = var.project_id
  }
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
    "secretmanager.googleapis.com",
    "iap.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com"
  ])

  project = var.project_id
  service = each.value

  disable_dependent_services = false
  disable_on_destroy        = false
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  environment           = local.environment
  project_id           = var.project_id
  region               = var.region
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  pods_cidr_range      = var.pods_cidr_range
  services_cidr_range  = var.services_cidr_range

  depends_on = [google_project_service.required_apis]
}

# Kubernetes Module
module "kubernetes" {
  source = "../../modules/kubernetes"

  environment                   = local.environment
  project_id                   = var.project_id
  region                       = var.region
  vpc_name                     = module.vpc.vpc_name
  subnet_name                  = module.vpc.public_subnet_name
  pods_secondary_range_name    = module.vpc.pods_secondary_range_name
  services_secondary_range_name = module.vpc.services_secondary_range_name
  
  # Staging-specific settings (cost-optimized)
  min_node_count         = var.min_node_count
  max_node_count         = var.max_node_count
  node_machine_type      = var.node_machine_type
  node_disk_size         = var.node_disk_size
  use_preemptible_nodes  = var.use_preemptible_nodes
  release_channel        = var.release_channel
  
  depends_on = [module.vpc]
}

# PostgreSQL Module
module "postgresql" {
  source = "../../modules/postgresql"

  environment         = local.environment
  project_id         = var.project_id
  region             = var.region
  vpc_id             = module.vpc.vpc_id
  
  # Staging-specific settings (cost-optimized)
  database_version      = var.database_version
  instance_tier        = var.db_instance_tier
  availability_type    = var.db_availability_type
  disk_type           = var.db_disk_type
  disk_size           = var.db_disk_size
  deletion_protection = var.db_deletion_protection
  
  # Backup settings
  backup_retained_count = var.db_backup_retained_count
  
  # Additional databases
  additional_databases = var.additional_databases
  
  depends_on = [module.vpc]
}

# OAuth SSO Module
module "oauth_sso" {
  source = "../../modules/oauth-sso"

  environment       = local.environment
  project_id       = var.project_id
  support_email    = var.support_email
  application_title = var.application_title
  
  # IAP settings
  enable_iap           = var.enable_iap
  backend_service_name = var.backend_service_name
  iap_users           = var.iap_users
  
  # Workload Identity settings
  enable_workload_identity    = var.enable_workload_identity
  kubernetes_namespace        = var.kubernetes_namespace
  kubernetes_service_account  = var.kubernetes_service_account
  
  depends_on = [module.kubernetes]
} 