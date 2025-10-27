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
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*:*"
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
  filename      = "${path.module}/../lambda-functions/budget-tracker/add-transaction/function.zip"
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
  filename      = "${path.module}/../lambda-functions/budget-tracker/get-balance/function.zip"
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

# Lambda Permissions for API Gateway
resource "aws_lambda_permission" "api_gateway_add_transaction" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_transaction.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_lambda_permission" "api_gateway_get_balance" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_balance.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"

  lifecycle {
    create_before_destroy = false
  }
}

# API Gateway Resources for Budget Tracker
resource "aws_api_gateway_resource" "budget_transactions" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "transactions"
}

resource "aws_api_gateway_resource" "budget_balance" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "balance"
}

# API Gateway: POST /transactions
resource "aws_api_gateway_method" "add_transaction" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.budget_transactions.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "add_transaction" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.budget_transactions.id
  http_method = aws_api_gateway_method.add_transaction.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.add_transaction.invoke_arn
}

# API Gateway: GET /balance
resource "aws_api_gateway_method" "get_balance" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.budget_balance.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_balance" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.budget_balance.id
  http_method = aws_api_gateway_method.get_balance.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_balance.invoke_arn
}

# CORS: OPTIONS for /transactions
resource "aws_api_gateway_method" "options_transactions" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.budget_transactions.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_transactions" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.budget_transactions.id
  http_method = aws_api_gateway_method.options_transactions.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_transactions" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.budget_transactions.id
  http_method = aws_api_gateway_method.options_transactions.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_transactions" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.budget_transactions.id
  http_method = aws_api_gateway_method.options_transactions.http_method
  status_code = aws_api_gateway_method_response.options_transactions.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }

  depends_on = [
    aws_api_gateway_integration.options_transactions
  ]
}

# CORS: OPTIONS for /balance
resource "aws_api_gateway_method" "options_balance" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.budget_balance.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_balance" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.budget_balance.id
  http_method = aws_api_gateway_method.options_balance.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_balance" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.budget_balance.id
  http_method = aws_api_gateway_method.options_balance.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_balance" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.budget_balance.id
  http_method = aws_api_gateway_method.options_balance.http_method
  status_code = aws_api_gateway_method_response.options_balance.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }

  depends_on = [
    aws_api_gateway_integration.options_balance
  ]
}

# Outputs
output "budget_tracker_table_name" {
  value = aws_dynamodb_table.budget_tracker.name
}

output "budget_alerts_topic_arn" {
  value = aws_sns_topic.budget_alerts.arn
}

output "budget_tracker_api_url" {
  description = "The Budget Tracker API URL"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/transactions"
}

output "budget_balance_api_url" {
  description = "The Budget Balance API URL"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/balance"
}

