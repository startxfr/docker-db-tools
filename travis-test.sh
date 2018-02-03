#!/bin/bash

echo "=================> STARTING TEST"
echo "=================> SETUP TEST ENVIRONMENT"
set -ev

echo "INFO: Updating docker configuration (experimental)"
echo '{ "experimental": true, "storage-driver": "overlay2", "max-concurrent-downloads": 50, "max-concurrent-uploads": 50 }' | sudo tee /etc/docker/daemon.json
sudo service docker restart

echo "========> BUILDING APPLICATIONS Containers (dev)"
sudo docker-compose -f travis-docker-compose.yml build

echo "========> STARTING DATABASE Containers (dev)"
sudo docker-compose -f travis-docker-compose.yml up -d db-mysql db-couchbase
sudo docker-compose logs --tail=500

echo "========> waiting for database startup (90sec)" && sleep 10
echo "========> waiting for database startup (80sec)" && sleep 10
echo "========> waiting for database startup (70sec)" && sleep 10
echo "========> waiting for database startup (60sec)" && sleep 10
echo "========> waiting for database startup (50sec)" && sleep 10
echo "========> waiting for database startup (40sec)" && sleep 10
echo "========> waiting for database startup (30sec)" && sleep 10
echo "========> waiting for database startup (20sec)" && sleep 10
echo "========> waiting for database startup (10sec)" && sleep 10
echo "========> waiting for database startup (0sec)"

echo "========> STARTING APPLICATION Containers (dev)"
echo "========> Testing container info"
sudo docker-compose -f travis-docker-compose.yml up app-info
sleep 2
echo "========> Testing container create all database(s), user(s) and data"
sudo docker-compose -f travis-docker-compose.yml up app-create
sleep 2
echo "========> Testing container delete all database(s), user(s) and data"
sudo docker-compose -f travis-docker-compose.yml up app-delete

echo "========> END TESTING APPLICATIONS"
exit 0;