# ============================================================
# IAM Role & Permissions
# Purpose: Create dedicated role with minimal permissions
# Security: Uses AssumeRole instead of static access keys
# ============================================================

########
# ROLE #
########

resource "aws_iam_role" "project_role" {
  name = "${var.project_name}-terraform-role"
  path = "/projects/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = data.aws_caller_identity.current.arn
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "sts:ExternalId" = var.project_name
        }
      }
    }]
  })

  tags = {
    Project   = var.project_name
    Purpose   = "Terraform and deployment automation"
    ManagedBy = "terraform"
  }
}

############
# Policies #
############

# S3 - Terraform state backend access
resource "aws_iam_role_policy" "s3_policy" {
  name = "S3StateManagement"
  role = aws_iam_role.project_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3StateBackend"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-*",
          "arn:aws:s3:::${var.project_name}-*/*"
        ]
      }
    ]
  })
}

# DynamoDB - Terraform state locking
resource "aws_iam_role_policy" "dynamodb_policy" {
  name = "DynamoDBStateLocking"
  role = aws_iam_role.project_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBStateLocking"
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/${var.project_name}-*"
      }
    ]
  })
}

# ECR - Container registry management
resource "aws_iam_role_policy_attachment" "ecr_full_access" {
  role       = aws_iam_role.project_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# EC2 Full Access - Covers VPC, Security Groups, EC2 Instances, and all networking
resource "aws_iam_role_policy_attachment" "ec2_full_access" {
  role       = aws_iam_role.project_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# EKS - Cluster management
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.project_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Auto Scaling - For EKS node groups
resource "aws_iam_role_policy_attachment" "autoscaling_full_access" {
  role       = aws_iam_role.project_role.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

# Load Balancing - For ALB/NLB ingress controllers
resource "aws_iam_role_policy_attachment" "elb_full_access" {
  role       = aws_iam_role.project_role.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

# IAM - Limited IAM role management (for EC2/EKS instance profiles, service accounts, OIDC providers)
# Custom policy because IAMFullAccess is too broad
resource "aws_iam_role_policy" "iam_role_policy" {
  name = "IAMRoleManagement"
  role = aws_iam_role.project_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "IAMRoleManagement"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:ListRoles",
          "iam:UpdateRole",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:GetRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:ListInstanceProfiles",
          "iam:TagInstanceProfile",
          "iam:UntagInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:PassRole",
          "iam:CreateOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders",
          "iam:CreateServiceLinkedRole"
        ]
        Resource = [
          "arn:aws:iam::*:role/${var.project_name}-*",
          "arn:aws:iam::*:instance-profile/${var.project_name}-*",
          "arn:aws:iam::*:oidc-provider/*"
        ]
      }
    ]
  })
}
