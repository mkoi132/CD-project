output "vm_public_hostname" {
  value = [for instance in aws_instance.app : instance.public_dns]
}

output "app_public_ip" {
  value = [for instance in aws_instance.app : instance.public_ip]
}

output "db_private_ip" {
  value = aws_instance.db.private_ip
}

output "app_ec2" {
  value = aws_instance.app
}