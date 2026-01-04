output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.url_shortener_api.id
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.url_shortener_api.arn
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.url_shortener_api.execution_arn
}

output "api_gateway_invoke_url" {
  description = "Invoke URL of the API Gateway"
  value       = "${aws_api_gateway_stage.url_shortener.invoke_url}/shorten"
}

output "api_gateway_stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.url_shortener.stage_name
}

output "api_gateway_shorten_endpoint" {
  description = "Full endpoint URL for the shorten endpoint"
  value       = "${aws_api_gateway_stage.url_shortener.invoke_url}/shorten"
}

