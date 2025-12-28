# Shared variables used across all services

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = ""
}

variable "aws_access_key" {
  description = "AWS access key ID (can also be set via AWS_ACCESS_KEY_ID env var)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS secret access key (can also be set via AWS_SECRET_ACCESS_KEY env var)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for tagging resources"
  type        = string
  default     = "url-shortener"
}

# DynamoDB Variables
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "url-shortener"
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
  
  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.dynamodb_billing_mode)
    error_message = "Billing mode must be either PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "dynamodb_read_capacity" {
  description = "Read capacity units (required if billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "Write capacity units (required if billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for DynamoDB table"
  type        = bool
  default     = false
}

variable "dynamodb_enable_encryption" {
  description = "Enable server-side encryption for DynamoDB table"
  type        = bool
  default     = true
}

# Lambda Variables
variable "lambda_shorten_function_source_path" {
  description = "Path to the shorten Lambda function source code"
  type        = string
  default     = "../backend/functions/shorten"
}

variable "lambda_redirect_function_source_path" {
  description = "Path to the redirect Lambda function source code"
  type        = string
  default     = "../backend/functions/redirect"
}

variable "lambda_runtime" {
  description = "Lambda runtime version"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "lambda_base_url" {
  description = "Base URL for shortened links (used in shorten function)"
  type        = string
  default     = "https://myapp.com"
}

variable "lambda_default_redirect_url" {
  description = "Default redirect URL if short code not found (used in redirect function)"
  type        = string
  default     = "https://myapp.com"
}
