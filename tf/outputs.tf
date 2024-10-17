output "public_subnet" {
  value = { for idx, subnet in module.subnets.public_subnets : "public subnet ${idx + 1}" => subnet.id }
}

output "app_public_ip" {
  value = { for idx, public_ip in module.app_infra.app_public_ip : "app ${idx + 1}" => public_ip }
}

output "db_private_ip" {
  value = module.app_infra.db_private_ip
}

# output "db_instance_private_ip" {
#   value = aws_instance.db.private_ip
# }

output "alb_dns" {
  value = module.load_balancer.load_balancer_dns
}