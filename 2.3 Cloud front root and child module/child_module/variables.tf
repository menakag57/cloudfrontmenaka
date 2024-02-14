variable "logging_bucket_name" {
  description = "The name of the S3 bucket for storing CloudFront logs"
  type        = string
}

variable "allowed_methods" {
  description = "The allowed HTTP methods for CORS"
  type        = list(string)
}

variable "allowed_origins" {
  description = "The allowed origins for CORS"
  type        = list(string)
}

variable "index_html_source_path" {
  description = "The local path to the index.html file"
  type        = string
}

variable "cloudfront_locations" {
  description = "List of CloudFront distribution location codes"
  type        = list(string)
  default     = ["US", "CA", "GB", "DE"]  # Example of valid location codes
}
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "terraformtest.kavicid.in"
}
