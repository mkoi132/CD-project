#!/bin/bash
## DUE TO SIMPLE SET UP, THIS SCRIPT IS NO LONGER IN NEED, BUT IS KEPT HERE FOR FURTHER PROJECT DEVELOP
terraform output > terraform-output.txt

# Input and Output files
TF_OUTPUT="terraform_output.txt"
INVENTORY_FILE="../ansible/inventory_aws_ec2.yml"

# Extract values from terraform_output.txt
APP_PUBLIC_IPS=$(grep -A 2 "app_public_ip" $TF_OUTPUT | grep -oP '\d+\.\d+\.\d+\.\d+')
DB_PRIVATE_IP=$(grep "db_private_ip" $TF_OUTPUT | grep -oP '\d+\.\d+\.\d+\.\d+')

# AWS region and key file (adjust if necessary)
AWS_REGION="us-east-1"
KEY_FILE="~/.ssh/github_sdo_key"

# Begin writing the inventory file
echo "plugin: aws_ec2" > $INVENTORY_FILE
echo "regions:" >> $INVENTORY_FILE
echo "  - $AWS_REGION  # Specify region" >> $INVENTORY_FILE
echo "filters:" >> $INVENTORY_FILE
echo "  tag:Name: app-server  # Optional: filter instances by tag" >> $INVENTORY_FILE
echo "keyed_groups:" >> $INVENTORY_FILE
echo "  - key: tags.Name  # Group by tags for EC2 instances" >> $INVENTORY_FILE
echo "hostnames:" >> $INVENTORY_FILE
echo "  - public-ip-address  # Use the public IP as the hostname" >> $INVENTORY_FILE
echo "compose:" >> $INVENTORY_FILE
echo "  ansible_host: public-ip-address  # Maps the public IP to ansible_host" >> $INVENTORY_FILE
echo "  ansible_user: ubuntu  # Set the SSH user for instances" >> $INVENTORY_FILE
echo "  ansible_ssh_private_key_file: $KEY_FILE  # Path to SSH key" >> $INVENTORY_FILE
echo "" >> $INVENTORY_FILE

# Add app group with public IPs
echo "groups:" >> $INVENTORY_FILE
echo "  app:" >> $INVENTORY_FILE
echo "    hosts:" >> $INVENTORY_FILE
for ip in $APP_PUBLIC_IPS; do
  echo "      - $ip" >> $INVENTORY_FILE
done

# Add db group with private IP
echo "  db:" >> $INVENTORY_FILE
echo "    hosts:" >> $INVENTORY_FILE
echo "      - $DB_PRIVATE_IP" >> $INVENTORY_FILE

# Display success message
echo "Inventory file $INVENTORY_FILE has been generated."

## DUE TO SIMPLE SET UP, THIS SCRIPT IS NO LONGER IN NEED, BUT IS KEPT HERE FOR FURTHER PROJECT DEVELOP
