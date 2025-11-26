# provider.tf
# Configura el provider de AWS con las credenciales y región

provider "aws" {
  region = var.aws_region

  # Tags por defecto que se aplicarán a TODOS los recursos
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Provider adicional para recursos globales (como CloudFront y Route53)
# CloudFront requiere certificados ACM en us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
