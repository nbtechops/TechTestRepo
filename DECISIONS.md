# Deecisions

## AWS resources will be deployed by terraform
 - User to clone this repo and update AWS env variables (AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION)
 - User to install terraform on his machine
 - User to populate tfvars

## Terraform will create EC2, RDS, ELB
 - EC2 instance to have docker, java, AWS CLI, git, jenkins installed
 - EC2 created form pre baked AMI
 - Tried approach for Chef provisioner for EC2 but time consuming - hence pre baked AMI
 - EC2 will run Jenkins when it starts. Jenkins will hourly build the TechTestApp repo and do docker build
 - Code for push to ECR tested
 - Currently same EC2 to build image and run image
 - Postgres DB needs initialised first (so the container must be run twice?)
 - Jenkins runs on port 8080 
 - Vibrato App runs on port 3000
 - Jenkins has a pre-baked job to recreate init container and service containers after every stipulated time
 - Terraform will prompt for all input details
 - Hardcoded the region as AMI not available in all regions