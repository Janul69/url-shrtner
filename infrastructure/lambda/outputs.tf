output "lambda_shorten_function_name" {
  description = "Name of the shorten Lambda function"
  value       = aws_lambda_function.shorten.function_name
}

output "lambda_shorten_function_arn" {
  description = "ARN of the shorten Lambda function"
  value       = aws_lambda_function.shorten.arn
}

output "lambda_shorten_function_invoke_arn" {
  description = "Invoke ARN of the shorten Lambda function"
  value       = aws_lambda_function.shorten.invoke_arn
}

output "lambda_redirect_function_name" {
  description = "Name of the redirect Lambda function"
  value       = aws_lambda_function.redirect.function_name
}

output "lambda_redirect_function_arn" {
  description = "ARN of the redirect Lambda function"
  value       = aws_lambda_function.redirect.arn
}

output "lambda_redirect_function_invoke_arn" {
  description = "Invoke ARN of the redirect Lambda function"
  value       = aws_lambda_function.redirect.invoke_arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

