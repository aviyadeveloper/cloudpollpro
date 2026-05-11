# EBS CSI Driver - enables EKS to manage EBS volumes as PersistentVolumes
# Uses IRSA (IAM Roles for Service Accounts) for secure AWS API access

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# IAM role for EBS CSI driver controller
# This role allows the CSI driver pods to call AWS EBS APIs
module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.project_name}-ebs-csi-driver"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    Project = var.project_name
    Name    = "${var.project_name}-ebs-csi-driver"
  }
}

# Install EBS CSI driver as an EKS addon
# This is the recommended way (vs Helm) for EKS-managed updates
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = var.cluster_name
  addon_name   = "aws-ebs-csi-driver"

  # Use latest available version
  addon_version = var.ebs_csi_driver_version

  # Associate the IRSA role
  service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn

  # Don't fail if addon already exists (for updates)
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = {
    Project = var.project_name
    Name    = "${var.project_name}-ebs-csi-driver"
  }
}
