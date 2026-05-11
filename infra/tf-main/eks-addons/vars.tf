variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider for IRSA"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the EKS cluster"
  type        = string
  sensitive   = true
}

variable "ebs_csi_driver_version" {
  description = "Version of the EBS CSI driver addon to install"
  type        = string
  default     = null # Uses latest available version
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster is deployed"
  type        = string
}

variable "alb_controller_version" {
  description = "Version of the AWS Load Balancer Controller Helm chart"
  type        = string
  default     = "1.7.1"
}
