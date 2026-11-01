# IAM Role for EC2
resource "aws_iam_role" "ec2_ssm_ecr_role" {
  name = "ec2-ecr-ssm-reader-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Access to agent storage table
resource "aws_iam_role_policy" "dynamodb_read_write" {
  name = "ec2-dynamodb-read-write-policy"
  role = aws_iam_role.ec2_ssm_ecr_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query"
        ]
        Resource = [
          var.agent_storage_table_values["arn_table"],
          var.agent_storage_table_values["arn_table_index"]
        ]
      }
    ]
  })
}

# Attach the Managed Policy for ECR Read-Only access
resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_ssm_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Attach the AmazonSSMManagedInstanceCore policy
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm_ecr_role.name
}
