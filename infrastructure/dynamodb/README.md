# DynamoDB Module

This module provisions a DynamoDB table for the URL shortener application.

## Resources

- **DynamoDB Table**: Stores shortened URLs with `short_code` as the hash key

## Usage

This module is called from the root `main.tf`:

```hcl
module "dynamodb" {
  source = "./dynamodb"
  
  environment  = var.environment
  project_name = var.project_name
  table_name   = var.dynamodb_table_name
  # ... other variables
}
```

## Variables

See `variables.tf` for all available variables.

## Outputs

- `dynamodb_table_name`: Name of the table
- `dynamodb_table_arn`: ARN of the table
- `dynamodb_table_id`: ID of the table
- `dynamodb_table_stream_arn`: Stream ARN (if enabled)

