# Steps to test app on local docker and to build AMI

## Docker build
docker build . -t techtestapp:latest
docker tag techtestapp:latest 487042587946.dkr.ecr.ap-southeast-2.amazonaws.com/projectx/techtestapp:v1
docker push 487042587946.dkr.ecr.ap-southeast-2.amazonaws.com/projectx/techtestapp:v1

## ECR Login
aws ecr get-login-password | docker login --username AWS --password-stdin 487042587946.dkr.ecr.ap-southeast-2.amazonaws.com/projectx/techtestapp

docker build -t projectx/techtestapp .

docker tag projectx/techtestapp:latest 487042587946.dkr.ecr.ap-southeast-2.amazonaws.com/projectx/techtestapp:latest

docker push 487042587946.dkr.ecr.ap-southeast-2.amazonaws.com/projectx/techtestapp:latest

## Init Container
docker run -itd --rm --name techtestapp-init \
-p 3000:3000 \
-e VTT_DBUSER=postgres \
-e VTT_DBPASSWORD=xxx \
-e VTT_DBNAME=postgres \
-e VTT_DBPORT=5432 \
-e VTT_DBHOST=<rds-url> \
-e VTT_LISTENHOST=0.0.0.0 \
-e VTT_LISTENPORT=3000 \
techtestapp:latest updatedb -s

## App Container
docker run -itd --name techtestapp \
-p 3000:3000 \
-e VTT_DBUSER=postgres \
-e VTT_DBPASSWORD=xxx \
-e VTT_DBNAME=postgres \
-e VTT_DBPORT=5432 \
-e VTT_DBHOST=<rds-url> \
-e VTT_LISTENHOST=0.0.0.0 \
-e VTT_LISTENPORT=3000 \
techtestapp:latest serve

## postgres
docker run --name pg-docker -e POSTGRES_PASSWORD=xxx -d -p 5432:5432 postgres

## utilities
yum install -y wget \
    unzip

## EPEL
yum install -y epel-release 

## Update
yum update -y

## Docker Install
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce \
    docker-ce-cli \
    containerd.io
systemctl start docker

## Install git
yum install git -y

## Install terraform
curl -O https://releases.hashicorp.com/terraform/0.12.2/terraform_0.12.2_linux_amd64.zip
unzip terraform_0.12.2_linux_amd64.zip
cp terraform /usr/local/bin/
export PATH=$PATH:/usr/local/bin
terraform –v

## Jenkins Install
yum install -y java-1.8.0-openjdk.x86_64
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install -y jenkins
systemctl start jenkins.service
systemctl enable jenkins.service
groupadd docker || true
usermod -aG docker jenkins

## AWS CLI Install
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
export PATH=$PATH:/usr/local/bin