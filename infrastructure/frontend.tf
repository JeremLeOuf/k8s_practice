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

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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

# S3 Bucket Policy for CloudFront
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.frontend.id}"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })

  lifecycle {
    create_before_destroy = false
  }
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "frontend" {
  comment = "OAI for Personal Knowledge Base Frontend"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "frontend" {
  depends_on = [aws_s3_bucket.frontend]

  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.frontend.bucket}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled      = true
  default_root_object  = "index.html"
  comment              = "Personal Knowledge Base Frontend"
  
  # Wait for deployment (faster than auto, but still takes ~15min first time)
  wait_for_deployment = false

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
    default_ttl            = 0      # No caching for faster updates
    max_ttl                = 0
    compress               = false  # Disable compression to speed up
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
  }

  tags = {
    Name        = "Personal Knowledge Base Frontend"
    Environment = var.environment
  }
}

# Empty bucket before destroying (runs during terraform destroy)
resource "null_resource" "empty_s3_bucket" {
  depends_on = [
    aws_cloudfront_distribution.frontend,
    aws_s3_bucket_policy.frontend,
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
  value = aws_cloudfront_distribution.frontend.domain_name
}

output "frontend_cdn_url" {
  value = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}

