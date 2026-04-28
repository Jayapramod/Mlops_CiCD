# ---------------------------------------------------------------------------
# Application Load Balancer
# ---------------------------------------------------------------------------
resource "aws_lb" "agrox" {
  name               = "${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_az1.id, aws_subnet.public_az2.id]

  enable_deletion_protection = false

  tags = {
    Name      = "${var.cluster_name}-alb"
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Target Group for ECS Services
# ---------------------------------------------------------------------------
resource "aws_lb_target_group" "agrox" {
  name        = "${var.cluster_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.agrox.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name      = "${var.cluster_name}-tg"
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# ALB Listener
# ---------------------------------------------------------------------------
resource "aws_lb_listener" "agrox" {
  load_balancer_arn = aws_lb.agrox.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.agrox.arn
  }
}
