provider "aws" {
  region = var.my_region
}

terraform {
  backend "s3" {
    bucket         = "state-bucket-3480999"         
    key            = "terraform/state.tfstate" 
    region         = "us-east-1"          
    dynamodb_table = "foostatelock"            
    encrypt        = true                      
  }
}


resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr_blocks
  enable_dns_hostnames = true
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}

module "subnets" {
  source               = "./modules/subnets"
  public_subnet_cidrs  = var.public_subnet_cidrs
  env_prefix           = var.env_prefix
  vpc_id               = aws_vpc.my_vpc.id
  private_subnet_cidrs = var.private_subnet_cidrs
  db_port              = var.db_port

}



module "app_infra" {
  source             = "./modules/app_infra"
  app_name           = var.app_name
  instance_type      = var.instance_type
  public_subnet_id   = [for subnet in module.subnets.public_subnets : subnet.id]
  private_subnet_id  = module.subnets.private_subnets.id
  availability_zones = module.subnets.availability_zones
  vpc_id             = aws_vpc.my_vpc.id
  db_port            = var.db_port
  app_ingressRule    = var.app_ingressRule
  db_ingressRule     = var.db_ingressRule
  alb_sg             = [module.load_balancer.alb_sg.id]
  path_to_public_key = var.path_to_public_key
}

module "load_balancer" {
  source           = "./modules/load_balancer"
  app_name         = var.app_name
  alb_ingressRule  = var.alb_ingressRule
  vpc_id           = aws_vpc.my_vpc.id
  public_subnet_id = [for subnet in module.subnets.public_subnets : subnet.id]
  aws_instances    = module.app_infra.app_ec2
}
