// child_module/outputs.tf

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.terraform_cdn.domain_name
}
