module "website_bucket" {
  source = "./modules/s3"

  bucket_name        = "${local.name_prefix}-website"
  versioning_enabled = true
  public_access      = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-website"
  })
}