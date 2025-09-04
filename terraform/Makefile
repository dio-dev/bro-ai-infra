# Terraform Infrastructure Makefile
# Provides convenient commands for managing infrastructure

# Default environment
ENV ?= stage

# Default project and region (override with environment variables)
PROJECT ?= $(shell gcloud config get-value project 2>/dev/null)
REGION ?= us-central1

# Colors for output
YELLOW := \033[1;33m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m

# Help target
.PHONY: help
help: ## Show this help message
	@echo "Terraform Infrastructure Management"
	@echo "=================================="
	@echo ""
	@echo "Usage: make [target] [ENV=stage|prod]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Validation targets
.PHONY: check
check: ## Check prerequisites and configuration
	@echo "$(YELLOW)Checking prerequisites...$(NC)"
	@command -v terraform >/dev/null 2>&1 || { echo "$(RED)Terraform is not installed$(NC)"; exit 1; }
	@command -v gcloud >/dev/null 2>&1 || { echo "$(RED)gcloud CLI is not installed$(NC)"; exit 1; }
	@test -n "$(PROJECT)" || { echo "$(RED)No GCP project set$(NC)"; exit 1; }
	@echo "$(GREEN)Prerequisites check passed$(NC)"

.PHONY: validate
validate: check ## Validate Terraform configuration
	@echo "$(YELLOW)Validating $(ENV) environment...$(NC)"
	@cd environments/$(ENV) && terraform validate
	@echo "$(GREEN)Configuration is valid$(NC)"

# Setup targets
.PHONY: setup
setup: ## Run the interactive setup script
	@./setup.sh

.PHONY: init-backend
init-backend: check ## Initialize the backend
	@echo "$(YELLOW)Initializing backend...$(NC)"
	@cd backend && terraform init
	@cd backend && terraform apply -var="project_id=$(PROJECT)" -var="region=$(REGION)" -auto-approve
	@echo "$(GREEN)Backend initialized$(NC)"

.PHONY: init
init: check ## Initialize Terraform for an environment
	@echo "$(YELLOW)Initializing $(ENV) environment...$(NC)"
	@cd environments/$(ENV) && terraform init
	@echo "$(GREEN)$(ENV) environment initialized$(NC)"

# Environment management
.PHONY: plan
plan: validate ## Plan infrastructure changes
	@echo "$(YELLOW)Planning $(ENV) environment...$(NC)"
	@cd environments/$(ENV) && terraform plan -var-file="terraform.tfvars.local"

.PHONY: apply
apply: validate ## Apply infrastructure changes
	@echo "$(YELLOW)Applying $(ENV) environment...$(NC)"
	@cd environments/$(ENV) && terraform apply -var-file="terraform.tfvars.local"

.PHONY: destroy
destroy: check ## Destroy infrastructure (use with caution!)
	@echo "$(RED)WARNING: This will destroy all resources in $(ENV) environment!$(NC)"
	@read -p "Are you sure? Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ]
	@cd environments/$(ENV) && terraform destroy -var-file="terraform.tfvars.local"

.PHONY: output
output: check ## Show Terraform outputs
	@echo "$(YELLOW)Outputs for $(ENV) environment:$(NC)"
	@cd environments/$(ENV) && terraform output

# State management
.PHONY: state-list
state-list: check ## List resources in Terraform state
	@cd environments/$(ENV) && terraform state list

.PHONY: state-backup
state-backup: check ## Backup Terraform state
	@echo "$(YELLOW)Backing up $(ENV) state...$(NC)"
	@cd environments/$(ENV) && terraform state pull > "backup-$(ENV)-$(shell date +%Y%m%d-%H%M%S).tfstate"
	@echo "$(GREEN)State backed up$(NC)"

# Formatting and linting
.PHONY: fmt
fmt: ## Format Terraform code
	@echo "$(YELLOW)Formatting Terraform code...$(NC)"
	@terraform fmt -recursive .
	@echo "$(GREEN)Code formatted$(NC)"

.PHONY: security-scan
security-scan: ## Run security scan with tfsec (if installed)
	@echo "$(YELLOW)Running security scan...$(NC)"
	@if command -v tfsec >/dev/null 2>&1; then \
		tfsec .; \
	else \
		echo "$(YELLOW)tfsec not installed. Install it for security scanning: https://aquasecurity.github.io/tfsec/$(NC)"; \
	fi

# Utility targets
.PHONY: clean
clean: ## Clean temporary files
	@echo "$(YELLOW)Cleaning temporary files...$(NC)"
	@find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.tfstate*" -not -name "*backup*" -delete 2>/dev/null || true
	@find . -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@echo "$(GREEN)Cleanup complete$(NC)"

.PHONY: docs
docs: ## Generate documentation
	@echo "$(YELLOW)Generating documentation...$(NC)"
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table --output-file README.md modules/vpc; \
		terraform-docs markdown table --output-file README.md modules/kubernetes; \
		terraform-docs markdown table --output-file README.md modules/postgresql; \
		terraform-docs markdown table --output-file README.md modules/oauth-sso; \
		echo "$(GREEN)Documentation generated$(NC)"; \
	else \
		echo "$(YELLOW)terraform-docs not installed. Install it for automatic documentation: https://terraform-docs.io/$(NC)"; \
	fi

# Quick deployment targets
.PHONY: deploy-stage
deploy-stage: ## Quick deploy to staging
	@$(MAKE) init ENV=stage
	@$(MAKE) plan ENV=stage
	@$(MAKE) apply ENV=stage

.PHONY: deploy-prod
deploy-prod: ## Quick deploy to production (with confirmation)
	@echo "$(RED)WARNING: Deploying to production!$(NC)"
	@read -p "Are you sure? Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ]
	@$(MAKE) init ENV=prod
	@$(MAKE) plan ENV=prod
	@$(MAKE) apply ENV=prod

# Environment info
.PHONY: info
info: check ## Show current configuration info
	@echo "$(YELLOW)Current Configuration:$(NC)"
	@echo "Environment: $(ENV)"
	@echo "GCP Project: $(PROJECT)"
	@echo "GCP Region: $(REGION)"
	@echo "Terraform Version: $(shell terraform version | head -n1)"
	@echo "gcloud Version: $(shell gcloud version | head -n1)"

# Debug targets
.PHONY: debug-plan
debug-plan: validate ## Plan with debug output
	@echo "$(YELLOW)Planning $(ENV) environment with debug output...$(NC)"
	@cd environments/$(ENV) && TF_LOG=DEBUG terraform plan -var-file="terraform.tfvars.local"

.PHONY: debug-apply
debug-apply: validate ## Apply with debug output
	@echo "$(YELLOW)Applying $(ENV) environment with debug output...$(NC)"
	@cd environments/$(ENV) && TF_LOG=DEBUG terraform apply -var-file="terraform.tfvars.local"

# Refresh and import
.PHONY: refresh
refresh: check ## Refresh Terraform state
	@echo "$(YELLOW)Refreshing $(ENV) state...$(NC)"
	@cd environments/$(ENV) && terraform refresh -var-file="terraform.tfvars.local"

# Show current workspace
.PHONY: workspace
workspace: check ## Show current Terraform workspace
	@cd environments/$(ENV) && terraform workspace show 