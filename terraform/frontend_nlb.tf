# Internet-Facing Network Load Balancer
resource "aws_lb" "frontend_nlb" {
  name               = "frontend-cluster-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public.id]

  tags = {
    Name = "frontend-cluster-nlb"
  }
}

# Target Group for the Frontend Cluster
resource "aws_lb_target_group" "frontend_tg" {
  name        = "frontend-cluster-tg"
  port        = 30080
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
  }

  tags = {
    Name = "frontend-cluster-tg"
  }
}

# NLB Listener
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

# Attach the 2 Worker Nodes to the Target Group
resource "aws_lb_target_group_attachment" "frontend_worker_nodes" {
  count            = 2
  target_group_arn = aws_lb_target_group.frontend_tg.arn
  target_id        = aws_instance.frontend_vm[count.index + 1].id
  port             = 30080
}