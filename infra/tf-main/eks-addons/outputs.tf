output "ebs_csi_driver_role_arn" {
  description = "ARN of the IAM role used by EBS CSI driver"
  value       = module.ebs_csi_driver_irsa.iam_role_arn
}

output "ebs_csi_driver_addon_version" {
  description = "Version of the EBS CSI driver addon installed"
  value       = aws_eks_addon.ebs_csi_driver.addon_version
}

output "ebs_csi_driver_addon_arn" {
  description = "ARN of the EBS CSI driver addon"
  value       = aws_eks_addon.ebs_csi_driver.arn
}

output "external_secrets_role_arn" {
  description = "ARN of the IAM role used by External Secrets Operator"
  value       = module.external_secrets_irsa.iam_role_arn
}
