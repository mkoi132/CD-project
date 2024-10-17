output "alb_sg" {
  value = aws_security_group.alb_sg
}

output "load_balancer_dns" {
    value = aws_lb.alb_public_sub.dns_name
}