# Información de la cuenta AWS actual
data "aws_caller_identity" "current" {}

# Información de la región actual
data "aws_region" "current" {}

data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}