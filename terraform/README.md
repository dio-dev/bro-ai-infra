# Terraform Infrastructure Management

This repository contains Terraform configurations for managing infrastructure on Google Cloud Platform (GCP) for the Bro AI project. It provides a scalable, modular approach to infrastructure management with support for multiple environments.

## 🏗️ Architecture Overview

The infrastructure consists of the following components:

- **VPC & Networking**: Isolated network infrastructure with public/private subnets
- **Google Kubernetes Engine (GKE)**: Managed Kubernetes cluster for application workloads
- **Cloud SQL PostgreSQL**: Managed PostgreSQL database instances
- **OAuth SSO**: Identity and access management with Google Cloud Identity
- **Secret Management**: Secure handling of secrets using Google Secret Manager

## 📁 Directory Structure

```
terraform/
├── modules/                     # Reusable Terraform modules
│   ├── kubernetes/             # GKE cluster configuration
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── vpc/                    # VPC & networking
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── postgresql/             # Cloud SQL PostgreSQL
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── oauth-sso/             # OAuth SSO setup
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/               # Environment-specific configs
│   ├── prod/                  # Production environment
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars
│   └── stage/                 # Staging environment
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars
└── backend/                   # Remote state management
    └── main.tf
```

## 🚀 Quick Start

### Prerequisites

1. **Google Cloud CLI**: Install and configure the [gcloud CLI](https://cloud.google.com/sdk/docs/install)
2. **Terraform**: Install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) (version >= 1.0)
3. **GCP Project**: Create a GCP project with billing enabled
4. **Service Account**: Create a service account with necessary permissions (see [Permissions](#permissions))

### Initial Setup

1. **Clone and navigate to the terraform directory**:
   ```bash
   cd terraform
   ```

2. **Set up remote state backend** (run this only once):
   ```bash
   cd backend
   # Edit main.tf to set your project_id
   terraform init
   terraform apply
   cd ..
   ```

3. **Configure environment variables**:
   ```bash
   export GOOGLE_PROJECT="your-gcp-project-id"
   export GOOGLE_REGION="us-central1"
   ```

### Deploying an Environment

#### Staging Environment

1. **Navigate to staging environment**:
   ```bash
   cd environments/stage
   ```

2. **Copy and customize variables**:
   ```bash
   cp terraform.tfvars terraform.tfvars.local
   # Edit terraform.tfvars.local with your specific values
   ```

3. **Initialize and deploy**:
   ```bash
   terraform init
   terraform plan -var-file="terraform.tfvars.local"
   terraform apply -var-file="terraform.tfvars.local"
   ```

#### Production Environment

1. **Navigate to production environment**:
   ```bash
   cd environments/prod
   ```

2. **Copy and customize variables**:
   ```bash
   cp terraform.tfvars terraform.tfvars.local
   # Edit terraform.tfvars.local with your specific values
   ```

3. **Initialize and deploy**:
   ```bash
   terraform init
   terraform plan -var-file="terraform.tfvars.local"
   terraform apply -var-file="terraform.tfvars.local"
   ```

## 🔐 Permissions

The service account used for Terraform needs the following IAM roles:

```bash
# Core infrastructure roles
gcloud projects add-iam-policy-binding $GOOGLE_PROJECT \
  --member="serviceAccount:terraform@$GOOGLE_PROJECT.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $GOOGLE_PROJECT \
  --member="serviceAccount:terraform@$GOOGLE_PROJECT.iam.gserviceaccount.com" \
  --role="roles/container.admin"

gcloud projects add-iam-policy-binding $GOOGLE_PROJECT \
  --member="serviceAccount:terraform@$GOOGLE_PROJECT.iam.gserviceaccount.com" \
  --role="roles/cloudsql.admin"

gcloud projects add-iam-policy-binding $GOOGLE_PROJECT \
  --member="serviceAccount:terraform@$GOOGLE_PROJECT.iam.gserviceaccount.com" \
  --role="roles/secretmanager.admin"

gcloud projects add-iam-policy-binding $GOOGLE_PROJECT \
  --member="serviceAccount:terraform@$GOOGLE_PROJECT.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding $GOOGLE_PROJECT \
  --member="serviceAccount:terraform@$GOOGLE_PROJECT.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.projectIamAdmin"

gcloud projects add-iam-policy-binding $GOOGLE_PROJECT \
  --member="serviceAccount:terraform@$GOOGLE_PROJECT.iam.gserviceaccount.com" \
  --role="roles/storage.admin"
```

## 🏗️ Module Documentation

### VPC Module (`modules/vpc`)

Creates a VPC with public and private subnets, including:
- VPC network with custom subnets
- Cloud NAT for private subnet internet access
- Firewall rules for GKE and database access
- Secondary IP ranges for GKE pods and services

**Key Variables**:
- `public_subnet_cidr`: CIDR for public subnet (default: 10.0.1.0/24)
- `private_subnet_cidr`: CIDR for private subnet (default: 10.0.2.0/24)
- `pods_cidr_range`: CIDR for GKE pods (default: 10.1.0.0/16)
- `services_cidr_range`: CIDR for GKE services (default: 10.2.0.0/16)

### Kubernetes Module (`modules/kubernetes`)

Creates a GKE cluster with:
- Private cluster configuration
- Workload Identity enabled
- Autoscaling node pools
- Network policies
- Service account with minimal permissions

**Key Variables**:
- `node_machine_type`: GKE node machine type (default: e2-medium)
- `min_node_count`/`max_node_count`: Node pool scaling limits
- `use_preemptible_nodes`: Use preemptible instances for cost savings

### PostgreSQL Module (`modules/postgresql`)

Creates Cloud SQL PostgreSQL instances with:
- Private IP configuration
- Automated backups
- High availability options
- Secret Manager integration for credentials

**Key Variables**:
- `instance_tier`: Database instance size (default: db-f1-micro)
- `availability_type`: ZONAL or REGIONAL
- `deletion_protection`: Prevent accidental deletion

### OAuth SSO Module (`modules/oauth-sso`)

Sets up OAuth and SSO with:
- Google Cloud Identity integration
- Identity-Aware Proxy (IAP) configuration
- Workload Identity for Kubernetes
- Secret Manager for OAuth credentials

**Key Variables**:
- `support_email`: Email for OAuth brand configuration
- `enable_iap`: Enable Identity-Aware Proxy
- `iap_users`: List of users/groups for IAP access

## 🌍 Environment Differences

### Production Environment
- **High Availability**: Regional database, multiple node zones
- **Performance**: Larger instance types, SSD storage
- **Security**: IAP enabled, deletion protection on
- **Monitoring**: Enhanced logging and monitoring

### Staging Environment
- **Cost Optimized**: Smaller instances, preemptible nodes
- **Development Focused**: Easier access, reduced restrictions
- **Quick Iteration**: Faster deployments, minimal backups

## 🔒 Security Best Practices

1. **Network Security**:
   - Private GKE clusters with authorized networks
   - Private IP for database instances
   - Firewall rules with minimal required access

2. **Identity & Access**:
   - Workload Identity for pod-to-service authentication
   - Service accounts with least privilege
   - IAP for administrative access

3. **Secret Management**:
   - All secrets stored in Google Secret Manager
   - Automatic secret rotation where possible
   - No hardcoded credentials in code

4. **Backup & Recovery**:
   - Automated database backups
   - Point-in-time recovery enabled
   - State file backup in GCS

## 🚨 Troubleshooting

### Common Issues

1. **API Not Enabled**:
   ```bash
   # Enable required APIs
   gcloud services enable compute.googleapis.com
   gcloud services enable container.googleapis.com
   gcloud services enable sqladmin.googleapis.com
   ```

2. **Insufficient Permissions**:
   ```bash
   # Check current permissions
   gcloud projects get-iam-policy $GOOGLE_PROJECT
   ```

3. **State Lock Issues**:
   ```bash
   # Force unlock if needed (use carefully)
   terraform force-unlock LOCK_ID
   ```

4. **Resource Quotas**:
   ```bash
   # Check quotas
   gcloud compute project-info describe --project=$GOOGLE_PROJECT
   ```

### Debugging Commands

```bash
# Terraform debugging
export TF_LOG=DEBUG

# GCP debugging
gcloud config set core/verbosity debug

# Check resource status
terraform state list
terraform state show <resource_name>
```

## 🔄 Maintenance

### Updating Infrastructure

1. **Plan before applying**:
   ```bash
   terraform plan -var-file="terraform.tfvars.local"
   ```

2. **Apply with approval**:
   ```bash
   terraform apply -var-file="terraform.tfvars.local"
   ```

3. **Backup state before major changes**:
   ```bash
   terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate
   ```

### Destroying Infrastructure

⚠️ **Warning**: This will destroy all resources. Use with extreme caution.

```bash
terraform destroy -var-file="terraform.tfvars.local"
```

## 📞 Support

For infrastructure issues:
1. Check the troubleshooting section above
2. Review Terraform logs with debug enabled
3. Check GCP Console for resource status
4. Contact the infrastructure team

## 🤝 Contributing

1. Always test changes in staging first
2. Use `terraform fmt` and `terraform validate`
3. Document any new variables or outputs
4. Follow the existing module structure
5. Update this README for any architectural changes

## 📝 License

This infrastructure code is part of the Bro AI project. See the main project LICENSE file for details. 