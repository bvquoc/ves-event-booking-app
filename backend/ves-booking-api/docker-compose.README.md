# Docker Compose Configuration Guide

This project uses multiple Docker Compose files for different environments.

## Files Overview

- **docker-compose.yml** - Base configuration (MySQL NOT exposed, app requires `--profile app`)
- **docker-compose.dev.yml** - Development backend (DB only, MySQL exposed locally)
- **docker-compose.local.yml** - Local development (app & db, MySQL exposed locally)
- **docker-compose.prod.yml** - Production/VPS (app & db, MySQL NOT exposed)

## Usage

### Building Images

When you need to build or rebuild the application image (first time, after code changes, or Dockerfile updates):

```bash
# Dev backend (DB only)
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build

# Local development (app & db)
docker-compose -f docker-compose.yml -f docker-compose.local.yml --profile app up -d --build

# Production/VPS (app & db)
docker-compose -f docker-compose.yml -f docker-compose.prod.yml --profile app up -d --build
```

**Note:** The `--build` flag rebuilds images before starting containers. Use it when:
- First time running the project
- After making code changes
- After updating the Dockerfile or dependencies
- When you want to ensure you have the latest image

### Development Backend (DB only, MySQL exposed)

Start only the MySQL database with port 3306 exposed for local development tools:

```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

Or with build:

```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
```

This will:
- Start MySQL container only
- Expose MySQL on `localhost:3306` for database tools
- App service is not started (requires `--profile app`)

### Local Development (App & DB, MySQL exposed)

Start both application and database with MySQL exposed:

```bash
docker-compose -f docker-compose.yml -f docker-compose.local.yml --profile app up -d
```

Or with build:

```bash
docker-compose -f docker-compose.yml -f docker-compose.local.yml --profile app up -d --build
```

This will:
- Start both MySQL and App containers
- Expose MySQL on `localhost:3306` for database tools
- Expose App on `localhost:8080`

### Production/VPS (App & DB, MySQL NOT exposed)

Start both application and database without exposing MySQL externally:

```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml --profile app up -d
```

Or with build:

```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml --profile app up -d --build
```

This will:
- Start both MySQL and App containers
- MySQL is only accessible within Docker network (not exposed to host)
- App is exposed on `localhost:8080`
- More secure for production deployments

## Stopping Services

To stop services, use the same file combination:

```bash
# Stop dev
docker-compose -f docker-compose.yml -f docker-compose.dev.yml down

# Stop local
docker-compose -f docker-compose.yml -f docker-compose.local.yml --profile app down

# Stop prod
docker-compose -f docker-compose.yml -f docker-compose.prod.yml --profile app down
```

## Quick Reference

### Common Commands

```bash
# Build and start (first time or after changes)
docker-compose -f docker-compose.yml -f docker-compose.local.yml --profile app up -d --build

# Start without building (use existing images)
docker-compose -f docker-compose.yml -f docker-compose.local.yml --profile app up -d

# Stop services
docker-compose -f docker-compose.yml -f docker-compose.local.yml --profile app down

# View logs
docker-compose -f docker-compose.yml -f docker-compose.local.yml --profile app logs -f

# Rebuild specific service
docker-compose -f docker-compose.yml -f docker-compose.local.yml --profile app build app

# Stop and remove volumes (clean slate)
docker-compose -f docker-compose.yml -f docker-compose.local.yml --profile app down -v
```

## Notes

- MySQL is accessible from the app container via `mysql:3306` in all configurations
- Only `docker-compose.dev.yml` and `docker-compose.local.yml` expose MySQL to the host
- Production configuration keeps MySQL internal for security
- App service requires `--profile app` flag to start (allows DB-only mode for development)
- Use `--build` flag when you need to rebuild images (code changes, Dockerfile updates, first run)

