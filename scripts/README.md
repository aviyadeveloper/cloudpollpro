# Development Scripts

## pre-commit.sh

Manual validation script for Terraform - runs formatting, documentation, and validation checks.

### What it does:

1. **Formats** all Terraform files (`terraform fmt`)
2. **Generates** module documentation (if `terraform-docs` is installed)
3. **Validates** Terraform configuration

### Usage:

**Run manually before committing:**
```bash
./scripts/pre-commit.sh
```

**Quick workflow:**
```bash
# Make changes to .tf files
./scripts/pre-commit.sh  # Format, generate docs, validate
git add -A
git commit -m "your message"
```

### Why not a git hook?

- Git hooks can be fragile and annoying
- Different workflows (CLI vs VS Code) behave differently
- Better to run manually when you're ready
- Future: CI/CD will check and generate docs automatically

### Requirements:

- Terraform (required)
- terraform-docs (optional, for auto-generating README.md)

### Installing terraform-docs:

```bash
# Linux
curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs
sudo mv terraform-docs /usr/local/bin/
rm terraform-docs.tar.gz

# Verify
terraform-docs --version
```
