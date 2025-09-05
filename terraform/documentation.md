# Terraform Infrastructure Documentation

## Overview
This document provides a short overview of the Terraform infrastructure implementation for the Bro AI project. The infrastructure is organized into reusable modules and environment-specific configurations.

## Module Organization

### VPC Module (`modules/vpc/`)
- **Purpose**: Sets up networking infrastructure including VPC, subnets, routing, and security
- **Components**: VPC network, public/private subnets, Cloud Router, Cloud NAT, firewall rules
- **Security**: Implements network segmentation and access controls

### Kubernetes Module (`modules/kubernetes/`)
- **Purpose**: Provisions Google Kubernetes Engine (GKE) clusters with security best practices
- **Components**: Private GKE cluster, node pools, service accounts, Workload Identity
- **Features**: Auto-scaling, regional deployment, security hardening

### PostgreSQL Module (`modules/postgresql/`)
- **Purpose**: Sets up managed PostgreSQL database with backup and security features
- **Components**: Cloud SQL instance, database users, Secret Manager integration
- **Security**: Private IP only, SSL encryption, automated backups

### OAuth SSO Module (`modules/oauth-sso/`)
- **Purpose**: Configures OAuth 2.0 authentication and Identity-Aware Proxy
- **Components**: OAuth clients, IAP configuration, Workload Identity bindings
- **Security**: Secure credential storage in Secret Manager

## Environment Configurations

### Staging Environment (`environments/stage/`)
- **Optimized for**: Development and testing
- **Resources**: Cost-optimized with preemptible nodes and zonal database
- **Features**: Reduced resource allocation, simplified monitoring

### Production Environment (`environments/prod/`)
- **Optimized for**: High availability and performance
- **Resources**: Regional database, standard nodes, enhanced monitoring
- **Features**: Production-grade resource allocation and redundancy

## Recent Fixes and Updates

### Secret Manager Configuration
- **Fixed**: Corrected `automatic = true` to `auto {}` for Secret Manager replication
- **Affected Modules**: OAuth SSO and PostgreSQL modules
- **Impact**: Ensures proper Secret Manager resource creation

### Cloud SQL Configuration
- **Fixed**: Updated `require_ssl = true` to `ssl_mode = "ENCRYPTED_ONLY"`
- **Affected Module**: PostgreSQL module
- **Impact**: Proper SSL/TLS configuration for database connections

### Known Issues and Deprecations
- **IAP OAuth Client Warning**: The `google_iap_client` resource will be deprecated after July 2025 due to IAP OAuth Admin API deprecation
- **Action Required**: Plan migration to new authentication methods before deprecation deadline
- **Current Status**: Functional but generates validation warnings

## Validation Status
✅ All Terraform configurations pass validation
✅ Formatting is consistent across all files
✅ Both staging and production environments are ready for deployment
⚠️ IAP OAuth deprecation warnings present (future action required)

## Usage
1. **Initialize**: `terraform init` in the respective environment directory
2. **Plan**: `terraform plan` to review changes
3. **Apply**: `terraform apply` to deploy infrastructure
4. **Validate**: `terraform validate` to check configuration syntax

## Best Practices Implemented
- Modular architecture for reusability
- Environment-specific variable files
- Secret management with Google Secret Manager
- Network security with private clusters and VPCs
- Infrastructure as Code with proper version control 