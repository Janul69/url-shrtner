# DynamoDB Table for URL Shortener
resource "aws_dynamodb_table" "url_shortener" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  hash_key       = "short_code"

  attribute {
    name = "short_code"
    type = "S"
  }

  # Optional: Add range key if needed for additional queries
  # range_key      = "created_at"
  # attribute {
  #   name = "created_at"
  #   type = "N"
  # }

  # Point-in-time recovery (optional but recommended for production)
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  # Server-side encryption
  server_side_encryption {
    enabled = var.enable_encryption
  }

  # Tags
  tags = {
    Name        = var.table_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Service     = "dynamodb"
  }
}

