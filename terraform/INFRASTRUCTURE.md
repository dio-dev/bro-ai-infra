# Infrastructure Overview

This document provides a technical overview of the Terraform infrastructure for the Bro AI project.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        Google Cloud Project                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────┐    ┌─────────────────────────────────┐  │
│  │       VPC           │    │          IAM & Security        │  │
│  │ ┌─────────────────┐ │    │ ┌─────────────────────────────┐ │  │
│  │ │ Public Subnet   │ │    │ │ OAuth Brand & Clients       │ │  │
│  │ │ - GKE Nodes     │ │    │ │ - IAP Configuration         │ │  │
│  │ │ - Load Balancer │ │    │ │ - Service Accounts          │ │  │
│  │ └─────────────────┘ │    │ │ - Workload Identity         │ │  │
│  │                     │    │ └─────────────────────────────┘ │  │
│  │ ┌─────────────────┐ │    └─────────────────────────────────┘  │
│  │ │ Private Subnet  │ │                                         │
│  │ │ - Cloud SQL     │ │    ┌─────────────────────────────────┐  │
│  │ │ - Internal Svcs │ │    │      GKE Cluster                │  │
│  │ └─────────────────┘ │    │ ┌─────────────────────────────┐ │  │
│  │                     │    │ │ Node Pool (Auto-scaling)    │ │  │
│  │ ┌─────────────────┐ │    │ │ - Application Pods          │ │  │
│  │ │ Cloud NAT       │ │    │ │ - System Pods               │ │  │
│  │ │ - Outbound      │ │    │ └─────────────────────────────┘ │  │
│  │ │   Internet      │ │    └─────────────────────────────────┘  │
│  │ └─────────────────┘ │                                         │
│  └─────────────────────┘    ┌─────────────────────────────────┐  │
│                             │      Cloud SQL PostgreSQL      │  │
│  ┌─────────────────────┐    │ ┌─────────────────────────────┐ │  │
│  │ Secret Manager      │    │ │ Primary Database Instance   │ │  │
│  │ - DB Passwords      │    │ │ - Private IP Only           │ │  │
│  │ - OAuth Secrets     │    │ │ - Automated Backups         │ │  │
│  │ - API Keys          │    │ │ - Point-in-time Recovery    │ │  │
│  │ - Certificates      │    │ └─────────────────────────────┘ │  │
│  └─────────────────────┘    └─────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. VPC & Networking

**Purpose**: Provides isolated network infrastructure with proper security boundaries.

**Components**:
- **VPC Network**: Custom VPC with regional routing
- **Public Subnet** (10.0.1.0/24): Hosts GKE nodes with external connectivity
- **Private Subnet** (10.0.2.0/24): Hosts databases and internal services
- **Secondary IP Ranges**: 
  - Pods: 10.1.0.0/16 (65,536 IPs)
  - Services: 10.2.0.0/16 (65,536 IPs)
- **Cloud NAT**: Provides outbound internet access for private resources
- **Firewall Rules**: Minimal required access for GKE and database communication

**Security Features**:
- Private subnet with no direct internet access
- Firewall rules with specific port and source restrictions
- Cloud NAT for secure outbound connectivity

### 2. Google Kubernetes Engine (GKE)

**Purpose**: Managed Kubernetes cluster for application workloads.

**Configuration**:
- **Cluster Type**: Regional private cluster
- **Network Policy**: Enabled for pod-to-pod traffic control
- **Workload Identity**: Enabled for secure pod-to-GCP service authentication
- **Node Pools**: Auto-scaling with configurable min/max nodes
- **Master Authorized Networks**: Configurable for admin access

**Features**:
- **Auto-scaling**: Both cluster and node pool level
- **Auto-upgrade**: Managed by Google with maintenance windows
- **Private Nodes**: Nodes have no external IP addresses
- **Shielded Nodes**: Enhanced security with integrity monitoring

**Production vs Staging Differences**:
- **Production**: e2-standard-2 instances, no preemptible nodes, STABLE channel
- **Staging**: e2-medium instances, preemptible nodes, REGULAR channel

### 3. Cloud SQL PostgreSQL

**Purpose**: Managed PostgreSQL database with high availability and security.

**Configuration**:
- **Engine**: PostgreSQL 15
- **Network**: Private IP only, no public access
- **High Availability**: Regional (prod) vs Zonal (staging)
- **Backups**: Automated daily backups with point-in-time recovery
- **Encryption**: Encryption at rest and in transit

**Features**:
- **Private Service Connect**: Database accessible only from VPC
- **Automated Maintenance**: Managed by Google with configurable windows
- **Read Replicas**: Can be configured for read scaling
- **Connection Pooling**: Configurable via database flags

**Production vs Staging Differences**:
- **Production**: db-custom-2-4096, REGIONAL, SSD storage, 30-day backups
- **Staging**: db-f1-micro, ZONAL, HDD storage, 7-day backups

### 4. OAuth SSO & Identity

**Purpose**: Centralized authentication and authorization.

**Components**:
- **OAuth Brand**: Application identity for OAuth flows
- **OAuth Clients**: Client credentials for different services
- **Identity-Aware Proxy (IAP)**: Google-managed authentication proxy
- **Workload Identity**: Secure authentication for Kubernetes pods

**Security Features**:
- **Zero-trust Access**: IAP provides application-level security
- **Service Account Keys**: No long-lived service account keys
- **Workload Identity**: Pods authenticate as Google service accounts
- **Secret Manager Integration**: Secure storage of OAuth credentials

### 5. Secret Management

**Purpose**: Secure storage and access of sensitive configuration.

**Stored Secrets**:
- Database passwords
- OAuth client credentials
- API keys and tokens
- TLS certificates
- Application-specific secrets

**Features**:
- **Automatic Replication**: Regional replication for availability
- **Access Control**: IAM-based access with least privilege
- **Audit Logging**: All access is logged for compliance
- **Versioning**: Automatic versioning of secret updates

## Environment Configurations

### Production Environment

```yaml
Characteristics:
  - High Availability: Regional database, multi-zone GKE
  - Performance: Larger instances, SSD storage
  - Security: IAP enabled, deletion protection
  - Monitoring: Enhanced logging and alerting
  - Backup: 30-day retention, point-in-time recovery

Network CIDR Blocks:
  - VPC: 10.0.0.0/16
  - Public Subnet: 10.0.1.0/24
  - Private Subnet: 10.0.2.0/24
  - Pods: 10.1.0.0/16
  - Services: 10.2.0.0/16

Resources:
  - GKE: 2-10 nodes, e2-standard-2
  - Database: db-custom-2-4096, REGIONAL
  - Storage: SSD for all components
```

### Staging Environment

```yaml
Characteristics:
  - Cost Optimized: Smaller instances, preemptible nodes
  - Development Focused: Faster iteration, easier access
  - Testing: Less restrictive policies for debugging
  - Backup: 7-day retention, basic recovery

Network CIDR Blocks:
  - VPC: 10.10.0.0/16
  - Public Subnet: 10.10.1.0/24
  - Private Subnet: 10.10.2.0/24
  - Pods: 10.11.0.0/16
  - Services: 10.12.0.0/16

Resources:
  - GKE: 1-5 nodes, e2-medium, preemptible
  - Database: db-f1-micro, ZONAL
  - Storage: HDD for cost savings
```

## Security Architecture

### Network Security

1. **Defense in Depth**:
   - VPC isolation
   - Private subnets for sensitive resources
   - Firewall rules with minimal required access
   - Private GKE clusters

2. **Access Control**:
   - No direct database access from internet
   - GKE master endpoint access controlled
   - Cloud NAT for outbound-only connectivity

### Identity & Access Management

1. **Service Accounts**:
   - Minimal required permissions
   - Workload Identity for pod authentication
   - No long-lived service account keys

2. **Human Access**:
   - IAP for administrative access
   - OAuth-based authentication
   - Group-based access control

### Data Protection

1. **Encryption**:
   - Encryption at rest for all data
   - Encryption in transit (TLS)
   - Customer-managed encryption keys (optional)

2. **Backup & Recovery**:
   - Automated database backups
   - Point-in-time recovery capability
   - Geographic backup distribution

## Monitoring & Observability

### Built-in Monitoring

1. **GKE Monitoring**:
   - Container-level metrics
   - Application performance monitoring
   - Resource utilization tracking

2. **Database Monitoring**:
   - Query performance insights
   - Connection monitoring
   - Backup status tracking

3. **Network Monitoring**:
   - VPC flow logs
   - Firewall rule logging
   - NAT gateway metrics

### Alerting

1. **Infrastructure Alerts**:
   - Resource quota violations
   - Service availability issues
   - Security policy violations

2. **Application Alerts**:
   - High error rates
   - Performance degradation
   - Dependency failures

## Disaster Recovery

### Backup Strategy

1. **Database Backups**:
   - Daily automated backups
   - Point-in-time recovery
   - Cross-region backup replication (optional)

2. **Configuration Backups**:
   - Terraform state files in GCS
   - Infrastructure as Code versioning
   - Secret backup procedures

### Recovery Procedures

1. **Database Recovery**:
   - Point-in-time restoration
   - Cross-region failover (for regional instances)
   - Data validation procedures

2. **Infrastructure Recovery**:
   - Terraform state restoration
   - Re-deployment from code
   - Secret restoration from backups

## Cost Optimization

### Automatic Cost Controls

1. **Auto-scaling**:
   - GKE cluster autoscaling
   - Node pool autoscaling
   - Vertical pod autoscaling

2. **Resource Management**:
   - Preemptible instances in staging
   - Right-sized instance types
   - Storage class optimization

### Cost Monitoring

1. **Budget Alerts**:
   - Environment-specific budgets
   - Resource-based cost tracking
   - Anomaly detection

2. **Resource Optimization**:
   - Unused resource identification
   - Right-sizing recommendations
   - Reserved instance planning

## Compliance & Governance

### Security Compliance

1. **Data Governance**:
   - Data classification policies
   - Access audit trails
   - Encryption compliance

2. **Operational Security**:
   - Patch management
   - Vulnerability scanning
   - Security incident response

### Change Management

1. **Infrastructure Changes**:
   - Terraform-managed changes
   - Peer review requirements
   - Testing in staging first

2. **Access Management**:
   - Regular access reviews
   - Principle of least privilege
   - Automated provisioning/deprovisioning 