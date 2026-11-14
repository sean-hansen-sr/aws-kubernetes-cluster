# Create a Private Backend Subnet (No Internet Gateway)
resource "aws_subnet" "private_backend" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "private-backend-subnet"
  }
}

# Route Table for Private Backend Subnet (Routes outbound traffic to the NAT Gateway)
resource "aws_route_table" "private_backend" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "private-backend-route-table" }
}

resource "aws_route_table_association" "private_backend" {
  subnet_id      = aws_subnet.private_backend.id
  route_table_id = aws_route_table.private_backend.id
}

# Create a Security Group
resource "aws_security_group" "private_backend_sg" {
  name        = "private-backend-ubuntu-sg"
  description = "Allow internal traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Allow NLB health checks and traffic on port 30080 from Private Frontend & Private Backend Subnet
  ingress {
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_frontend.cidr_block, aws_subnet.private_backend.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-backend-ubuntu-sg"
  }
}