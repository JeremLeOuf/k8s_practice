variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "personal-knowledge-base"
}

variable "alert_email" {
  description = "Email address for budget alerts"
  type        = string
  default     = "your-email@example.com"
}

variable "enable_cloudfront" {
  description = "Enable CloudFront distribution (disabled for faster deployments)"
  type        = bool
  default     = false
}

