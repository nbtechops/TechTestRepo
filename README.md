# TechTestRepo

## Pre-reqs
- terraform
- public key for EC2 access (Create a public/private SSH key pair using ssh-keygen -t rsa)

## Inputs
- username and password to set for the database
- public key for EC2 (in format "ssh-rsa xxxxxxxxxxxxxxxxxx")

## Usage
- git clone
- terraform init
- terraform plan (supply db_user, db_password and ssh_key)
- terraform apply (supply db_user, db_password and ssh_key)
- check the output for URLs for Jenkins, App and ELB. URLs will be accesible within 2-5 mins on specified ports

## Outputs
- app_hostname (link accessible on port 3000)
- db_hostname
- elb_dnsname (link accessible on port 3000)
- jenkins_url (link accesible on port 8080)

## Network Segmentation
- Through different subnets for App and DB
- Security groups define which ports allowed

