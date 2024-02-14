module "cdn" {
  source = "./child_module"

  logging_bucket_name    = var.logging_bucket_name
  allowed_methods        = var.allowed_methods
  allowed_origins        = var.allowed_origins
  index_html_source_path = var.index_html_source_path
  cloudfront_locations   = var.cloudfront_locations
}
