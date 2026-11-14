# Bedrock Agent DynamoDB Storage Table
resource "aws_dynamodb_table" "agent_storage" {
  name         = var.agent_storage_table_values["name"]
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  # Enables Time to Live (TTL)
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  # Encrypts data at rest using an AWS-managed KMS key
  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = var.agent_storage_table_values["name"]
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}