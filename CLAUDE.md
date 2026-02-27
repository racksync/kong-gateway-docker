# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Kong API Gateway Docker deployment using Docker Compose with PostgreSQL backend. Production-ready setup running Kong 3.9 with PostgreSQL 17.

## Commands

### Quick Start
```bash
cp default.env .env      # Configure environment
./setup.sh               # Full automated setup
```

### Manual Deployment
```bash
docker-compose up -d kong-database              # Start database
docker-compose run --rm kong-migrations         # Run migrations
docker-compose up -d kong                       # Start Kong
docker-compose down                             # Stop all services
docker-compose logs -f kong                     # View Kong logs
```

### Health & Status
```bash
curl http://localhost:8001/status               # Kong health check
docker-compose ps                               # Container status
```

### Upgrading Kong
```bash
# 1. Update KONG_VERSION in .env
docker-compose run --rm kong kong migrations up --vv
docker-compose run --rm kong kong migrations finish --vv
docker-compose up -d kong
```

### Database Backup
```bash
docker exec kong-database pg_dump -U kong kong > kong_backup.sql
```

## Architecture

Three services in `docker-compose.yml`:

| Service | Image | Purpose |
|---------|-------|---------|
| kong-database | postgres:17-alpine | Persistent storage |
| kong-migrations | kong:3.9 | One-shot bootstrap |
| kong | kong:3.9 | Gateway (read-only) |

### Dependency Flow
```
kong-database (health check) → kong-migrations (completed) → kong
```

Uses modern `depends_on` conditions:
- `condition: service_healthy` - waits for database health check
- `condition: service_completed_successfully` - waits for migrations to finish

### Ports
| Port | Service |
|------|---------|
| 8000 | Kong Proxy (HTTP) |
| 8443 | Kong Proxy (HTTPS) |
| 8001 | Admin API (HTTP) |
| 8444 | Admin API (HTTPS) |
| 8002 | Kong Manager (HTTP) |
| 8445 | Kong Manager (HTTPS) |
| 5432 | PostgreSQL |

### Volumes
- `kong_data`: PostgreSQL persistent storage
- `kong_prefix_vol` / `kong_tmp_vol`: tmpfs for Kong runtime
- `./config` → `/opt/kong`: Declarative configuration (read-only)

## Configuration

Environment variables via `.env` file (copy from `default.env`):

| Variable | Default |
|----------|---------|
| KONG_VERSION | 3.9 |
| KONG_PG_DATABASE | kong |
| KONG_PG_USER | kong |
| KONG_PG_PASSWORD | kong |

The YAML anchor `&kong-env` shares database connection settings across services.

## Security

- Kong container: read-only filesystem + `no-new-privileges`
- Config directory mounted as read-only
- Default credentials must be changed for production
- Admin API ports should be network-restricted in production
