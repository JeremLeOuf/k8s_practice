# DynamoDB Table for Budget Tracker
resource "aws_dynamodb_table" "budget_tracker" {
  name         = "BudgetTracker"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  global_secondary_index {
    name            = "TimestampIndex"
    hash_key        = "timestamp"
    projection_type = "ALL"
  }

  tags = {
    Name        = "Budget Tracker"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [name]
  }
}

# SNS Topic for Budget Alerts
resource "aws_sns_topic" "budget_alerts" {
  name = "budget-alerts"

  tags = {
    Name        = "Budget Alerts"
    Environment = var.environment
  }
}

# SNS Topic Subscription (Email)
resource "aws_sns_topic_subscription" "budget_alerts_email" {
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# IAM Policy for Budget Tracker Lambda to access DynamoDB and SNS
resource "aws_iam_role_policy" "budget_tracker_lambda" {
  name = "budget-tracker-lambda-policy"
  role = aws_iam_role.budget_tracker_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = [
          aws_dynamodb_table.budget_tracker.arn,
          "${aws_dynamodb_table.budget_tracker.arn}/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
          "sns:GetTopicAttributes"
        ]
        Resource = aws_sns_topic.budget_alerts.arn
      }
    ]
  })

  lifecycle {
    create_before_destroy = false
  }
}

# IAM Role for Budget Tracker Lambda
resource "aws_iam_role" "budget_tracker_lambda" {
  name = "budget-tracker-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  lifecycle {
    ignore_changes = [name]
  }
}

# Lambda Function: Add Transaction
resource "aws_lambda_function" "add_transaction" {
  filename      = "${path.module}/../budget-tracker/lambda-functions/add-transaction/function.zip"
  function_name = "budget-tracker-add-transaction"
  role          = aws_iam_role.budget_tracker_lambda.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.9"
  memory_size   = 128
  timeout       = 10

  environment {
    variables = {
      TABLE_NAME    = aws_dynamodb_table.budget_tracker.name
      SNS_TOPIC_ARN = aws_sns_topic.budget_alerts.arn
    }
  }
}

# Lambda Function: Get Balance
resource "aws_lambda_function" "get_balance" {
  filename      = "${path.module}/../budget-tracker/lambda-functions/get-balance/function.zip"
  function_name = "budget-tracker-get-balance"
  role          = aws_iam_role.budget_tracker_lambda.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.9"
  memory_size   = 128
  timeout       = 10

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.budget_tracker.name
    }
  }
}

# Outputs
output "budget_tracker_table_name" {
  value = aws_dynamodb_table.budget_tracker.name
}

output "budget_alerts_topic_arn" {
  value = aws_sns_topic.budget_alerts.arn
}

