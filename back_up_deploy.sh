#!/bin/bash

# Set the working directory to the misc/ folder for the bucket-statefile-setup
cd misc/

# Step 1: Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Step 2: Apply Terraform to set up the bucket statefile
echo "Applying Terraform changes..."
terraform apply -auto-approve

# Move to the tf/ directory for aws-infra-setup
cd ../tf/

# Step 3: Initialize Terraform for AWS infrastructure setup
echo "Initializing Terraform for AWS infrastructure setup..."
terraform init

# Step 4: Plan the Terraform changes
echo "Planning Terraform changes..."
terraform refresh
terraform plan -out=tfplan

# Step 5: Apply Terraform changes for AWS infrastructure setup
echo "Applying Terraform changes for AWS infrastructure..."
terraform apply -auto-approve

# Save the ALB DNS value to a file
echo "Saving ALB DNS value..."
alb_dns=$(terraform output -raw alb_dns)
echo "alb_dns=$alb_dns" > alb_dns.txt

# Step 6: Move to the ansible/ directory for ansible-docker-setup
cd ../ansible/

# Step 7: Initialize Terraform and generate the Ansible inventory file
echo "Initializing Terraform and generating Ansible inventory..."
cd ../tf
terraform init
chmod +x generate_inventory_jq.sh
./generate_inventory_jq.sh

# Verify if the Ansible inventory file exists and is not empty
if [ -f "./inventory.ini" ]; then
    echo "inventory.ini found"
    cat ./inventory.ini
else
    echo "inventory.ini not found"
fi

# Step 8: Install Ansible and Python3
echo "Installing Ansible and Python3..."
sudo apt-get update && sudo apt-get install -y ansible python3-pip
ansible-galaxy collection install community.docker

# Step 9: Check if containers are running
echo "Checking if containers are running..."
result=$(ansible -i ./inventory.ini -m shell -a "docker ps" all)

app_running=$(echo "$result" | grep -q 'foo_app.*running' && echo true || echo false)
db_running=$(echo "$result" | grep -q 'foo_db.*running' && echo true || echo false)

# Step 10: Install required services if not running
if [ "$app_running" != "true" ] || [ "$db_running" != "true" ]; then
    echo "Services not running, installing required services..."
    sleep 20  # Wait for services to start
    ansible-playbook -i ./inventory.ini install_docker_db_sql.yml
else
    echo "Services already running."
fi

# Wait for services to start
echo "Waiting for services to start..."
sleep 15
