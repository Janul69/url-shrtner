# Lambda Module

This module provisions AWS Lambda functions for the URL shortener application.

## Resources

- **IAM Role**: Execution role for Lambda functions
- **IAM Policy**: Grants DynamoDB access permissions
- **Lambda Function (shorten)**: Creates shortened URLs
- **Lambda Function (redirect)**: Redirects short codes to original URLs

## IAM Permissions

The Lambda execution role has the following permissions:

### DynamoDB Permissions
- `dynamodb:GetItem` - Read items from the table
- `dynamodb:PutItem` - Create new items
- `dynamodb:UpdateItem` - Update existing items
- `dynamodb:Query` - Query the table
- `dynamodb:Scan` - Scan the table

### CloudWatch Logs Permissions
- `logs:CreateLogGroup` - Create log groups
- `logs:CreateLogStream` - Create log streams
- `logs:PutLogEvents` - Write log events

## Usage

This module is called from the root `main.tf`:

```hcl
module "lambda" {
  source = "./lambda"
  
  environment  = var.environment
  project_name = var.project_name
  dynamodb_table_name = module.dynamodb.dynamodb_table_name
  dynamodb_table_arn  = module.dynamodb.dynamodb_table_arn
  # ... other variables
}
```

## Variables

See `variables.tf` for all available variables.

## Outputs

- `lambda_shorten_function_name`: Name of the shorten function
- `lambda_shorten_function_arn`: ARN of the shorten function
- `lambda_shorten_function_invoke_arn`: Invoke ARN for API Gateway integration
- `lambda_redirect_function_name`: Name of the redirect function
- `lambda_redirect_function_arn`: ARN of the redirect function
- `lambda_redirect_function_invoke_arn`: Invoke ARN for API Gateway integration
- `lambda_execution_role_arn`: ARN of the execution role

## Function Source Code

The module packages the Lambda functions from:
- `shorten`: `../../backend/functions/shorten`
- `redirect`: `../../backend/functions/redirect`

Make sure these directories contain:
- `index.js` - Main handler file
- `package.json` - Node.js dependencies
- `node_modules/` - Installed dependencies (will be packaged)

## Notes

- The functions are packaged as ZIP files using the `archive` provider
- Source code changes require a new deployment (Terraform will detect changes via hash)
- Environment variables are set for `TABLE_NAME`, `BASE_URL`, and `DEFAULT_REDIRECT`

