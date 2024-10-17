output "public_subnets" {
    value = aws_subnet.public_subnets
}

output "private_subnets" {
    value = aws_subnet.private_subnet
}

output "availability_zones" {
    value = data.aws_availability_zones.available.names
}
