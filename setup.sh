#!/usr/bin/env bash

echo "Starting the kong-database"
docker-compose up -d kong-database

echo "Waiting for kong-database to become healthy..."
while ! docker-compose ps kong-database | grep -q "(healthy)"; do
  sleep 5
done

echo "Running the kong-migrations"
docker-compose run --rm kong-migrations

echo "Starting kong"
docker-compose up -d kong

echo "Waiting for kong to become healthy..."
while ! docker-compose ps kong | grep -q "(healthy)"; do
  sleep 5
done

echo "Kong is running on:"
echo "Admin API: http://localhost:8001"
echo "Proxy: http://localhost:8000"
echo "Manager: http://localhost:8002"