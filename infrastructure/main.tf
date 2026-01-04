terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  # Credentials can be provided via:
  # 1. Environment variables: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
  # 2. Terraform variables: aws_access_key and aws_secret_key
  # 3. AWS credentials file (~/.aws/credentials) - not used here
  access_key = var.aws_access_key != "" ? var.aws_access_key : null
  secret_key = var.aws_secret_key != "" ? var.aws_secret_key : null
}

# DynamoDB Module
module "dynamodb" {
  source = "./dynamodb"

  # Pass shared variables
  environment  = var.environment
  project_name = var.project_name

  # DynamoDB-specific variables
  table_name                  = var.dynamodb_table_name
  billing_mode                = var.dynamodb_billing_mode
  read_capacity               = var.dynamodb_read_capacity
  write_capacity              = var.dynamodb_write_capacity
  enable_point_in_time_recovery = var.dynamodb_enable_point_in_time_recovery
  enable_encryption           = var.dynamodb_enable_encryption
}

# Lambda Module
module "lambda" {
  source = "./lambda"

  # Pass shared variables
  environment  = var.environment
  project_name = var.project_name

  # DynamoDB information (from dynamodb module)
  dynamodb_table_name = module.dynamodb.dynamodb_table_name
  dynamodb_table_arn  = module.dynamodb.dynamodb_table_arn

  # Lambda-specific variables
  shorten_function_source_path = var.lambda_shorten_function_source_path
  redirect_function_source_path = var.lambda_redirect_function_source_path
  lambda_runtime               = var.lambda_runtime
  lambda_timeout               = var.lambda_timeout
  lambda_memory_size           = var.lambda_memory_size
  base_url                     = var.lambda_base_url
  default_redirect_url         = var.lambda_default_redirect_url
}


# API Gateway Module
module "api_gateway" {
  source = "./api-gateway"

  # Pass shared variables
  environment  = var.environment
  project_name = var.project_name

  # Lambda information (from lambda module)
  lambda_shorten_function_name = module.lambda.lambda_shorten_function_name
  lambda_shorten_invoke_arn    = module.lambda.lambda_shorten_function_invoke_arn

  # API Gateway-specific variables
  api_name        = var.api_gateway_name
  api_description = var.api_gateway_description
  endpoint_type   = var.api_gateway_endpoint_type
  stage_name      = var.api_gateway_stage_name
}