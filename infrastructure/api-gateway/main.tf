# API Gateway REST API
resource "aws_api_gateway_rest_api" "url_shortener_api" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  tags = {
    Name        = var.api_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Service     = "api-gateway"
  }
}

# API Gateway Resource for /shorten endpoint
resource "aws_api_gateway_resource" "shorten" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  parent_id   = aws_api_gateway_rest_api.url_shortener_api.root_resource_id
  path_part   = "shorten"
}

# API Gateway Method for POST /shorten
resource "aws_api_gateway_method" "shorten_post" {
  rest_api_id   = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id   = aws_api_gateway_resource.shorten.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Method for OPTIONS /shorten (CORS)
resource "aws_api_gateway_method" "shorten_options" {
  rest_api_id   = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id   = aws_api_gateway_resource.shorten.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Lambda Integration for POST /shorten
resource "aws_api_gateway_integration" "shorten_lambda" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id = aws_api_gateway_resource.shorten.id
  http_method = aws_api_gateway_method.shorten_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_shorten_invoke_arn
}

# Mock Integration for OPTIONS /shorten (CORS)
resource "aws_api_gateway_integration" "shorten_options" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id = aws_api_gateway_resource.shorten.id
  http_method = aws_api_gateway_method.shorten_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Method Response for POST /shorten
resource "aws_api_gateway_method_response" "shorten_post_200" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id = aws_api_gateway_resource.shorten.id
  http_method = aws_api_gateway_method.shorten_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# Method Response for OPTIONS /shorten
resource "aws_api_gateway_method_response" "shorten_options_200" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id = aws_api_gateway_resource.shorten.id
  http_method = aws_api_gateway_method.shorten_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods"  = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Integration Response for OPTIONS /shorten
resource "aws_api_gateway_integration_response" "shorten_options" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id = aws_api_gateway_resource.shorten.id
  http_method = aws_api_gateway_method.shorten_options.http_method
  status_code = aws_api_gateway_method_response.shorten_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods"  = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Lambda Permission for API Gateway to invoke shorten function
resource "aws_lambda_permission" "api_gateway_shorten" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_shorten_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.url_shortener_api.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "url_shortener" {
  depends_on = [
    aws_api_gateway_integration.shorten_lambda,
    aws_api_gateway_integration.shorten_options,
    aws_api_gateway_method_response.shorten_options_200,
    aws_api_gateway_integration_response.shorten_options,
  ]

  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.shorten.id,
      aws_api_gateway_method.shorten_post.id,
      aws_api_gateway_method.shorten_options.id,
      aws_api_gateway_integration.shorten_lambda.id,
      aws_api_gateway_integration.shorten_options.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "url_shortener" {
  deployment_id = aws_api_gateway_deployment.url_shortener.id
  rest_api_id   = aws_api_gateway_rest_api.url_shortener_api.id
  stage_name    = var.stage_name

  tags = {
    Name        = "${var.api_name}-${var.stage_name}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Service     = "api-gateway"
  }
}

