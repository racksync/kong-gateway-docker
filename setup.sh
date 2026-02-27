#!/usr/bin/env bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for .env file
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  No .env file found, copying default.env to .env${NC}"
    cp default.env .env
fi

# Start timing
start_time=$(date +%s)

echo -e "${BLUE}🐋 Starting the kong-database${NC}"
docker compose up -d kong-database

echo -e "${BLUE}⏳ Waiting for kong-database to become healthy...${NC}"
while ! docker compose ps kong-database | grep -q "(healthy)"; do
  sleep 5
done

echo -e "${BLUE}🔄 Running the kong-migrations${NC}"
docker compose run --rm kong-migrations

echo -e "${BLUE}🚀 Starting kong${NC}"
docker compose up -d kong

echo -e "${BLUE}⏳ Waiting for kong to become healthy...${NC}"
while ! docker compose ps kong | grep -q "(healthy)"; do
  sleep 5
done

echo -e "${GREEN}✨ Kong is running on:${NC}"
echo -e "${GREEN}   Proxy:     http://localhost:8000  (SSL: https://localhost:8443)${NC}"
echo -e "${GREEN}   Admin API: http://localhost:8001  (SSL: https://localhost:8444)${NC}"
echo -e "${GREEN}   Manager:   http://localhost:8002  (SSL: https://localhost:8445)${NC}"

# Calculate and display duration
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))
echo ""
echo -e "${GREEN}✅ Setup completed in ${minutes}m ${seconds}s${NC}"
