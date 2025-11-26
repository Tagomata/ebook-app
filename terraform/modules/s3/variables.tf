variable "bucket_name" {
  type        = string
  description = "S3 Bucket name"
}

variable "versioning_enabled" {
  description = "Enabled versioning on S3 Bucket"
  type        = bool
  default     = true
}

variable "public_access" {
  description = "Public access block configuration for S3 Bucket"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to be applied to S3 Bucket"
  type        = map(string)
  default     = {}
}