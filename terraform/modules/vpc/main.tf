# VPC Module - Networking Infrastructure
# This module creates VPC, subnets, and security configurations

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "${var.environment}-vpc"
  auto_create_subnetworks = false
  routing_mode           = "REGIONAL"
  description            = "VPC for ${var.environment} environment"
}

# Public Subnet for GKE nodes
resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.environment}-public-subnet"
  ip_cidr_range = var.public_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  description   = "Public subnet for ${var.environment} GKE nodes"

  secondary_ip_range {
    range_name    = "${var.environment}-gke-pods"
    ip_cidr_range = var.pods_cidr_range
  }

  secondary_ip_range {
    range_name    = "${var.environment}-gke-services"
    ip_cidr_range = var.services_cidr_range
  }
}

# Private Subnet for databases and internal services
resource "google_compute_subnetwork" "private_subnet" {
  name                     = "${var.environment}-private-subnet"
  ip_cidr_range           = var.private_subnet_cidr
  region                  = var.region
  network                 = google_compute_network.vpc.id
  description             = "Private subnet for ${var.environment} databases"
  private_ip_google_access = true
}

# Cloud Router for NAT Gateway
resource "google_compute_router" "router" {
  name    = "${var.environment}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

# Cloud NAT for outbound internet access from private resources
resource "google_compute_router_nat" "nat" {
  name                               = "${var.environment}-nat"
  router                            = google_compute_router.router.name
  region                            = var.region
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

# Firewall rule for GKE cluster communication
resource "google_compute_firewall" "gke_cluster" {
  name    = "${var.environment}-gke-cluster-fw"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["443", "80", "8080", "10250"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  source_ranges = [var.public_subnet_cidr, var.pods_cidr_range]
  target_tags   = ["gke-node"]
}

# Firewall rule for SSH access (for debugging)
resource "google_compute_firewall" "ssh" {
  name    = "${var.environment}-ssh-fw"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-enabled"]
}

# Firewall rule for PostgreSQL access from GKE
resource "google_compute_firewall" "postgresql" {
  name    = "${var.environment}-postgresql-fw"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = [var.public_subnet_cidr, var.pods_cidr_range]
  target_tags   = ["postgresql-access"]
} 