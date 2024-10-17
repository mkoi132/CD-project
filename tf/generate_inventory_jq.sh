#!/bin/bash

# Update the terraform-output.json file with the latest Terraform outputs
terraform output -json > terraform-output.json

# Extract the public IPs of the app instances and the private IP of the database from the Terraform output
app_public_ips=$(jq -r '.app_public_ip.value | to_entries[] | .value' terraform-output.json)
db_private_ip=$(jq -r '.db_private_ip.value // empty' terraform-output.json)


# If db_private_ip is empty, handle the error
if [ -z "$db_private_ip" ]; then
  echo "Error: Could not extract DB private IP. Please check the Terraform output."
  exit 1
fi

# Get the first app public IP to use as the bastion host IP
bastion_host_ip=$(echo "$app_public_ips" | head -n 1)

# Create an Ansible inventory file with both app and db groups
cat <<EOL > ../ansible/inventory.ini
[bastion]
$bastion_host_ip
[app]
$app_public_ips

[app:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/github_sdo_key
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[db]
$db_private_ip

[db:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/github_sdo_key
ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -i ~/.ssh/github_sdo_key -W %h:%p -q ubuntu@$bastion_host_ip" -o StrictHostKeyChecking=no'

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOL

echo "Ansible inventory has been generated and saved as 'inventory.ini'."
