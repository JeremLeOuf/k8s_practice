output "api_gateway_url" {
  description = "The API Gateway URL"
  value       = aws_api_gateway_deployment.api.invoke_url
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = aws_dynamodb_table.knowledge_base.arn
}

output "lambda_function_names" {
  description = "Names of the Lambda functions"
  value = {
    get_items   = aws_lambda_function.get_items.function_name
    create_item = aws_lambda_function.create_item.function_name
    delete_item = aws_lambda_function.delete_item.function_name
  }
}

