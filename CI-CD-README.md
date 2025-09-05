# CI/CD Pipeline Documentation

## Overview

This document describes the complete CI/CD pipeline for the Bro AI infrastructure. The pipeline focuses on infrastructure validation, deployment automation, and operational excellence using GitHub Actions and ArgoCD for GitOps-based deployments.

**Note**: This repository contains only infrastructure code. Application code is maintained separately and deployments reference external application images.

## Architecture

The CI/CD pipeline consists of three main workflows:

1. **Infrastructure Validation** (`.github/workflows/build.yml`) - Validates infrastructure code and configurations
2. **Infrastructure Deploy** (`.github/workflows/deploy.yml`) - Manages infrastructure deployments via ArgoCD
3. **Backup & Health** (`.github/workflows/backup.yml`) - Automated backup processes and health monitoring

## Workflows

### 1. Infrastructure Validation Workflow

**Trigger**: Push to `main`/`develop` branches or pull requests affecting infrastructure files
**Purpose**: Comprehensive validation of infrastructure code and configurations

#### Jobs:

##### Terraform Validation
- **Terraform Format Check**: Ensures consistent code formatting
- **Module Validation**: Validates all Terraform modules independently
- **Environment Validation**: Validates staging and production configurations
- **Multi-environment Testing**: Tests both staging and production environments

##### YAML Validation
- **Workflow Validation**: Validates GitHub Actions workflows
- **Kubernetes Manifest Validation**: Validates all K8s YAML files
- **ArgoCD Configuration Validation**: Validates ArgoCD application definitions
- **Linting**: Comprehensive YAML linting with custom rules

##### Kubernetes Validation
- **kubeval**: Validates Kubernetes manifests against schema
- **Manifest Structure**: Ensures proper resource definitions
- **Cross-environment Validation**: Validates both staging and production manifests

##### Security Scanning
- **Trivy Filesystem Scan**: Scans infrastructure code for security vulnerabilities
- **SARIF Integration**: Uploads security findings to GitHub Security tab
- **Infrastructure Security**: Identifies misconfigurations and security issues

##### Documentation Check
- **Required Files**: Ensures all documentation files are present
- **TODO Detection**: Identifies outstanding TODO items in infrastructure
- **Documentation Completeness**: Validates documentation coverage

##### Cost Estimation (PR only)
- **Infracost Integration**: Provides cost estimates for infrastructure changes
- **Multi-environment Costing**: Separate estimates for staging and production
- **PR Comments**: Automated cost impact comments on pull requests

### 2. Infrastructure Deploy Workflow

**Trigger**: Push to `main`/`develop` branches affecting K8s manifests or manual dispatch
**Purpose**: Manages infrastructure deployments using GitOps via ArgoCD

#### Jobs:

##### Get Infrastructure Info
- **Terraform Output Extraction**: Retrieves cluster information from Terraform state
- **Dynamic Environment Detection**: Determines target environment based on branch/input
- **Cluster Credential Management**: Configures access to target GKE clusters

##### Validate Manifests
- **Pre-deployment Validation**: Validates Kubernetes manifests before deployment
- **Schema Compliance**: Ensures manifests comply with Kubernetes API

##### Deploy to Staging
**Trigger**: Push to `develop` branch or manual dispatch to staging
**Environment**: staging (GitHub environment protection)

- **Manifest Updates**: Updates staging manifests with commit references
- **Git Integration**: Commits and pushes manifest changes
- **ArgoCD Sync**: Triggers ArgoCD application synchronization
- **Health Checks**: Monitors application health and readiness
- **Automatic Rollback**: Fails deployment if health checks don't pass

##### Deploy to Production
**Trigger**: Push to `main` branch or manual dispatch to production
**Environment**: production (requires manual approval)

- **Production Safeguards**: Enhanced validation and approval process
- **Manifest Updates**: Updates production manifests with commit references
- **Manual/Automatic Sync**: Configurable sync policy via workflow input
- **Smoke Tests**: Runs production health checks and endpoint testing
- **Health Monitoring**: Comprehensive application health validation

##### Deployment Notifications
- **Slack Integration**: Sends deployment status to configured Slack channels
- **Status Reporting**: Success, failure, or skip notifications
- **Rich Messages**: Includes repository, branch, commit, and workflow details

### 3. Backup & Health Workflow

**Trigger**: Daily schedule (1 AM UTC) or manual dispatch
**Purpose**: Automated backup processes and infrastructure health monitoring

#### Jobs:

##### Database Backup
- **Cloud SQL Backups**: Creates and manages database backups
- **GCS Export**: Exports database contents to Google Cloud Storage
- **Backup Validation**: Verifies backup integrity and completeness

##### Infrastructure State Backup
- **Terraform State Backup**: Backs up Terraform state files
- **State Validation**: Ensures state file integrity
- **Version Management**: Maintains versioned state backups

##### Secret Backup
- **Secret Metadata Export**: Backs up Secret Manager configurations
- **Security Compliance**: Maintains audit trail for secret management
- **Access Control**: Ensures proper permissions for backup operations

##### Cleanup Operations
- **Old Backup Removal**: Removes backups beyond retention period
- **Storage Optimization**: Manages storage costs through lifecycle policies
- **Resource Cleanup**: Removes temporary and obsolete resources

##### Health Monitoring
- **Infrastructure Drift Detection**: Runs `terraform plan` to detect configuration drift
- **Cluster Health Checks**: Validates GKE cluster status and node health
- **Database Health**: Checks database connectivity and performance
- **Service Health**: Validates critical service availability

##### Notification System
- **Backup Status Alerts**: Notifies team of backup success/failure
- **Health Check Results**: Reports infrastructure health status
- **Issue Escalation**: Alerts on critical infrastructure problems

## Prerequisites

### Required Tools
- **Terraform**: v1.5.0 or later
- **kubectl**: For Kubernetes cluster interaction
- **ArgoCD CLI**: For GitOps deployment management
- **Google Cloud SDK**: For GCP resource management

### GCP Setup
1. **Service Account**: Create dedicated service account for CI/CD
2. **IAM Permissions**: Configure required permissions (see Security section)
3. **API Enablement**: Enable necessary GCP APIs
4. **Project Configuration**: Set up staging and production projects

### Infrastructure Prerequisites
- **GKE Clusters**: Deployed via Terraform (staging and production)
- **ArgoCD Installation**: Deployed and configured on clusters
- **Network Configuration**: VPC and firewall rules configured
- **Database Setup**: Cloud SQL instances provisioned

## Required GitHub Secrets

Configure the following secrets in your GitHub repository settings:

### GCP Authentication
```bash
# GCP Service Account Key (JSON format)
GCP_SA_KEY="<base64-encoded-service-account-key>"

# GCP Project ID
GCP_PROJECT_ID="your-gcp-project-id"
```

**To generate the GCP Service Account Key:**
```bash
# Create service account
gcloud iam service-accounts create github-actions-sa \
  --display-name="GitHub Actions Service Account"

# Grant required permissions
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/container.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudsql.admin"

# Create and download key
gcloud iam service-accounts keys create github-actions-key.json \
  --iam-account=github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com

# Base64 encode the key for GitHub secret
base64 -i github-actions-key.json
```

### ArgoCD Configuration
```bash
# ArgoCD server URL
ARGOCD_SERVER="argocd.your-domain.com"

# ArgoCD admin username
ARGOCD_USERNAME="admin"

# ArgoCD admin password
ARGOCD_PASSWORD="your-argocd-password"
```

### Notification Integration
```bash
# Slack webhook URL for notifications
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
```

### Cost Monitoring (Optional)
```bash
# Infracost API key for cost estimation
INFRACOST_API_KEY="your-infracost-api-key"
```

## Setup Instructions

### 1. Repository Configuration
```bash
# Clone the repository
git clone https://github.com/your-org/bro-ai-infra.git
cd bro-ai-infra

# Configure GitHub secrets (via GitHub UI or CLI)
gh secret set GCP_SA_KEY --body "$(base64 -i github-actions-key.json)"
gh secret set GCP_PROJECT_ID --body "your-gcp-project-id"
gh secret set ARGOCD_SERVER --body "argocd.your-domain.com"
gh secret set ARGOCD_USERNAME --body "admin"
gh secret set ARGOCD_PASSWORD --body "your-argocd-password"
gh secret set SLACK_WEBHOOK_URL --body "your-slack-webhook-url"
```

### 2. Infrastructure Deployment
```bash
# Deploy infrastructure using Terraform
cd terraform/environments/stage
terraform init
terraform plan
terraform apply

# Deploy ArgoCD
kubectl apply -f ../../argocd/argocd-setup.yaml
./../../ci/setup-scripts/install-argocd.sh
```

### 3. ArgoCD Application Setup
```bash
# Apply ArgoCD applications
kubectl apply -f argocd/applications/bro-ai-staging.yaml
kubectl apply -f argocd/applications/bro-ai-production.yaml

# Verify application status
argocd app list
argocd app get bro-ai-staging
```

## Usage Guide

### Infrastructure Changes
1. **Make Changes**: Modify Terraform configurations or Kubernetes manifests
2. **Create PR**: Submit pull request for review
3. **Validation**: Automated validation runs on PR
4. **Review**: Team reviews changes and validation results
5. **Merge**: Merge to `develop` for staging or `main` for production
6. **Deploy**: Automated deployment via ArgoCD

### Manual Deployments
```bash
# Trigger manual deployment
gh workflow run deploy.yml \
  --field environment=staging \
  --field sync_policy=automatic

# Check deployment status
gh run list --workflow=deploy.yml
gh run view <run-id>
```

### Monitoring Deployments
```bash
# Check ArgoCD application status
argocd app get bro-ai-staging
argocd app sync bro-ai-staging

# Monitor Kubernetes resources
kubectl get pods -n staging
kubectl get services -n staging
kubectl logs -f deployment/bro-ai-app -n staging
```

### Backup Operations
```bash
# Trigger manual backup
gh workflow run backup.yml

# Check backup status
gsutil ls gs://your-backup-bucket/

# Verify database backups
gcloud sql backups list --instance=your-instance
```

## Troubleshooting

### Common Issues

#### Terraform State Lock
```bash
# Force unlock if needed (use with caution)
terraform force-unlock <lock-id>
```

#### ArgoCD Sync Issues
```bash
# Manual sync with prune
argocd app sync bro-ai-staging --prune

# Hard refresh
argocd app refresh bro-ai-staging --hard

# Check application health
argocd app get bro-ai-staging
```

#### GKE Authentication
```bash
# Re-authenticate with cluster
gcloud container clusters get-credentials cluster-name --region region

# Check permissions
kubectl auth can-i create deployments --namespace staging
```

#### Secret Management
```bash
# Verify secret access
gcloud secrets versions access latest --secret="database-password"

# Check Workload Identity
kubectl describe serviceaccount bro-ai-service-account -n staging
```

### Debug Commands
```bash
# Check workflow logs
gh run view <run-id> --log

# Kubernetes debugging
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>

# ArgoCD debugging
argocd app logs bro-ai-staging
argocd app manifests bro-ai-staging
```

## Monitoring and Alerting

### GitHub Actions
- **Workflow Status**: Monitor workflow success/failure rates
- **Action Insights**: Review action performance and usage
- **Security Alerts**: Monitor security findings and vulnerabilities

### ArgoCD
- **Application Health**: Monitor application sync and health status
- **Sync Frequency**: Track deployment frequency and patterns
- **Drift Detection**: Monitor configuration drift and corrections

### Infrastructure
- **Resource Utilization**: Monitor CPU, memory, and storage usage
- **Cost Tracking**: Monitor infrastructure costs and optimization opportunities
- **Security Posture**: Continuous security monitoring and compliance

## Security Best Practices

### Secret Management
- **Rotation**: Regularly rotate service account keys and passwords
- **Least Privilege**: Grant minimum required permissions
- **Audit**: Regular audit of secret access and usage

### Access Control
- **Branch Protection**: Protect main branches with required reviews
- **Environment Protection**: Use GitHub environment protection rules
- **RBAC**: Implement role-based access control in Kubernetes

### Security Scanning
- **Continuous Scanning**: Automated security scanning in CI/CD
- **Vulnerability Management**: Regular updates and patches
- **Compliance**: Maintain compliance with security standards

This CI/CD pipeline provides robust infrastructure management capabilities with strong emphasis on automation, security, and operational excellence. 