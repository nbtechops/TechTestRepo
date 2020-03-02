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

## Outputs
- app_hostname
- db_hostname
- elb_dnsname
- jenkins_url

## Features
- 

