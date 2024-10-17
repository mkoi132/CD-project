resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible-inventory.ini"
  content = <<-EOF
[app]
${aws_instance.app.public_dns}

[app:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/github_sdo_key
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3
EOF
}
