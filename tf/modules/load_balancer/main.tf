resource "aws_lb" "alb_public_sub" {
  name               = "alb-public"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_id
# subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]

}

resource "aws_lb_target_group" "tg" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    path                = "/health-check"
    port                = "traffic-port"
  }
  tags = {
    Name = "target_group_${var.app_name}"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb_public_sub.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_security_group" "alb_sg" {
  description = "Allow inbound traffic from anywhere on port 80 and 443"
  name        = "alb_sg"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    iterator = port
    for_each = var.alb_ingressRule
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group_attachment" "example" {
  # covert a list of instance objects to a map with instance ID as the key, and an instance
  # object as the value.
  for_each = {
    for idx, instance in var.aws_instances : idx => instance
  }

  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = each.value.id
  port             = 80
}