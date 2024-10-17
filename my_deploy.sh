#!/bin/bash
set -e
cd ./one-instance
echo "$(pwd)"
terraform apply --auto-approve

# Check the exit status of terraform apply
if [ $? -eq 0 ]; then
  echo "Terraform applied successfully. Generating inventory..."
  sleep 30
  ansible-playbook -i ansible-inventory.ini ansible-install.yml
  else
    echo "Error. Exiting..."
    exit 1
fi
public_dns=$(terraform output -raw app_public_dns)  # Fetch the public DNS
echo "Public DNS of the application instance: $public_dns"