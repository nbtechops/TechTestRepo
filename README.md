# TechTestRepo

## Pre-reqs
- terraform
- public key for EC2 access (Create a public/private SSH key pair using ssh-keygen -t rsa). Refer https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair

## Inputs
- username and password to set for the database
- public key for EC2 (in format "ssh-rsa xxxxxxxxxxxxxxxxxx")

## Usage
- git clone
- terraform init
- terraform plan (supply db_user, db_password and ssh_key)
- terraform apply (supply db_user, db_password and ssh_key)
- check the output for URLs for Jenkins, App and ELB. URLs will be accesible within 2-5 mins on specified ports

## Cleanup
- terraform destroy

## Outputs
- app_hostname (EC2 link accessible on port 3000)
- db_hostname (in secured zone, only access through app subnet)
- elb_dnsname (ELB link accessible on port 3000)
- jenkins_url (link accesible on port 8080 of EC2)
- ssh login to EC2 instance: ssh -i <priv_key_file> centos@app_hostname

## Network Segmentation
- Through different subnets for App and DB
- Security groups define which ports allowed

## More details
- Refer to DECISIONS.md