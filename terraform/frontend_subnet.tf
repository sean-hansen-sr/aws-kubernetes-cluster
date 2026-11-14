# Create a Private Frontend Subnet (No Internet Gateway)
resource "aws_subnet" "private_frontend" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "private-frontend-subnet"
  }
}

# Route Table for Private Frontend Subnet (Routes outbound traffic to the NAT Gateway)
resource "aws_route_table" "private_frontend" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "private-frontend-route-table" }
}

resource "aws_route_table_association" "private_frontend" {
  subnet_id      = aws_subnet.private_frontend.id
  route_table_id = aws_route_table.private_frontend.id
}

# Create a Security Group
resource "aws_security_group" "private_frontend_sg" {
  name        = "private-frontend-ubuntu-sg"
  description = "Allow internal traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  
  ingress {
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-frontend-ubuntu-sg"
  }
}