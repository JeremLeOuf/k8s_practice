# AWS Managed Grafana Workspace
resource "aws_grafana_workspace" "main" {
  name                     = "pkb-grafana-workspace"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["SAML"]
  permission_type          = "SERVICE_MANAGED"
  
  data_sources = ["CLOUDWATCH", "PROMETHEUS"]
  
  role_arn = aws_iam_role.grafana_managed.arn

  tags = {
    Name        = "Grafana Workspace"
    Environment = var.environment
  }
}

# IAM Role for AWS Managed Grafana
resource "aws_iam_role" "grafana_managed" {
  name = "pkb-grafana-managed-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "grafana.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "Grafana Managed Role"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [name]
  }
}

# Attach CloudWatch read access
resource "aws_iam_role_policy_attachment" "grafana_managed_cloudwatch" {
  role       = aws_iam_role.grafana_managed.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

# Attach Grafana service role policy
resource "aws_iam_role_policy_attachment" "grafana_managed_service_role" {
  role       = aws_iam_role.grafana_managed.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonGrafanaServiceLinkedRolePolicy"
}

# Outputs
output "grafana_managed_url" {
  description = "AWS Managed Grafana workspace URL"
  value       = aws_grafana_workspace.main.endpoint
}

output "grafana_managed_id" {
  description = "Grafana workspace ID"
  value       = aws_grafana_workspace.main.id
}

