variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "kubernetes_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster and node groups"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs (optional, for public node groups)"
  type        = list(string)
  default     = []
}

variable "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions to access EKS"
  type        = string
}
