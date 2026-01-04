# Shared variables passed from root module
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging resources"
  type        = string
}

# Lambda information
variable "lambda_shorten_function_name" {
  description = "Name of the shorten Lambda function"
  type        = string
}

variable "lambda_shorten_invoke_arn" {
  description = "Invoke ARN of the shorten Lambda function"
  type        = string
}

# API Gateway-specific variables
variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "url-shortener-api"
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = "API Gateway for URL Shortener service"
}

variable "endpoint_type" {
  description = "API Gateway endpoint type (REGIONAL, EDGE, or PRIVATE)"
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "EDGE", "PRIVATE"], var.endpoint_type)
    error_message = "Endpoint type must be REGIONAL, EDGE, or PRIVATE."
  }
}

variable "stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "dev"
}

