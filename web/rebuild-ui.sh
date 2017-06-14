#!/bin/sh
echo "Stopping all docker containers..."
docker-compose stop

echo "Removing web UI dashboard container..."
docker-compose rm -f dashboard

echo "Pulling web UI dashboard container..."
docker-compose pull dashboard

echo "Bringing up containers with docker-compose..."
docker-compose up -d

echo "Verify all containers are running. Use docker-compose logs -t <container> if needed..."
docker-compose ps

