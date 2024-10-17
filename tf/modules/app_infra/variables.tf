variable "app_ingressRule" {
  type        = list(number)
  # default     = [22, 80, 443, 3000, 5432] 
  description = "ingress fules for app instance sg"
}
variable path_to_public_key{}
variable db_ingressRule {}
variable db_port{}
variable instance_type {}
variable vpc_id {}
variable app_name {}
variable public_subnet_id {}
variable private_subnet_id {}
variable availability_zones {
  type = list(string)
}
variable alb_sg {}

#defines in main `.tfvars`