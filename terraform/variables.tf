# Fetch current AWS account ID
data "aws_caller_identity" "current" {}

# Get Latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu_image" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
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

# Availability Zone Variable
variable "availability_zone" {
  type    = string
  default = "us-east-1a"
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

# Kubernetes Frontend Cluster Private IP Addresses
variable "kubernetes_private_frontend_ips" {
  type    = list(string)
  default = ["10.0.2.10", "10.0.2.11", "10.0.2.12"]
}

# Internal Network Load Balancer Private IP Addresse
variable "backend_nlb_private_ip" {
  type = string
  default = "10.0.2.9"
}

variable "frontend_nlb_private_ip" {
  type = string
  default = "10.0.1.9"
}

# EC2 Setting Values
variable "ec2_setting_values" {
  type             = map(string)
  description      = "A map of EC2 setting values"
  
  default = {
    ami            = "ami-09c99d62ef07e4dd9"
    instance_type  = "t4g.medium"
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