provider "aws" {
  region = "us-east-1"
}

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

resource "aws_key_pair" "admin" {
  key_name   = "admin-key-assgimeng2"
  public_key = file("~/.ssh/github_sdo_key.pub")
}


resource "aws_instance" "app" {
  associate_public_ip_address = true
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.admin.key_name
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  user_data                   = <<-EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install ansible -y
EOF 
  user_data_replace_on_change = true
  tags = {
    Name = "app server"
  }
}

resource "aws_security_group" "app_sg" {
  name = "app_sg"
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

  # Allow outbound traffic on TCP port 443
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS to anywhere
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "app_public_dns" {
  value = aws_instance.app.public_dns
  description = "Public DNS of the application instance"
}
