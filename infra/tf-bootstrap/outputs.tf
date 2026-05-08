# ============================================================
# Essential Outputs Only
# ============================================================

output "role_arn" {
  description = "ARN of the IAM role to assume for Terraform operations"
  value       = aws_iam_role.project_role.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.project_role.name
}

output "external_id" {
  description = "External ID required to assume the role"
  value       = var.project_name
  sensitive   = true
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role for CI/CD"
  value       = var.github_repo_owner != "" && var.github_repo_name != "" ? aws_iam_role.github_actions_role[0].arn : "Not configured - set github_repo_owner and github_repo_name variables"
}
