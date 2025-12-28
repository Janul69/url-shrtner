# Importing Existing Resources

If you have resources that were created outside of Terraform, you need to import them into Terraform state.

## Import Existing DynamoDB Table

If you already have a DynamoDB table named `url-shortener`, import it with:

```bash
terraform import module.dynamodb.aws_dynamodb_table.url_shortener url-shortener
```

**Note:** Make sure your `terraform.tfvars` configuration matches the existing table's settings (billing mode, encryption, etc.) before importing.

## After Import

1. Run `terraform plan` to verify the configuration matches the existing resource
2. If there are differences, Terraform will show what needs to be updated
3. Run `terraform apply` to sync any configuration differences

## Verify Table Configuration

Before importing, verify your table configuration matches:
- Table name: `url-shortener`
- Hash key: `short_code` (String)
- Billing mode: Should match your `dynamodb_billing_mode` variable
- Encryption: Should match your `dynamodb_enable_encryption` variable

