# ============================================================
# GitHub Actions OIDC Integration
# Purpose: Allow GitHub Actions to assume AWS role for CI/CD
# Security: No long-lived credentials, scoped to specific repo
# ============================================================

# GitHub OIDC Provider
resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.github_repo_owner != "" && var.github_repo_name != "" ? 1 : 0

  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = {
    Project   = var.project_name
    Purpose   = "GitHub Actions OIDC"
    ManagedBy = "terraform"
  }
}

# IAM Role for GitHub Actions (Read-Only for Terraform Plan)
resource "aws_iam_role" "github_actions_role" {
  count = var.github_repo_owner != "" && var.github_repo_name != "" ? 1 : 0

  name = "${var.project_name}-github-actions-ro"
  path = "/ci/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions[0].arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo_owner}/${var.github_repo_name}:*"
          }
        }
      }
    ]
  })

  tags = {
    Project   = var.project_name
    Purpose   = "GitHub Actions CI read-only access"
    ManagedBy = "terraform"
  }
}

# Read-Only Policy for Terraform Plan
resource "aws_iam_role_policy" "github_actions_terraform_ro" {
  count = var.github_repo_owner != "" && var.github_repo_name != "" ? 1 : 0

  name = "TerraformReadOnly"
  role = aws_iam_role.github_actions_role[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "TerraformStateRead"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
      },
      {
        Sid    = "ReadProjectResources"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:Get*",
          "eks:Describe*",
          "eks:List*",
          "iam:Get*",
          "iam:List*",
          "autoscaling:Describe*",
          "elasticloadbalancing:Describe*"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:ResourceTag/Project" = "cloudpollpro*"
          }
        }
      },
      {
        Sid    = "DescribeAllForPlan"
        Effect = "Allow"
        Action = [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:ListPolicies",
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}
