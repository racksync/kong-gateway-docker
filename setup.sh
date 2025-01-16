#!/usr/bin/env bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Start timing
start_time=$(date +%s)

echo -e "${BLUE}🐋 Starting the kong-database${NC}"
docker-compose up -d kong-database

echo -e "${BLUE}⏳ Waiting for kong-database to become healthy...${NC}"
while ! docker-compose ps kong-database | grep -q "(healthy)"; do
  sleep 5
done

echo -e "${BLUE}🔄 Running the kong-migrations${NC}"
docker-compose run --rm kong-migrations

echo -e "${BLUE}🚀 Starting kong${NC}"
docker-compose up -d kong

echo -e "${BLUE}⏳ Waiting for kong to become healthy...${NC}"
while ! docker-compose ps kong | grep -q "(healthy)"; do
  sleep 5
done

echo -e "${GREEN}✨ Kong is running on:${NC}"
echo -e "${GREEN} Admin API: http://localhost:8001${NC}"
echo -e "${GREEN} Proxy: http://localhost:8000${NC}"
echo -e "${GREEN} Manager: http://localhost:8002${NC}"

# Calculate and display duration
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))
echo ""
echo -e "${GREEN}✅ Setup completed in ${minutes}m ${seconds}s${NC}"