# Create a Private Backend Subnet (No Internet Gateway)
resource "aws_subnet" "private_backend" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

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
  
  # Allow TCP Port 179 (BGP)
  ingress {
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    self        = true
  }

  # Allow UDP Port 4789 (Calico VXLAN overlay network)
  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    self        = true
  }

  # Allow TCP Port 5473 (Calico Typha communication)
  ingress {
    from_port   = 5473
    to_port     = 5473
    protocol    = "tcp"
    self        = true
  }

  # Allow TCP Port 6443 (Kubernetes API server)
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    self        = true
  }

  # Allow UDP Port 51820 & 51821 (Calico WireGuard encryption)
  ingress {
    from_port   = 51820
    to_port     = 51821
    protocol    = "udp"
    self        = true
  }

  # Allow IP-in-IP (IP Protocol 4) encapsulation
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "4" # Protocol 4 represents IP-in-IP
    self        = true
  }

  # All NodePort services (30000-32767) for Kubernetes
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow direct access to the application port for testing
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
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