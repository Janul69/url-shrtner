terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
