variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
  default     = "us-east-2"
}

variable "stack_id" {
  description = "Identificador único del stack (usado en nombres de recursos)"
  type        = string
  default     = "ebook-app"
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "ebook-app"
}
