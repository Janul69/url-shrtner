# Terraform Infrastructure for URL Shortener

This directory contains Terraform configuration for provisioning AWS infrastructure for the URL shortener project.

## Directory Structure

```
infrastructure/
├── main.tf                    # Root module with provider and service modules
├── variables.tf               # Shared variables (AWS credentials, region, etc.)
├── outputs.tf                 # Root-level outputs
├── terraform.tfvars.example  # Example variables file
├── .gitignore                # Git ignore rules
├── README.md                 # This file
├── dynamodb/                  # DynamoDB service module
│   ├── main.tf               # DynamoDB table resource
│   ├── variables.tf          # DynamoDB-specific variables
│   ├── outputs.tf            # DynamoDB outputs
│   └── README.md             # DynamoDB module documentation
├── lambda/                    # Lambda service module
│   ├── main.tf               # Lambda functions and IAM resources
│   ├── variables.tf          # Lambda-specific variables
│   ├── outputs.tf            # Lambda outputs
│   └── README.md             # Lambda module documentation
└── api-gateway/              # API Gateway service module
    ├── main.tf               # API Gateway REST API and integrations
    ├── variables.tf          # API Gateway-specific variables
    ├── outputs.tf            # API Gateway outputs
    └── README.md             # API Gateway module documentation
```

The infrastructure is organized by service (e.g., `dynamodb/`, `lambda/`). Each service has its own module with dedicated configuration files. This makes it easy to add new services (e.g., `api-gateway/`, `s3/`, etc.) in the future.

## Prerequisites

1. **Terraform installed** (version >= 1.0)
   - Download from: https://www.terraform.io/downloads
   - Or use package manager: `choco install terraform` (Windows)

2. **AWS Account** with appropriate permissions

3. **AWS Credentials** - You'll need:
   - AWS Access Key ID
   - AWS Secret Access Key
   - AWS Region

## Setup

### 1. Configure Terraform Variables

Copy the example variables file:

**On Windows (PowerShell):**
```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

**On Linux/Mac:**
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and add your AWS credentials and customize the settings:

```hcl
# AWS Configuration
aws_region     = "us-east-1"
aws_access_key = "your_access_key_here"
aws_secret_key = "your_secret_key_here"

# Shared Configuration
environment  = "dev"
project_name = "url-shortener"

# DynamoDB Configuration
dynamodb_table_name = "url-shortener"
dynamodb_billing_mode = "PAY_PER_REQUEST"
# ... other settings
```

**Important:** Never commit the `terraform.tfvars` file to version control. It's already in `.gitignore`.

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review the Plan

```bash
terraform plan
```

Or save the plan to a file for later application:

```bash
terraform plan -out=tfplan
```

### 4. Apply the Configuration

```bash
terraform apply
```

Or apply a saved plan:

```bash
terraform apply tfplan
```

Type `yes` when prompted to create the resources (unless using a saved plan).

## Resources Created

### DynamoDB Module (`dynamodb/`)

- **DynamoDB Table**: `url-shortener` (or name specified in variables)
  - Hash key: `short_code` (String)
  - Billing mode: Pay-per-request (default) or Provisioned
  - Server-side encryption enabled by default

### Lambda Module (`lambda/`)

- **IAM Role**: Execution role for Lambda functions with DynamoDB and CloudWatch Logs permissions
- **Lambda Function (shorten)**: Creates shortened URLs
  - Runtime: Node.js 18.x (configurable)
  - Timeout: 30 seconds (configurable)
  - Memory: 128 MB (configurable)
- **Lambda Function (redirect)**: Redirects short codes to original URLs
  - Runtime: Node.js 18.x (configurable)
  - Timeout: 30 seconds (configurable)
  - Memory: 128 MB (configurable)

**IAM Permissions:**
- DynamoDB: GetItem, PutItem, UpdateItem, Query, Scan
- CloudWatch Logs: CreateLogGroup, CreateLogStream, PutLogEvents

### API Gateway Module (`api-gateway/`)

- **API Gateway REST API**: RESTful API for URL shortener service
- **POST /shorten Endpoint**: Creates shortened URLs
- **OPTIONS /shorten Endpoint**: CORS preflight handler
- **Lambda Integration**: Integrated with shorten Lambda function
- **Deployment & Stage**: Configured with dev stage (configurable)

**Features:**
- CORS enabled for all origins
- AWS_PROXY integration with Lambda
- Automatic deployment on configuration changes

## Outputs

After applying, Terraform will output:
- DynamoDB table name, ARN, and ID
- Lambda function names, ARNs, and invoke ARNs (for API Gateway integration)
- Lambda execution role ARN
- API Gateway ID, ARN, and invoke URL
- API Gateway shorten endpoint URL (ready to use)

## Destroying Resources

To remove all created resources:

```bash
terraform destroy
```

## Variables

See `variables.tf` for all available variables and their descriptions.

Key variables:

**Shared Variables:**
- `aws_region`: AWS region (default: us-east-1)
- `environment`: Environment name (dev, staging, prod)
- `project_name`: Project name for tagging (default: url-shortener)

**DynamoDB Variables:**
- `dynamodb_table_name`: Name of the table (default: url-shortener)
- `dynamodb_billing_mode`: PAY_PER_REQUEST or PROVISIONED
- `dynamodb_enable_encryption`: Enable server-side encryption (default: true)
- `dynamodb_enable_point_in_time_recovery`: Enable PITR (default: false)
- `dynamodb_read_capacity`: Read capacity (if using PROVISIONED mode)
- `dynamodb_write_capacity`: Write capacity (if using PROVISIONED mode)

**Lambda Variables:**
- `lambda_shorten_function_source_path`: Path to shorten function (default: ../backend/functions/shorten)
- `lambda_redirect_function_source_path`: Path to redirect function (default: ../backend/functions/redirect)
- `lambda_runtime`: Lambda runtime version (default: nodejs18.x)
- `lambda_timeout`: Function timeout in seconds (default: 30)
- `lambda_memory_size`: Memory size in MB (default: 128)
- `lambda_base_url`: Base URL for shortened links (default: https://myapp.com)
- `lambda_default_redirect_url`: Default redirect URL (default: https://myapp.com)

**API Gateway Variables:**
- `api_gateway_name`: Name of the API Gateway (default: url-shortener-api)
- `api_gateway_description`: Description of the API Gateway
- `api_gateway_endpoint_type`: REGIONAL, EDGE, or PRIVATE (default: REGIONAL)
- `api_gateway_stage_name`: Stage name (default: dev)

## Security Notes

- **Never commit `terraform.tfvars` files containing credentials** - They are already in `.gitignore`
- Use IAM roles and policies to limit permissions
- For production, consider using:
  - AWS Secrets Manager or Parameter Store for credentials
  - IAM roles instead of access keys when possible
  - Terraform Cloud/Enterprise for remote state and variable management
- Enable point-in-time recovery for production environments
- Review and rotate credentials regularly

