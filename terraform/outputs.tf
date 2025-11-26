# outputs.tf
# Outputs que se mostrarán después de terraform apply

output "aws_region" {
  description = "Región de AWS utilizada"
  value       = var.aws_region
}

output "stack_id" {
  description = "ID del stack desplegado"
  value       = var.stack_id
}

output "environment" {
  description = "Ambiente desplegado"
  value       = var.environment
}

output "project_name" {
  description = "Nombre del proyecto"
  value       = var.project_name
}

output "name_prefix" {
  description = "Prefijo usado para nombres de recursos"
  value       = local.name_prefix
}
