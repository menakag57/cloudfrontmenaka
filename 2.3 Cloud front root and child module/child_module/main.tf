// S3 Bucket Configuration for Logs
resource "aws_s3_bucket" "logs_my_cdn" {
  bucket = var.logging_bucket_name
   versioning {
    enabled = true
   }
    tags = {
    Name = var.logging_bucket_name
  }
  acl           = "private"
  force_destroy = true
  object_lock_configuration {
    object_lock_enabled = "Enabled"
    rule {
      default_retention {
        mode = "GOVERNANCE"
        days = 1
      }
    }
  }
}
resource "aws_s3_bucket_policy" "logs_my_cdn_policy" {
  bucket = aws_s3_bucket.logs_my_cdn.id

  policy = jsonencode({
   
   "Version": "2012-10-17",
   "Statement": [
      {
         "Sid": "Only allow writes to my bucket with bucket owner full control",
         "Effect": "Allow",
         "Principal": {
            "AWS": [
               "*"
            ]
         },
         "Action": [
            "s3:PutObject"
         ],
         "Resource": "arn:aws:s3:::log-my-cdn/*",
         "Condition": {
            "StringEquals": {
               "s3:x-amz-acl": "bucket-owner-full-control"
            }
         }
      }
   ]
  })

}


resource "aws_s3_bucket_public_access_block" "logs_my_cdn" {
  bucket              = aws_s3_bucket.logs_my_cdn.id
  block_public_acls   = false
  block_public_policy = false
}



// S3 Bucket Configuration

resource "aws_s3_bucket" "terraform" {
  bucket = var.bucket_name
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  website {
    index_document = "index.html"
  }

  versioning {
    enabled = true
  }
  // CORS rules to allow access from specified origins
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = var.allowed_methods
    allowed_origins = var.allowed_origins
  }

  tags = {
    name = "terraform_angular"
  }

  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "terraform" {
  bucket = aws_s3_bucket.terraform.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "GetObjectPolicy",
    "Statement" : [
      {
        "Sid" : "GetObjectStatement",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.terraform.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "hosting_bucket_website_configuration" {
  bucket = aws_s3_bucket.terraform.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform" {
  bucket              = aws_s3_bucket.terraform.id
  block_public_acls   = false
  block_public_policy = false
}

resource "aws_s3_bucket_object" "bucket1" {
  bucket       = aws_s3_bucket.terraform.bucket
  key          = "index.html"
  content_type = "text/html"
  source       = var.index_html_source_path
  etag         = filemd5(var.index_html_source_path)

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_cloudfront_distribution" "terraform_cdn" {
  origin {
    domain_name = aws_s3_bucket.terraform.bucket_regional_domain_name
    origin_id   = "my_first_origin"
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "my_first_origin"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  logging_config {
    bucket          = aws_s3_bucket.logs_my_cdn.bucket_domain_name
    include_cookies = true
    prefix          = null
  }
  wait_for_deployment = true // Whether to wait for the distribution to be deployed
  web_acl_id          = null

  // Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "my_first_origin"
    forwarded_values {
      query_string = false
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "allow-all"
  }

  // Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "my_first_origin"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  price_class = "PriceClass_200"
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = var.cloudfront_locations
    }
  }
  tags = {
    Environment = "production"
  }
  viewer_certificate {
    acm_certificate_arn            = null
    cloudfront_default_certificate = true
  }
}
