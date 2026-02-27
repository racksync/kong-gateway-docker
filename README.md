# Kong Gateway Docker

[![Kong](https://img.shields.io/badge/Kong-3.9-003459?logo=kong&logoColor=white)](https://konghq.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker_Compose-2.x-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Production-ready Kong API Gateway deployment with Docker Compose.

## Features

- **Authentication** - JWT, OAuth2, API keys, and more
- **Rate Limiting** - Protect backend services from abuse
- **Traffic Control** - Request/response transformations
- **Load Balancing** - Distribute traffic across multiple backends
- **Health Checks** - Active and passive health monitoring
- **Plugin Ecosystem** - 100+ official and community plugins
- **AI Gateway** - Native LLM provider integration (Kong 3.9+)

## Requirements

- Docker Engine 20.10+
- Docker Compose 2.0+
- 2GB RAM minimum

## Quick Start

```bash
./setup.sh
```

The setup script will:
1. Create `.env` from `default.env` if not present
2. Start PostgreSQL database
3. Run database migrations
4. Launch Kong Gateway

## Endpoints

| Service | HTTP | HTTPS |
|---------|------|-------|
| Proxy | `:8000` | `:8443` |
| Admin API | `:8001` | `:8444` |
| Kong Manager | `:8002` | `:8445` |

Verify the installation:

```bash
curl http://localhost:8001/status
```

## Configuration

### Environment Variables

Copy and edit the environment file:

```bash
cp default.env .env
```

| Variable | Default | Description |
|----------|---------|-------------|
| `KONG_VERSION` | `3.9` | Kong Gateway version |
| `KONG_PG_DATABASE` | `kong` | PostgreSQL database name |
| `KONG_PG_USER` | `kong` | PostgreSQL username |
| `KONG_PG_PASSWORD` | `kong` | PostgreSQL password |

### Declarative Configuration

Place Kong configuration in `config/kong.yaml`:

```yaml
_format_version: "3.0"

services:
  - name: my-service
    url: https://api.example.com
    routes:
      - name: my-route
        paths:
          - /api
```

## Architecture

```
┌─────────────────┐
│  kong-database  │  PostgreSQL 17 (persistent storage)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ kong-migrations │  Database schema bootstrap
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│      kong       │  Kong Gateway 3.9 (read-only container)
└─────────────────┘
```

Container dependencies use health check conditions to ensure proper startup ordering.

## Operations

### Start Services

```bash
docker compose up -d
```

### Stop Services

```bash
docker compose down
```

### View Logs

```bash
docker compose logs -f kong
```

### Backup Database

```bash
docker exec kong-database pg_dump -U kong kong > backup.sql
```

### Restore Database

```bash
cat backup.sql | docker exec -i kong-database psql -U kong kong
```

## Upgrade

> **Note**: Upgrades may require service downtime. Always backup before upgrading.

1. Update `KONG_VERSION` in `.env`
2. Run migrations:

```bash
docker compose run --rm kong kong migrations up --vv
docker compose run --rm kong kong migrations finish --vv
```

3. Restart Kong:

```bash
docker compose up -d kong
```

## Security

This deployment implements several security measures:

- Read-only container filesystem
- `no-new-privileges` security option
- Config directory mounted read-only
- tmpfs volumes for runtime data

### Production Checklist

- [ ] Change default database credentials
- [ ] Enable TLS certificates for all endpoints
- [ ] Restrict Admin API access to trusted networks
- [ ] Configure firewall rules for exposed ports
- [ ] Set up log aggregation and monitoring

## License

MIT License - See [LICENSE](LICENSE) for details.

---

<p align="center">
  <a href="https://racksync.com">
    <img src="https://img.shields.io/badge/RACKSYNC-Automation_Solutions-blue?style=flat-square" alt="RACKSYNC">
  </a>
</p>
