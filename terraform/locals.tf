locals {
  # Información de la cuenta y región
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # Prefijo común para nombres de recursos
  name_prefix = "${var.stack_id}-${var.environment}"

  # Tags comunes para todos los recursos
  common_tags = {
    StackId     = var.stack_id
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }

  domain_name = "www.sminfralab.cloud"
}
