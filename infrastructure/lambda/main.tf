# IAM Role for Lambda execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}-lambda-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-lambda-execution-role"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Service     = "lambda"
  }
}

# IAM Policy for DynamoDB access
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "${var.project_name}-lambda-dynamodb-policy-${var.environment}"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          var.dynamodb_table_arn,
          "${var.dynamodb_table_arn}/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Archive the shorten function
data "archive_file" "shorten_zip" {
  type        = "zip"
  source_dir  = "${path.root}/${var.shorten_function_source_path}"
  output_path = "${path.module}/shorten.zip"
}

# Archive the redirect function
data "archive_file" "redirect_zip" {
  type        = "zip"
  source_dir  = "${path.root}/${var.redirect_function_source_path}"
  output_path = "${path.module}/redirect.zip"
}

# Lambda function for shortening URLs
resource "aws_lambda_function" "shorten" {
  filename         = data.archive_file.shorten_zip.output_path
  function_name    = "${var.project_name}-shorten-${var.environment}"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "index.handler"
  source_code_hash = data.archive_file.shorten_zip.output_base64sha256
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
      BASE_URL  = var.base_url
    }
  }

  tags = {
    Name        = "${var.project_name}-shorten"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Service     = "lambda"
  }
}

# Lambda function for redirecting URLs
resource "aws_lambda_function" "redirect" {
  filename         = data.archive_file.redirect_zip.output_path
  function_name    = "${var.project_name}-redirect-${var.environment}"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "index.handler"
  source_code_hash = data.archive_file.redirect_zip.output_base64sha256
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  environment {
    variables = {
      TABLE_NAME      = var.dynamodb_table_name
      DEFAULT_REDIRECT = var.default_redirect_url
    }
  }

  tags = {
    Name        = "${var.project_name}-redirect"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Service     = "lambda"
  }
}

