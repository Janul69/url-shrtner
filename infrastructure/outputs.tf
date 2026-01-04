# Root-level outputs that reference module outputs

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamodb.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamodb.dynamodb_table_arn
}

output "dynamodb_table_id" {
  description = "ID of the DynamoDB table"
  value       = module.dynamodb.dynamodb_table_id
}

output "dynamodb_table_stream_arn" {
  description = "The ARN of the Table Stream. Only available when stream_enabled = true"
  value       = module.dynamodb.dynamodb_table_stream_arn
}

# Lambda Outputs
output "lambda_shorten_function_name" {
  description = "Name of the shorten Lambda function"
  value       = module.lambda.lambda_shorten_function_name
}

output "lambda_shorten_function_arn" {
  description = "ARN of the shorten Lambda function"
  value       = module.lambda.lambda_shorten_function_arn
}

output "lambda_shorten_function_invoke_arn" {
  description = "Invoke ARN of the shorten Lambda function"
  value       = module.lambda.lambda_shorten_function_invoke_arn
}

output "lambda_redirect_function_name" {
  description = "Name of the redirect Lambda function"
  value       = module.lambda.lambda_redirect_function_name
}

output "lambda_redirect_function_arn" {
  description = "ARN of the redirect Lambda function"
  value       = module.lambda.lambda_redirect_function_arn
}

output "lambda_redirect_function_invoke_arn" {
  description = "Invoke ARN of the redirect Lambda function"
  value       = module.lambda.lambda_redirect_function_invoke_arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = module.lambda.lambda_execution_role_arn
}

# API Gateway Outputs
output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = module.api_gateway.api_gateway_id
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway"
  value       = module.api_gateway.api_gateway_arn
}

output "api_gateway_invoke_url" {
  description = "Invoke URL of the API Gateway"
  value       = module.api_gateway.api_gateway_invoke_url
}

output "api_gateway_shorten_endpoint" {
  description = "Full endpoint URL for the shorten endpoint"
  value       = module.api_gateway.api_gateway_shorten_endpoint
}
