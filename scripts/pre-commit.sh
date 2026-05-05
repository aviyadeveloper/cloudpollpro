#!/bin/bash
# Terraform validation and documentation script
# Run manually: ./scripts/pre-commit.sh
# Note: Not installed as git hook - run before committing or use CI/CD

set -e

echo "🔍 Running Terraform checks..."

# Change to project root
cd "$(git rev-parse --show-toplevel)"

# Format Terraform files
echo "📝 Formatting Terraform files..."
terraform -chdir=infra/tf-bootstrap fmt -recursive
terraform -chdir=infra/terraform fmt -recursive

# Generate module documentation if terraform-docs is installed
if command -v terraform-docs &> /dev/null; then
  echo "📚 Generating module documentation..."
  
  # Find all modules with .terraform-docs.yml and generate docs
  find infra/terraform -type f -name ".terraform-docs.yml" | while read -r config_file; do
    module_dir=$(dirname "$config_file")
    module_name=$(basename "$module_dir")
    terraform-docs "$module_dir"
    echo "  ✓ Updated $module_name/README.md"
  done
else
  echo "ℹ️  terraform-docs not installed, skipping documentation generation"
  echo "   Install: https://terraform-docs.io/user-guide/installation/"
fi

# Validate Terraform if initialized
if [ -d "infra/terraform/.terraform" ]; then
  echo "✅ Validating Terraform configuration..."
  terraform -chdir=infra/terraform validate
fi

echo "✨ All checks passed!"
