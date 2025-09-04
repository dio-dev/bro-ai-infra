#!/bin/bash

# ArgoCD Installation Script for GKE
# This script installs ArgoCD on the GKE cluster with proper configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        exit 1
    fi
    
    if ! command -v gcloud &> /dev/null; then
        print_error "gcloud CLI is not installed"
        exit 1
    fi
    
    # Check if connected to the right cluster
    CURRENT_CONTEXT=$(kubectl config current-context)
    print_status "Current kubectl context: $CURRENT_CONTEXT"
    
    read -p "Continue with this cluster? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        print_error "Aborted by user"
        exit 1
    fi
}

# Install ArgoCD
install_argocd() {
    print_status "Installing ArgoCD..."
    
    # Create namespace
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    
    # Install ArgoCD
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    print_success "ArgoCD installed successfully"
}

# Apply custom configuration
apply_custom_config() {
    print_status "Applying custom ArgoCD configuration..."
    
    # Apply the custom setup from argocd/argocd-setup.yaml
    if [ -f "argocd/argocd-setup.yaml" ]; then
        # Replace placeholder values
        if [ -z "$PROJECT_ID" ]; then
            read -p "Enter your GCP Project ID: " PROJECT_ID
        fi
        
        if [ -z "$GITHUB_ORG" ]; then
            read -p "Enter your GitHub organization: " GITHUB_ORG
        fi
        
        if [ -z "$DOMAIN" ]; then
            read -p "Enter your domain (e.g., example.com): " DOMAIN
        fi
        
        # Create temporary file with substitutions
        TEMP_FILE=$(mktemp)
        sed -e "s/PROJECT_ID/$PROJECT_ID/g" \
            -e "s/YOUR_ORG/$GITHUB_ORG/g" \
            -e "s/YOUR_DOMAIN.com/$DOMAIN/g" \
            argocd/argocd-setup.yaml > "$TEMP_FILE"
        
        kubectl apply -f "$TEMP_FILE"
        rm "$TEMP_FILE"
        
        print_success "Custom configuration applied"
    else
        print_warning "Custom configuration file not found at argocd/argocd-setup.yaml"
    fi
}

# Wait for ArgoCD to be ready
wait_for_argocd() {
    print_status "Waiting for ArgoCD to be ready..."
    
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-application-controller -n argocd
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-dex-server -n argocd
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-redis -n argocd
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
    
    print_success "ArgoCD is ready"
}

# Get initial admin password
get_admin_password() {
    print_status "Getting ArgoCD admin password..."
    
    ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    
    echo ""
    echo "===================="
    echo "ArgoCD Admin Credentials:"
    echo "Username: admin"
    echo "Password: $ADMIN_PASSWORD"
    echo "===================="
    echo ""
    
    print_warning "Save this password! The secret will be deleted for security."
    
    # Delete the initial admin secret for security
    kubectl -n argocd delete secret argocd-initial-admin-secret
}

# Setup port forwarding
setup_port_forward() {
    read -p "Set up port forwarding to access ArgoCD? (y/N): " setup_forward
    if [[ $setup_forward =~ ^[Yy]$ ]]; then
        print_status "Setting up port forwarding..."
        print_status "Access ArgoCD at: http://localhost:8080"
        print_status "Use Ctrl+C to stop port forwarding"
        
        kubectl port-forward svc/argocd-server -n argocd 8080:443
    fi
}

# Install ArgoCD applications
install_applications() {
    print_status "Installing ArgoCD applications..."
    
    if [ -f "argocd/applications/bro-ai-staging.yaml" ]; then
        kubectl apply -f argocd/applications/bro-ai-staging.yaml
        print_success "Staging application installed"
    fi
    
    if [ -f "argocd/applications/bro-ai-production.yaml" ]; then
        kubectl apply -f argocd/applications/bro-ai-production.yaml
        print_success "Production application installed"
    fi
}

# Create GCP resources
create_gcp_resources() {
    read -p "Create GCP resources (static IP, SSL certificate)? (y/N): " create_resources
    if [[ $create_resources =~ ^[Yy]$ ]]; then
        print_status "Creating GCP resources..."
        
        # Create static IP
        gcloud compute addresses create argocd-ip --global
        
        # The SSL certificate will be created automatically by the ManagedCertificate
        print_success "GCP resources created"
    fi
}

# Main installation process
main() {
    echo "🚀 ArgoCD Installation for Bro AI Infrastructure"
    echo "================================================"
    
    check_prerequisites
    install_argocd
    wait_for_argocd
    get_admin_password
    apply_custom_config
    install_applications
    create_gcp_resources
    setup_port_forward
    
    print_success "ArgoCD installation completed! 🎉"
    echo ""
    echo "Next steps:"
    echo "1. Configure your GitHub repository secrets"
    echo "2. Update DNS records to point to the ArgoCD ingress"
    echo "3. Configure OAuth for Google authentication"
    echo "4. Test the deployment pipelines"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --project-id)
            PROJECT_ID="$2"
            shift 2
            ;;
        --github-org)
            GITHUB_ORG="$2"
            shift 2
            ;;
        --domain)
            DOMAIN="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --project-id ID    GCP project ID"
            echo "  --github-org ORG   GitHub organization"
            echo "  --domain DOMAIN    Your domain name"
            echo "  --help             Show this help"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Run main function
main 