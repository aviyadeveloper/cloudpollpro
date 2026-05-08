output "repository_urls" {
  description = "Map of repository names to their URLs"
  value = {
    for k, repo in aws_ecr_repository.this : k => repo.repository_url
  }
}

output "repository_arns" {
  description = "Map of repository names to their ARNs"
  value = {
    for k, repo in aws_ecr_repository.this : k => repo.arn
  }
}

output "registry_id" {
  description = "The registry ID where the repositories were created"
  value       = values(aws_ecr_repository.this)[0].registry_id
}
