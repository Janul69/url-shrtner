# Shared variables passed from root module
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging resources"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  type        = string
}

# Lambda-specific variables
variable "shorten_function_source_path" {
  description = "Path to the shorten Lambda function source code"
  type        = string
  default     = "../../backend/functions/shorten"
}

variable "redirect_function_source_path" {
  description = "Path to the redirect Lambda function source code"
  type        = string
  default     = "../../backend/functions/redirect"
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

variable "base_url" {
  description = "Base URL for shortened links (used in shorten function)"
  type        = string
  default     = "https://myapp.com"
}

variable "default_redirect_url" {
  description = "Default redirect URL if short code not found (used in redirect function)"
  type        = string
  default     = "https://myapp.com"
}

