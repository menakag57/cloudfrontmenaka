output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.cdn.cloudfront_domain_name
}
