# Bro AI Infrastructure

This repository contains the complete infrastructure setup for the Bro AI project, built on Google Cloud Platform using Terraform for Infrastructure as Code.

## 🏗️ Overview

The Bro AI infrastructure provides a scalable, secure, and cost-effective cloud platform for deploying and managing AI-powered applications. It includes:

- **Multi-environment support** (Production & Staging)
- **Google Kubernetes Engine (GKE)** for container orchestration
- **Cloud SQL PostgreSQL** for data storage
- **OAuth SSO** with Google Cloud Identity
- **Comprehensive security** with defense-in-depth approach
- **Automated scaling** and cost optimization
- **Infrastructure as Code** with Terraform

## 📁 Repository Structure

```
bro-ai-infra/
├── terraform/                 # Complete Terraform infrastructure
│   ├── modules/              # Reusable infrastructure modules
│   ├── environments/         # Environment-specific configurations
│   ├── backend/              # Remote state management
│   ├── setup.sh             # Interactive setup script
│   ├── Makefile             # Convenient operation commands
│   └── README.md            # Detailed Terraform documentation
├── ProjectStack.md           # Complete technology stack overview
├── ProjectSpec.md            # Technical specifications and requirements
└── README.md                # This file
```

## 🚀 Quick Start

### Prerequisites

1. [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) installed and configured
2. [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) (version >= 1.0)
3. GCP project with billing enabled
4. Appropriate IAM permissions (see [terraform/README.md](terraform/README.md#permissions))

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd bro-ai-infra
   ```

2. **Navigate to terraform directory**:
   ```bash
   cd terraform
   ```

3. **Run the interactive setup**:
   ```bash
   ./setup.sh
   ```

4. **Or use make commands**:
   ```bash
   make setup          # Interactive setup
   make init ENV=stage # Initialize staging environment
   make plan ENV=stage # Plan staging deployment
   make apply ENV=stage # Deploy staging environment
   ```

For detailed instructions, see [terraform/README.md](terraform/README.md).

## 🏛️ Architecture

The infrastructure follows a modular, cloud-native architecture:

### Core Components

- **VPC & Networking**: Isolated network with public/private subnets
- **GKE Clusters**: Auto-scaling Kubernetes clusters with private nodes
- **Cloud SQL**: Managed PostgreSQL with automated backups
- **OAuth SSO**: Centralized authentication and authorization
- **Secret Manager**: Secure credential storage and management

### Environment Differences

| Component | Production | Staging |
|-----------|------------|---------|
| **GKE Nodes** | e2-standard-2, SSD, non-preemptible | e2-medium, SSD, preemptible |
| **Database** | Regional, SSD, 30-day backups | Zonal, HDD, 7-day backups |
| **Security** | IAP enabled, deletion protection | Basic security, no deletion protection |
| **Cost** | Performance optimized | Cost optimized |

## 🔒 Security Features

- **Network Security**: Private clusters, firewall rules, Cloud NAT
- **Identity Management**: OAuth 2.0, IAP, Workload Identity
- **Data Protection**: Encryption at rest and in transit
- **Secret Management**: Google Secret Manager integration
- **Access Control**: Role-based permissions with least privilege

## 📊 Monitoring & Observability

- **Infrastructure Monitoring**: Google Cloud Monitoring
- **Application Metrics**: Container and pod-level monitoring
- **Logging**: Centralized logging with Cloud Logging
- **Alerting**: Multi-channel notifications and escalation
- **Security Monitoring**: Audit logs and security events

## 💰 Cost Management

- **Auto-scaling**: Dynamic resource allocation
- **Environment-specific sizing**: Appropriate resources per environment
- **Preemptible instances**: Cost savings for non-critical workloads
- **Budget monitoring**: Automated cost tracking and alerts

## 📚 Documentation

- **[terraform/README.md](terraform/README.md)**: Complete Terraform documentation
- **[terraform/documentation.md](terraform/documentation.md)**: Infrastructure implementation overview
- **[ProjectStack.md](ProjectStack.md)**: Complete technology stack
- **[ProjectSpec.md](ProjectSpec.md)**: Technical specifications and requirements
- **[terraform/INFRASTRUCTURE.md](terraform/INFRASTRUCTURE.md)**: Detailed architecture overview

## 🛠️ Available Commands

From the `terraform/` directory:

```bash
# Setup and initialization
make setup                    # Interactive setup
make init ENV=stage          # Initialize environment
make init-backend            # Initialize remote state backend

# Deployment
make plan ENV=stage          # Plan infrastructure changes
make apply ENV=stage         # Apply infrastructure changes
make deploy-stage            # Quick staging deployment
make deploy-prod             # Quick production deployment

# Management
make output ENV=stage        # Show environment outputs
make state-list ENV=stage    # List resources in state
make state-backup ENV=stage  # Backup current state

# Maintenance
make fmt                     # Format Terraform code
make validate ENV=stage      # Validate configuration
make clean                   # Clean temporary files
```

## 🔄 Development Workflow

1. **Make changes** to Terraform configurations
2. **Test in staging**: `make deploy-stage`
3. **Validate changes**: Review outputs and test functionality
4. **Deploy to production**: `make deploy-prod` (with approval)
5. **Monitor**: Check metrics and logs in GCP Console

## 🤝 Contributing

1. Create feature branch from `main`
2. Make infrastructure changes in staging first
3. Test thoroughly in staging environment
4. Submit PR with detailed description
5. Get approval before merging
6. Deploy to production after merge

## 📞 Support

For infrastructure issues:
1. Check the troubleshooting section in [terraform/README.md](terraform/README.md#troubleshooting)
2. Review Terraform logs and GCP Console
3. Check existing documentation and specifications
4. Contact the infrastructure team

## 📄 License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

---

**Note**: This infrastructure is designed for the Bro AI project and follows cloud-native best practices for scalability, security, and operational excellence.