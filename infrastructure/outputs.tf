# API URLs
output "api_url" {
  description = "The API Gateway URL for items endpoint"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/items"
}

output "api_gateway_url" {
  description = "The API Gateway base URL"
  value       = aws_api_gateway_stage.prod.invoke_url
}

# Database
output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.knowledge_base.name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = aws_dynamodb_table.knowledge_base.arn
}

# Lambda Functions
output "lambda_function_names" {
  description = "Names of the Lambda functions"
  value = {
    get_items   = aws_lambda_function.get_items.function_name
    create_item = aws_lambda_function.create_item.function_name
    delete_item = aws_lambda_function.delete_item.function_name
  }
}

