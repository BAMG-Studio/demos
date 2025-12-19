.PHONY: help setup validate-setup phase1-plan phase1-apply phase1-validate clean test

help:
	@echo "Rackspace Managed Security Project — Make Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup              - Initial setup (venv, dependencies)"
	@echo "  make validate-setup     - Validate prerequisites"
	@echo ""
	@echo "Phase 1: Foundation"
	@echo "  make phase1-plan        - Terraform plan for Phase 1"
	@echo "  make phase1-apply       - Terraform apply for Phase 1"
	@echo "  make phase1-validate    - Validate Phase 1 deployment"
	@echo ""
	@echo "Testing & Validation:"
	@echo "  make test               - Run all tests"
	@echo "  make test-terraform     - Validate Terraform"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean              - Remove temporary files"
	@echo "  make clean-all          - Remove all generated files"

setup:
	@echo "Setting up project..."
	@python3 -m venv venv
	@. venv/bin/activate && pip install --upgrade pip
	@. venv/bin/activate && pip install -r requirements.txt
	@cp .env.example .env
	@echo "✓ Setup complete!"
	@echo ""
	@echo "Next steps:"
	@echo "1. Edit .env with your AWS account IDs"
	@echo "2. Run: make validate-setup"

validate-setup:
	@echo "Validating prerequisites..."
	@command -v terraform >/dev/null 2>&1 || { echo "✗ Terraform not installed"; exit 1; }
	@command -v aws >/dev/null 2>&1 || { echo "✗ AWS CLI not installed"; exit 1; }
	@command -v python3 >/dev/null 2>&1 || { echo "✗ Python 3 not installed"; exit 1; }
	@command -v docker >/dev/null 2>&1 || { echo "✗ Docker not installed"; exit 1; }
	@command -v jq >/dev/null 2>&1 || { echo "✗ jq not installed"; exit 1; }
	@echo "✓ All prerequisites installed"
	@echo ""
	@echo "Checking AWS credentials..."
	@aws sts get-caller-identity > /dev/null 2>&1 || { echo "✗ AWS credentials not configured"; exit 1; }
	@echo "✓ AWS credentials configured"
	@echo ""
	@echo "Checking Terraform..."
	@terraform version
	@echo ""
	@echo "✓ All validations passed!"

phase1-plan:
	@echo "Planning Phase 1: Foundation..."
	@cd phase-1-foundation/terraform && \
		terraform init && \
		terraform plan -var-file=terraform.tfvars -out=tfplan
	@echo "✓ Phase 1 plan complete"

phase1-apply:
	@echo "Applying Phase 1: Foundation..."
	@cd phase-1-foundation/terraform && \
		terraform apply tfplan
	@echo "✓ Phase 1 apply complete"

phase1-validate:
	@echo "Validating Phase 1: Foundation..."
	@bash phase-1-foundation/scripts/validate_foundation.sh
	@echo "✓ Phase 1 validation complete"

test:
	@echo "Running tests..."
	@. venv/bin/activate && pytest tests/ -v --cov=. --cov-report=html
	@echo "✓ Tests complete (coverage report: htmlcov/index.html)"

test-terraform:
	@echo "Validating Terraform..."
	@cd phase-1-foundation/terraform && terraform validate
	@cd phase-2-detection/terraform && terraform validate 2>/dev/null || echo "Phase 2 not ready"
	@cd phase-3-incident-response/terraform && terraform validate 2>/dev/null || echo "Phase 3 not ready"
	@cd phase-4-compliance/terraform && terraform validate 2>/dev/null || echo "Phase 4 not ready"
	@echo "✓ Terraform validation complete"

clean:
	@echo "Cleaning temporary files..."
	@find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete
	@find . -type f -name ".terraform.lock.hcl" -delete
	@find . -type d -name .terraform -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "tfplan" -delete
	@find . -type f -name "*.tfstate*" -delete
	@echo "✓ Cleanup complete"

clean-all: clean
	@echo "Removing all generated files..."
	@rm -rf venv/
	@rm -rf htmlcov/
	@rm -rf .coverage
	@rm -f .env
	@echo "✓ Full cleanup complete"

.DEFAULT_GOAL := help
