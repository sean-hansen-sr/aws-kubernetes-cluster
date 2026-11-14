# Create an Internal Network Load Balancer
resource "aws_lb" "backend_nlb" {
  name               = "backend-cluster-nlb"
  internal           = true
  load_balancer_type = "network"
  
  subnet_mapping {
    subnet_id     = aws_subnet.private_frontend.id
    private_ipv4_address = var.backend_nlb_private_ip
  }

  tags = {
    Name = "backend-cluster-nlb"
  }
}

# Target Group for the Backend Cluster
resource "aws_lb_target_group" "backend_tg" {
  name        = "backend-cluster-tg"
  port        = 30080
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
  }

  tags = {
    Name = "backend-cluster-tg"
  }
}

# NLB Listener
resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_nlb.arn
  port              = 30080
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

# Attach the 2 Worker Nodes to the Target Group
resource "aws_lb_target_group_attachment" "backend_nodes" {
  count            = length(aws_instance.ubuntu_backend_vm) - 1
  target_group_arn = aws_lb_target_group.backend_tg.arn
  target_id        = aws_instance.ubuntu_backend_vm[count.index + 1].id
  port             = 30080
}
