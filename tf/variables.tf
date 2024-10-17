variable "vpc_cidr_blocks" {
  description = "My VPC cidr blocks"
}
variable "private_subnet_cidrs" {}
variable "public_subnet_cidrs" {}
variable "env_prefix" {}
variable "app_name" {}
variable "instance_type" {}
variable "db_port" {}
variable "app_ingressRule" {}
variable "db_ingressRule" {}
variable "alb_ingressRule" {}
variable my_region {}
variable "path_to_public_key" {}
