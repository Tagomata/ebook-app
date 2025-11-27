# Data source para obtener el account ID
data "aws_caller_identity" "current" {}

# ============================================================================
# OIDC PROVIDER - Conecta GitHub con AWS
# ============================================================================

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # Thumbprints de GitHub (estos son públicos y no cambian)
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}

# ============================================================================
# IAM ROLE - Role que asumirá GitHub Actions
# ============================================================================

# Trust policy: define QUIÉN puede asumir este role
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      # Permite cualquier rama/tag del repositorio
      values = ["repo:Tagomata/ebook-app:*"]
    }
  }
}

# Crear el IAM Role
resource "aws_iam_role" "github_actions" {
  name               = "github-actions-terraform-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  description = "Role para GitHub Actions ejecutar Terraform en Tagomata/ebook-app"

  tags = {
    Name       = "github-actions-terraform-role"
    Repository = "Tagomata/ebook-app"
  }
}

# ============================================================================
# IAM POLICY - Permisos que tendrá el role
# ============================================================================

# Política de permisos para Terraform
data "aws_iam_policy_document" "terraform_permissions" {
  # Permisos para S3 backend
  statement {
    sid = "TerraformStateS3"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::tfstate-ebook-app",
      "arn:aws:s3:::tfstate-ebook-app/*"
    ]
  }

  # Permisos para DynamoDB locking
  statement {
    sid = "TerraformStateDynamoDB"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable"
    ]
    resources = [
      "arn:aws:dynamodb:us-east-2:${data.aws_caller_identity.current.account_id}:table/tfstate-ebook-app-lock"
    ]
  }

  # Permisos para Lambda
  statement {
    sid = "LambdaManagement"
    actions = [
      "lambda:*"
    ]
    resources = ["*"]
  }

  # Permisos para DynamoDB
  statement {
    sid = "DynamoDBManagement"
    actions = [
      "dynamodb:*"
    ]
    resources = ["*"]
  }

  # Permisos para CloudFront
  statement {
    sid = "CloudFrontManagement"
    actions = [
      "cloudfront:*"
    ]
    resources = ["*"]
  }

  # Permisos para Route53
  statement {
    sid = "Route53Management"
    actions = [
      "route53:*"
    ]
    resources = ["*"]
  }

  # Permisos para CloudWatch
  statement {
    sid = "CloudWatchManagement"
    actions = [
      "logs:*",
      "cloudwatch:*"
    ]
    resources = ["*"]
  }

  # Permisos para IAM (crear roles para Lambda)
  statement {
    sid = "IAMManagement"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:PassRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:ListOpenIDConnectProviders"
    ]
    resources = ["*"]
  }

  # Permisos para ACM (certificados SSL)
  statement {
    sid = "ACMManagement"
    actions = [
      "acm:*"
    ]
    resources = ["*"]
  }

  # Permisos para S3 (buckets de aplicación)
  statement {
    sid = "S3Management"
    actions = [
      "s3:*"
    ]
    resources = ["*"]
  }

  # Permisos para API Gateway
  statement {
    sid = "APIGatewayManagement"
    actions = [
      "apigateway:*"
    ]
    resources = ["*"]
  }

  # Permisos para leer datos (necesario para data sources)
  statement {
    sid = "ReadOnlyAccess"
    actions = [
      "ec2:Describe*",
      "elasticloadbalancing:Describe*",
      "sts:GetCallerIdentity"
    ]
    resources = ["*"]
  }
}

# Crear la política
resource "aws_iam_policy" "terraform_permissions" {
  name        = "github-actions-terraform-policy"
  description = "Política de permisos para Terraform ejecutado por GitHub Actions"
  policy      = data.aws_iam_policy_document.terraform_permissions.json
}

# Adjuntar la política al role
resource "aws_iam_role_policy_attachment" "terraform_permissions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_permissions.arn
}
