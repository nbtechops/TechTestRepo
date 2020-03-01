# Steps to test app on local docker

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

## Test DB
psql -h localhost -U postgres -d postgres