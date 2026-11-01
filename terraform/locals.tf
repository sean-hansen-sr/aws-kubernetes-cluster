# Environment Variable
variable "environment" {
  type    = string
  default = "development"
}

# Kubernetes Cluster Private IP Addresses
variable "kubernetes_private_ips" {
  type    = list(string)
  default = ["10.0.2.10", "10.0.2.11", "10.0.2.12"]
}

# EC2 Setting Values
variable "ec2_setting_values" {
  type             = map(string)
  description      = "A map of EC2 setting values"
  
  default = {
    ami            = "ami-033ea4ff4a9c726dc"
    instance_type  = "t3.small"
  }
}

# Agent storage table values
variable "agent_storage_table_values" {
  type              = map(string)
  description       = "A map of agent storage table values"

  default = {
    name            = "agent-sessions-table"
    arn_table       = "arn:aws:dynamodb:*:*:table/agent-sessions-table"
    arn_table_index = "arn:aws:dynamodb:*:*:table/agent-sessions-table/index/*"
  }

}