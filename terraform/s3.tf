module "website_bucket" {
  source = "./modules/s3"

  bucket_name        = "${local.name_prefix}-website"
  versioning_enabled = true
  public_access      = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-website"
  })
}

resource "aws_s3_bucket_policy" "website_cloudfront_access" {
  bucket = module.website_bucket.bucket_id
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "AllowCloudFrontAccess"
          Effect = "Allow"
          Principal = {
            Service = "cloudfront.amazonaws.com"
          }
          Action   = "s3:GetObject"
          Resource = "${module.website_bucket.bucket_arn}/*"
          Condition = {
            StringEquals = {
              "AWS:SourceArn" = aws_cloudfront_distribution.website_cloudfront.arn
            }
          }
        },
      ]
    }
  )
}