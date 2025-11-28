resource "aws_acm_certificate" "website_cloudfront_certificate" {
  provider          = aws.us_east_1
  domain_name       = local.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "www.${local.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}