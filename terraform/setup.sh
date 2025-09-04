#!/bin/bash

# Terraform Infrastructure Setup Script
# This script helps set up the Terraform infrastructure for Bro AI

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check for gcloud
    if ! command -v gcloud &> /dev/null; then
        print_error "gcloud CLI is not installed. Please install it first:"
        echo "https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    
    # Check for terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first:"
        echo "https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli"
        exit 1
    fi
    
    print_success "All prerequisites are installed"
}

# Get project configuration
get_project_config() {
    print_status "Getting project configuration..."
    
    # Get current project if not set
    if [ -z "$GOOGLE_PROJECT" ]; then
        GOOGLE_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "")
        if [ -z "$GOOGLE_PROJECT" ]; then
            print_error "No GCP project set. Please set one:"
            echo "gcloud config set project YOUR_PROJECT_ID"
            exit 1
        fi
    fi
    
    if [ -z "$GOOGLE_REGION" ]; then
        GOOGLE_REGION="us-central1"
    fi
    
    print_success "Using project: $GOOGLE_PROJECT in region: $GOOGLE_REGION"
}

# Enable required APIs
enable_apis() {
    print_status "Enabling required GCP APIs..."
    
    apis=(
        "compute.googleapis.com"
        "container.googleapis.com"
        "sqladmin.googleapis.com"
        "servicenetworking.googleapis.com"
        "secretmanager.googleapis.com"
        "iap.googleapis.com"
        "cloudresourcemanager.googleapis.com"
        "iam.googleapis.com"
        "serviceusage.googleapis.com"
    )
    
    for api in "${apis[@]}"; do
        print_status "Enabling $api..."
        gcloud services enable "$api" --project="$GOOGLE_PROJECT"
    done
    
    print_success "All APIs enabled"
}

# Setup backend
setup_backend() {
    print_status "Setting up Terraform backend..."
    
    cd backend
    
    # Update backend configuration with project ID
    sed -i.bak "s/YOUR_PROJECT_ID/$GOOGLE_PROJECT/g" main.tf
    
    # Initialize and apply backend
    terraform init
    terraform apply -var="project_id=$GOOGLE_PROJECT" -var="region=$GOOGLE_REGION" -auto-approve
    
    print_success "Backend setup complete"
    cd ..
}

# Setup environment
setup_environment() {
    local env=$1
    print_status "Setting up $env environment..."
    
    cd "environments/$env"
    
    # Update backend configuration
    sed -i.bak "s/YOUR_PROJECT_ID/$GOOGLE_PROJECT/g" main.tf
    
    # Copy and update terraform.tfvars
    if [ ! -f "terraform.tfvars.local" ]; then
        cp terraform.tfvars terraform.tfvars.local
        sed -i.bak "s/your-gcp-project-id/$GOOGLE_PROJECT/g" terraform.tfvars.local
        
        print_warning "Please edit terraform.tfvars.local in environments/$env/ with your specific values"
        print_warning "Especially update the support_email and other environment-specific settings"
    fi
    
    # Initialize terraform
    terraform init
    
    print_success "$env environment setup complete"
    cd ../..
}

# Validate configuration
validate_config() {
    print_status "Validating Terraform configuration..."
    
    for env in prod stage; do
        print_status "Validating $env environment..."
        cd "environments/$env"
        terraform validate
        cd ../..
    done
    
    print_success "All configurations are valid"
}

# Main setup function
main() {
    echo "🚀 Bro AI Terraform Infrastructure Setup"
    echo "========================================"
    
    check_prerequisites
    get_project_config
    
    read -p "Do you want to enable required GCP APIs? (y/N): " enable_apis_choice
    if [[ $enable_apis_choice =~ ^[Yy]$ ]]; then
        enable_apis
    fi
    
    read -p "Do you want to set up the Terraform backend? (y/N): " setup_backend_choice
    if [[ $setup_backend_choice =~ ^[Yy]$ ]]; then
        setup_backend
    fi
    
    read -p "Do you want to set up the staging environment? (y/N): " setup_stage_choice
    if [[ $setup_stage_choice =~ ^[Yy]$ ]]; then
        setup_environment "stage"
    fi
    
    read -p "Do you want to set up the production environment? (y/N): " setup_prod_choice
    if [[ $setup_prod_choice =~ ^[Yy]$ ]]; then
        setup_environment "prod"
    fi
    
    validate_config
    
    print_success "Setup complete! 🎉"
    echo ""
    echo "Next steps:"
    echo "1. Edit terraform.tfvars.local files in environments/stage/ and environments/prod/"
    echo "2. Run 'terraform plan' in your chosen environment"
    echo "3. Run 'terraform apply' to deploy infrastructure"
    echo ""
    echo "For more information, see the README.md file"
}

# Script help
show_help() {
    echo "Bro AI Terraform Setup Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -p, --project  Set GCP project ID"
    echo "  -r, --region   Set GCP region (default: us-central1)"
    echo ""
    echo "Environment variables:"
    echo "  GOOGLE_PROJECT  GCP project ID"
    echo "  GOOGLE_REGION   GCP region"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Interactive setup"
    echo "  $0 -p my-project-id                  # Set project ID"
    echo "  GOOGLE_PROJECT=my-project-id $0      # Use environment variable"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -p|--project)
            GOOGLE_PROJECT="$2"
            shift 2
            ;;
        -r|--region)
            GOOGLE_REGION="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
main 