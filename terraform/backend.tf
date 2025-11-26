terraform {
  backend "s3" {
    bucket         = "tfstate-ebook-app"
    key            = "ebook-app/production/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "tfstate-ebook-app-lock"
    encrypt        = true
  }
}
