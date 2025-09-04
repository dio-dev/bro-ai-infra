variable "environment" {
  description = "Environment name (prod, stage)"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "vpc_id" {
  description = "VPC network ID"
  type        = string
}

variable "database_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "POSTGRES_15"
}

variable "instance_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-f1-micro"
}

variable "availability_type" {
  description = "Availability type for the instance"
  type        = string
  default     = "ZONAL"
  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.availability_type)
    error_message = "Availability type must be either ZONAL or REGIONAL."
  }
}

variable "disk_type" {
  description = "Disk type for the instance"
  type        = string
  default     = "PD_SSD"
  validation {
    condition     = contains(["PD_SSD", "PD_HDD"], var.disk_type)
    error_message = "Disk type must be either PD_SSD or PD_HDD."
  }
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "disk_autoresize" {
  description = "Enable automatic disk resizing"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "backup_location" {
  description = "Backup location"
  type        = string
  default     = null
}

variable "backup_retained_count" {
  description = "Number of backups to retain"
  type        = number
  default     = 7
}

variable "authorized_networks" {
  description = "List of authorized networks"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "database_flags" {
  description = "List of database flags"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "maintenance_window_day" {
  description = "Day of the week for maintenance (1-7, Sunday = 7)"
  type        = number
  default     = 7
  validation {
    condition     = var.maintenance_window_day >= 1 && var.maintenance_window_day <= 7
    error_message = "Maintenance window day must be between 1 and 7."
  }
}

variable "maintenance_window_hour" {
  description = "Hour of the day for maintenance (0-23)"
  type        = number
  default     = 3
  validation {
    condition     = var.maintenance_window_hour >= 0 && var.maintenance_window_hour <= 23
    error_message = "Maintenance window hour must be between 0 and 23."
  }
}

variable "maintenance_window_update_track" {
  description = "Update track for maintenance"
  type        = string
  default     = "stable"
  validation {
    condition     = contains(["canary", "stable"], var.maintenance_window_update_track)
    error_message = "Update track must be either canary or stable."
  }
}

variable "default_database_name" {
  description = "Name of the default database"
  type        = string
  default     = "app_db"
}

variable "default_user_name" {
  description = "Name of the default user"
  type        = string
  default     = "app_user"
}

variable "additional_databases" {
  description = "List of additional databases to create"
  type        = list(string)
  default     = []
}

variable "additional_users" {
  description = "Map of additional users to create"
  type = map(object({
    password = string
  }))
  default = {}
} 