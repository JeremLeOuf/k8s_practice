# IAM Policy for Grafana CloudWatch monitoring access

resource "aws_iam_policy" "grafana_cloudwatch_access" {
  name        = "pkb-grafana-cloudwatch-access"
  description = "Policy for Grafana to read CloudWatch metrics and logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:ListFunctions",
          "lambda:GetFunction"
        ]
        Resource = "*"
      }
    ]
  })

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_iam_user" "grafana_cloudwatch" {
  name = "pkb-grafana-cloudwatch"
  path = "/monitoring/"

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_iam_user_policy_attachment" "grafana_cloudwatch" {
  user       = aws_iam_user.grafana_cloudwatch.name
  policy_arn = aws_iam_policy.grafana_cloudwatch_access.arn

  # Ensure this is deleted before the policy and user
  lifecycle {
    create_before_destroy = false
  }
}

output "grafana_access_key_instructions" {
  value = <<-EOT
    To generate credentials for Grafana:
    
    1. Go to IAM Console → Users → pkb-grafana-cloudwatch → Security credentials
    2. Create access key
    3. Use these credentials in Grafana setup
    
    Or run:
    aws iam create-access-key --user-name pkb-grafana-cloudwatch
  EOT
}
