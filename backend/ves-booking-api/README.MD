# VES Booking API

Spring Boot application providing Identity & Access Management and Event Booking functionality.

## Tech Stack

- Java 21
- Spring Boot 3.2.2
- MySQL 8.0
- Maven 3.9.5+

## Quick Start

### Prerequisites

- Docker & Docker Compose

### Start with Docker Compose

**Local Development (App & DB, MySQL exposed):**

```bash
# Start MySQL and application
docker-compose -f docker-compose.yml -f docker-compose.local.yml --profile app up -d

# View logs
docker-compose -f docker-compose.yml -f docker-compose.local.yml --profile app logs -f

# Stop services
docker-compose -f docker-compose.yml -f docker-compose.local.yml --profile app down
```

**Development Backend (DB only, MySQL exposed):**

```bash
# Start only MySQL database
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Stop services
docker-compose -f docker-compose.yml -f docker-compose.dev.yml down
```

**Production (App & DB, MySQL NOT exposed):**

```bash
# Start MySQL and application
docker-compose -f docker-compose.yml -f docker-compose.prod.yml --profile app up -d

# Stop services
docker-compose -f docker-compose.yml -f docker-compose.prod.yml --profile app down
```

> For more details, see [docker-compose.README.md](./docker-compose.README.md)

### Application URL

- **Base URL:** `http://localhost:8080/api`

### Default Credentials

**Application Users (auto-created on first startup - see `ApplicationInitConfig.java`):**

| Username      | Password | Role        | Description                    |
| ------------- | -------- | ----------- | ------------------------------ |
| `admin`       | `admin`  | `ADMIN`     | Administrator with full access |
| `user1`       | `123456` | `USER`      | Regular user                   |
| `staff`       | `123456` | `STAFF`     | Staff - can check in tickets   |
| `organizer`   | `123456` | `ORGANIZER` | Organizer - can manage events  |
| `newuser`     | `123456` | `USER`      | Demo user - new user scenario  |
| `regularuser` | `123456` | `USER`      | Demo user - regular engagement |
| `vipuser`     | `123456` | `USER`      | Demo user - high engagement    |

⚠️ **Important:** Change all default passwords after first login!

### Quick Test

```bash
# Login as admin
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'
```
