# Fetch current AWS account ID
data "aws_caller_identity" "current" {}

# Get Latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu_latest" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Region Variable
variable "region" {
  type    = string
  default = "us-east-1"
}

# Environment Variable
variable "environment" {
  type    = string
  default = "development"
}

# Kubernetes Backend Cluster Private IP Addresses
variable "kubernetes_private_backend_ips" {
  type    = list(string)
  default = ["10.0.3.10", "10.0.3.11", "10.0.3.12"]
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
    table_arn       = "arn:aws:dynamodb:*:*:table/agent-sessions-table"
    table_index_arn = "arn:aws:dynamodb:*:*:table/agent-sessions-table/index/*"
  }
}