# versions.tf
# Define las versiones mínimas de Terraform y providers que este proyecto requiere
# Esto asegura que todos los desarrolladores usen versiones compatibles

terraform {
  # Versión mínima de Terraform requerida
  required_version = ">= 1.6.0"

  # Providers que este proyecto necesita
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Usa versión 5.x (5.0, 5.1, 5.2, etc.)
    }
  }
}
