resource "aws_iam_role" "github_actions_ebook_deploy" {
  name        = "github-actions-ebook-deploy-role"
  description = "Role para que GitHub Actions pueda desplegar el código del sitio ebook en S3"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Federated = data.aws_iam_openid_connect_provider.github_actions.arn
          }
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
              "token.actions.githubusercontent.com:sub" = "repo:Tagomata/${var.github_repo_frontend}:ref:refs/heads/main"
            }
          }
        }
      ]
    }
  )


  tags = merge(local.common_tags, {
    Name = "github-actions-ebook-deploy-role"
  })
}

resource "aws_iam_policy" "github_actions_ebook_deploy" {
  name        = "github-actions-ebook-deploy-policy"
  description = "Política de permisos para desplegar el código del sitio ebook en S3"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "S3Access"
          Effect = "Allow"
          Action = [
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ]
          Resource = [
            "arn:aws:s3:::${module.website_bucket.bucket_id}"
          ]
        },
        {
          Sid    = "S3ObjectAccess"
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
          ]
          Resource = [
            "arn:aws:s3:::${module.website_bucket.bucket_id}/*"
          ]
        },
        {
          Sid    = "CloudfrontInvalidation"
          Effect = "Allow"
          Action = [
            "cloudfront:GetDistribution",
            "cloudfront:CreateInvalidation",
            "cloudfront:ListInvalidations",
            "cloudfront:GetInvalidation",
          ]
          Resource = [
            aws_cloudfront_distribution.website_cloudfront.arn
          ]
        }

      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "github_actions_ebook_deploy" {
  role       = aws_iam_role.github_actions_ebook_deploy.name
  policy_arn = aws_iam_policy.github_actions_ebook_deploy.arn
}