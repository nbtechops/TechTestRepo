# Steps to test app on local docker

## Init Container
docker run -itd --rm --name techtestapp-init \
-p 3000:3000 \
-e VTT_DBUSER=postgres \
-e VTT_DBPASSWORD=changeme \
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
-e VTT_DBPASSWORD=changeme \
-e VTT_DBNAME=postgres \
-e VTT_DBPORT=5432 \
-e VTT_DBHOST=<rds-url> \
-e VTT_LISTENHOST=0.0.0.0 \
-e VTT_LISTENPORT=3000 \
techtestapp:latest serve

