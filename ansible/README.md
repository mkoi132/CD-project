# ANSIBLE CONFIGURATIONS

_Overview: This directory contains seperated all-Ansible configurations, so that it less likely to mixed up when running GitHub Action Jobs_

## Directory Structure

### inventory.ini

The `inventory.ini` is _preview only_, the deployment version of it will be dynamically generated in the runner with actual hosts from terraform-created infrastructure.

### install_docker_db_sql.yml

This ansible playbook does the following: Installs Docker and necessary dependencies on all hosts, and sets up a PostgreSQL container with a data snapshot on the db host.
Beakdown:

- Installs Docker and Python's Docker module.
- Adds the ubuntu user to the Docker group.
- Sets up a PostgreSQL container with an initialized SQL data snapshot on the db host.
- Pulls and runs pre-built application container on the app host with the database connection information.

### ansible.cfg

Configures Ansible to use the AWS EC2 plugin and Python interpreter (python3).

### ec2_plugin.yml

Defines the AWS EC2 plugin configuration, specifying the regions to scan for EC2 instances, in addition to the ansible.cfg

## How to use

### Prerequisites

- Ensure AWS and credentials are properly configured for environment.
- Terraform infrastructure ready and generate required `inventory.ini` file. This must be placed in the same ansible directory.
- The Ansible control node (whatever it runs on) should have the necessary privileges (aka SSH private key pair configured) to SSH into the EC2 instances that spin up using Terraform earlier.
- Ansible and its required dependencies should be installed.

**IMPORTANT LIMITATION**- The private key pair of the one used for terraform infrastructure _must_ be store at `~/.ssh/` **AND** under the name `github_sdo_key`. Please attempt to _relocate and rename_ it otherwise this configuration would throw an error while executing.
This limitation is due to the inventory file is currently being hard-coded into the directory via a script execution. This is a temporary solution and could be fixed in the future.

### GitHub Actions pipeline integration (IN USE)

This playbook can be executed from a workflow runner. [See workflow description](../)

### CLI and script (OPTIONAL)

- Ensure to have the correct SSH private key pair load into location specified in **inventory.ini**. Its public pair was used when terraform creating EC2 instance.
- Then execute the script `ansible-playbook -i ./inventory.ini install_docker_db_sql.yml`
