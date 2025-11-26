provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      Project   = "ebook-app"
      ManagedBy = "Terraform"
      Purpose   = "GitHub-Actions-OIDC"
    }
  }
}
