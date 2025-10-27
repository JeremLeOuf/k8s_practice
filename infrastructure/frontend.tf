# S3 Bucket for Static Website Hosting
resource "aws_s3_bucket" "frontend" {
  bucket = "pkb-frontend-${var.project_name}"

  tags = {
    Name        = "Personal Knowledge Base Frontend"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [bucket]
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Public Access Block (allow public access when not using CloudFront)
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = var.enable_cloudfront
  block_public_policy     = var.enable_cloudfront
  ignore_public_acls      = var.enable_cloudfront
  restrict_public_buckets = var.enable_cloudfront

  lifecycle {
    # Don't delete this if switching between CloudFront and S3-only modes
    prevent_destroy = false
  }
}

# S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "frontend" {
  count   = var.enable_cloudfront ? 1 : 0
  comment = "OAI for Personal Knowledge Base Frontend"
}

# S3 Bucket Policy (conditional based on CloudFront usage)
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  # Use CloudFront OAI policy if enabled, otherwise public read policy
  policy = var.enable_cloudfront ? jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.frontend[0].id}"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  }) : jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })

  lifecycle {
    create_before_destroy = false
  }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "frontend" {
  count  = var.enable_cloudfront ? 1 : 0
  depends_on = [aws_s3_bucket.frontend, aws_api_gateway_stage.prod]

  # S3 Origin for static files
  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.frontend.bucket}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend[0].cloudfront_access_identity_path
    }
  }

  # API Gateway Origin for /items, /transactions, /balance
  origin {
    domain_name = replace(replace(aws_api_gateway_stage.prod.invoke_url, "/https?://", ""), "/prod.*", "")
    origin_id   = "api-gateway"
    origin_path = "/prod"

    custom_origin_config {
      http_port              = 443
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "Personal Knowledge Base Frontend"

  # Wait for deployment (faster than auto, but still takes ~15min first time)
  wait_for_deployment = false

  # Default behavior for static files (S3)
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.frontend.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0 # No caching for faster updates
    max_ttl                = 0
    compress               = false # Disable compression to speed up
  }

  # Behavior for /items/* endpoints (includes /items and /items/{id})
  ordered_cache_behavior {
    path_pattern     = "/items*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "api-gateway"

    forwarded_values {
      query_string = true
      headers      = ["Accept", "Content-Type", "Host", "Origin", "Referer"]
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
  }

  # Behavior for /transactions endpoint
  ordered_cache_behavior {
    path_pattern     = "/transactions"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "api-gateway"

    forwarded_values {
      query_string = true
      headers      = ["Accept", "Content-Type", "Host", "Origin", "Referer"]
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
  }

  # Behavior for /balance endpoint
  ordered_cache_behavior {
    path_pattern     = "/balance"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "api-gateway"

    forwarded_values {
      query_string = true
      headers      = ["Accept", "Content-Type", "Host", "Origin", "Referer"]
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Disable logging to speed up deployments
  # Don't wait for deployment to complete
  lifecycle {
    ignore_changes = [
      comment,
      enabled,
      is_ipv6_enabled
    ]
    create_before_destroy = true
  }

  tags = {
    Name        = "Personal Knowledge Base Frontend"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Empty bucket before destroying (runs during terraform destroy)
resource "null_resource" "empty_s3_bucket" {
  depends_on = [
    aws_s3_bucket_versioning.frontend,
    aws_s3_bucket_public_access_block.frontend
  ]

  triggers = {
    bucket_id = aws_s3_bucket.frontend.id
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      set -e
      BUCKET="${self.triggers.bucket_id}"
      
      echo "🗑️ Emptying S3 bucket: $BUCKET (all versions)..."
      
      # Delete all versions and markers
      aws s3api list-object-versions \
        --bucket "$BUCKET" \
        --output json \
        --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' > /tmp/delete-versions.json 2>/dev/null || echo '{"Objects":[]}' > /tmp/delete-versions.json
      
      [ -s /tmp/delete-versions.json ] && aws s3api delete-objects --bucket "$BUCKET" --delete file:///tmp/delete-versions.json || true
      
      # Delete markers
      aws s3api list-object-versions \
        --bucket "$BUCKET" \
        --output json \
        --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' > /tmp/delete-markers.json 2>/dev/null || echo '{"Objects":[]}' > /tmp/delete-markers.json
      
      [ -s /tmp/delete-markers.json ] && aws s3api delete-objects --bucket "$BUCKET" --delete file:///tmp/delete-markers.json || true
      
      # Finally delete remaining objects
      aws s3 rm "s3://$BUCKET" --recursive || true
      
      echo "✅ Bucket emptied"
    EOT
  }
}

# Outputs
output "frontend_bucket_name" {
  value = aws_s3_bucket.frontend.bucket
}

output "frontend_url" {
  value = var.enable_cloudfront ? aws_cloudfront_distribution.frontend[0].domain_name : aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "frontend_cdn_url" {
  value = var.enable_cloudfront ? "https://${aws_cloudfront_distribution.frontend[0].domain_name}" : "http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}"
}

output "frontend_s3_url" {
  description = "Direct S3 website endpoint URL"
  value       = "http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}"
}

