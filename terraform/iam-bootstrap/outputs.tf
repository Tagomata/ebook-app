# Outputs importantes para GitHub Actions

output "oidc_provider_arn" {
  description = "ARN del OIDC Provider de GitHub"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arn" {
  description = "ARN del IAM Role para GitHub Actions - COPIA ESTE VALOR"
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "Nombre del IAM Role"
  value       = aws_iam_role.github_actions.name
}
