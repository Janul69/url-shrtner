# API Gateway Module

This module provisions an AWS API Gateway REST API and integrates it with the shorten Lambda function.

## Resources

- **API Gateway REST API**: Main API Gateway resource
- **Resource (/shorten)**: API Gateway resource for the shorten endpoint
- **Method (POST)**: HTTP POST method for creating shortened URLs
- **Method (OPTIONS)**: HTTP OPTIONS method for CORS preflight requests
- **Lambda Integration**: Integration between API Gateway and shorten Lambda function
- **Lambda Permission**: Permission for API Gateway to invoke the Lambda function
- **Deployment**: API Gateway deployment
- **Stage**: API Gateway stage (dev, staging, prod)

## Endpoints

### POST /shorten
Creates a shortened URL.

**Request Body:**
```json
{
  "url": "https://example.com",
  "customCode": "optional-custom-code"
}
```

**Response:**
```json
{
  "success": true,
  "shortCode": "abc123",
  "shortUrl": "https://myapp.com/abc123",
  "originalUrl": "https://example.com",
  "createdAt": 1234567890,
  "expiresAt": 1237159890
}
```

### OPTIONS /shorten
CORS preflight request handler.

## CORS Configuration

The API Gateway is configured with CORS support:
- **Allowed Origins**: `*` (all origins)
- **Allowed Methods**: `POST, OPTIONS`
- **Allowed Headers**: `Content-Type, X-Amz-Date, Authorization, X-Api-Key, X-Amz-Security-Token`

## Usage

This module is called from the root `main.tf`:

```hcl
module "api_gateway" {
  source = "./api-gateway"
  
  environment  = var.environment
  project_name = var.project_name
  lambda_shorten_function_name = module.lambda.lambda_shorten_function_name
  lambda_shorten_invoke_arn    = module.lambda.lambda_shorten_function_invoke_arn
  # ... other variables
}
```

## Variables

See `variables.tf` for all available variables.

## Outputs

- `api_gateway_id`: ID of the API Gateway
- `api_gateway_arn`: ARN of the API Gateway
- `api_gateway_execution_arn`: Execution ARN for Lambda permissions
- `api_gateway_invoke_url`: Base invoke URL
- `api_gateway_shorten_endpoint`: Full endpoint URL for POST /shorten

## Testing the API

After deployment, you can test the API using curl:

```bash
curl -X POST https://<api-id>.execute-api.<region>.amazonaws.com/dev/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}'
```

Or using the output value:

```bash
curl -X POST $(terraform output -raw api_gateway_shorten_endpoint) \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}'
```

## Notes

- The API Gateway uses AWS_PROXY integration type for Lambda
- CORS is configured to allow all origins (adjust for production)
- The deployment is triggered automatically when resources change
- The stage name defaults to "dev" but can be configured

