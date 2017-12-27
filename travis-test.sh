#!/bin/bash

echo "=================> STARTING TEST"
echo "=================> SETUP TEST ENVIRONMENT"
set -ev

echo "========> BUILDING APPLICATIONS Containers (dev)"
sudo docker-compose build

echo "========> STARTING DATABASE Containers (dev)"
sudo docker-compose up -d db-mysql db-couchbase
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
sudo docker-compose up -d app pma
sudo docker-compose logs --tail=500

echo "========> TESTING APPLICATIONS"
curl -I http://localhost:1901 && echo ""
curl -I http://localhost:8091 && echo ""

echo "========> END TESTING APPLICATIONS"
exit 0;