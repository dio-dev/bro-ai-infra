# PostgreSQL Cloud SQL Module
# This module creates a Cloud SQL PostgreSQL instance

# Random password for the PostgreSQL instance
resource "random_password" "postgres_password" {
  length  = 16
  special = true
}

# Cloud SQL PostgreSQL instance
resource "google_sql_database_instance" "postgresql" {
  name             = "${var.environment}-postgresql-${random_id.instance_suffix.hex}"
  database_version = var.database_version
  region           = var.region
  
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.instance_tier
    availability_type = var.availability_type
    disk_type         = var.disk_type
    disk_size         = var.disk_size
    disk_autoresize   = var.disk_autoresize

    # Backup configuration
    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      location                      = var.backup_location
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = var.backup_retained_count
        retention_unit   = "COUNT"
      }
    }

    # IP configuration
    ip_configuration {
      ipv4_enabled    = true
      private_network = var.vpc_id
      require_ssl     = true
      
      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.value
        }
      }
    }

    # Database flags
    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    # Maintenance window
    maintenance_window {
      day          = var.maintenance_window_day
      hour         = var.maintenance_window_hour
      update_track = var.maintenance_window_update_track
    }

    # User labels
    user_labels = {
      environment = var.environment
      managed_by  = "terraform"
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# Random suffix for instance name
resource "random_id" "instance_suffix" {
  byte_length = 4
}

# Default database
resource "google_sql_database" "default_database" {
  name     = var.default_database_name
  instance = google_sql_database_instance.postgresql.name
}

# Default user
resource "google_sql_user" "default_user" {
  name     = var.default_user_name
  instance = google_sql_database_instance.postgresql.name
  password = random_password.postgres_password.result
}

# Additional databases
resource "google_sql_database" "additional_databases" {
  for_each = toset(var.additional_databases)
  
  name     = each.value
  instance = google_sql_database_instance.postgresql.name
}

# Additional users
resource "google_sql_user" "additional_users" {
  for_each = var.additional_users
  
  name     = each.key
  instance = google_sql_database_instance.postgresql.name
  password = each.value.password != null ? each.value.password : random_password.postgres_password.result
}

# Private service networking for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.environment}-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Secret Manager secret for database password
resource "google_secret_manager_secret" "db_password" {
  secret_id = "${var.environment}-postgresql-password"
  
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.postgres_password.result
} 