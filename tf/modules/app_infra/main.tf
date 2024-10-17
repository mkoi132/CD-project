data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}
resource "aws_instance" "app" {
  count = 2
  associate_public_ip_address = true
  subnet_id = var.public_subnet_id[count.index]
  availability_zone  = var.availability_zones[count.index]
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.admin.key_name
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  user_data                   = <<-EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install ansible -y
EOF 
  user_data_replace_on_change = true
  tags = {
    Name = "${var.app_name} server"
  }
}

# Single EC2 instance for the database
resource "aws_instance" "db" {
  associate_public_ip_address = false  # No public IP since it's in a private subnet
  subnet_id                   = var.private_subnet_id
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.admin.key_name
  vpc_security_group_ids             = [aws_security_group.db_sg.id]
  
  # Install Ansible via user_data
  user_data                   = <<-EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install ansible -y
EOF
  user_data_replace_on_change = true

  tags = {
    Name = "${var.app_name} db-instance"
  }
}


resource "aws_key_pair" "admin" {
  key_name   = "admin-key-${var.app_name}"
  public_key = file("${var.path_to_public_key}")
}

resource "aws_security_group" "app_sg" {
  vpc_id = var.vpc_id
  name = "app_sg"
  # Allow traffic from the ALB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = var.alb_sg  # Allow traffic only from the ALB SG
  }
    dynamic "ingress" {
      iterator = port
      for_each = var.app_ingressRule
      content {
        from_port   = port.value
        to_port     = port.value
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for the DB instance in the private subnet
resource "aws_security_group" "db_sg" {
  vpc_id = var.vpc_id
  name   = "db_sg" 
  # allowing ssh traffic from bastion host (but in private network)
  # so that ansible can access it from outside, through ssh port forwarding
  dynamic "ingress" {
    iterator = port
    for_each = var.db_ingressRule
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"] #vpc internal network
    }
  }

  # Allow traffic from the app security group
  ingress {
    from_port                = var.db_port
    to_port                  = var.db_port
    protocol                 = "tcp"
    security_groups  = [aws_security_group.app_sg.id]
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db_security_group_${var.app_name}"
  }
}

