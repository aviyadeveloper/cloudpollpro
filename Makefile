.PHONY: infra-bootstrap

infra-bootstrap:
	@echo "Bootstrap Terraform configuration for CloudPollPro project"
	cd infra/tf-bootstrap && terraform init
	cd infra/tf-bootstrap && terraform apply

pre-commit:
	@echo "Running pre-commit checks for Terraform"
	./scripts/pre-commit.sh
