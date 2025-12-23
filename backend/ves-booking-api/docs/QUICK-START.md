# VES Booking API - Quick Start Guide

**Updated for Phase 2: Reference Data APIs**

---

## Quick Links

- **Full API Docs:** [docs/api-docs.md](./api-docs.md)
- **System Architecture:** [docs/system-architecture.md](./system-architecture.md)
- **Entity Model:** [docs/entity-relationships.md](./entity-relationships.md)
- **Phase 2 Details:** [docs/phase-2-reference-data.md](./phase-2-reference-data.md)

---

## Five-Minute Overview

### What is VES Booking API?

Spring Boot 3.2 + MySQL 8.0 event booking platform with:
- User authentication (JWT + RBAC)
- Event discovery (categories, cities)
- Event booking & ticketing
- Voucher/promotion system
- User notifications

### Current Phase

**Phase 2: Reference Data APIs** (Complete)
- ✅ Categories & Cities endpoints
- ✅ Event count calculation
- ✅ Public API access (no auth)

### Next Phase

**Phase 3: Event Management**
- Event CRUD operations
- Advanced search & filtering
- Trending events

---

## API Endpoints at a Glance

### Public Endpoints (No Auth)

```
GET /api/categories          # All categories with event counts
GET /api/cities              # All cities with event counts
POST /api/users              # Create user account
```

### Authenticated Endpoints

```
POST /api/auth/token         # Login
POST /api/auth/refresh       # Refresh token
POST /api/auth/logout        # Logout
GET /api/users/my-info       # Current user profile
PUT /api/users/{id}          # Update profile
```

### Admin Endpoints

```
GET /api/users               # List all users
DELETE /api/users/{id}       # Delete user
POST /api/roles              # Create role
GET /api/roles               # List roles
POST /api/permissions        # Create permission
GET /api/permissions         # List permissions
```

---

## Local Development

### Prerequisites

```bash
java -version        # Java 21+
docker -v            # Docker & Docker Compose
mvn -v              # Maven 3.9.5+
```

### Start Application

```bash
# 1. Start database
docker compose up -d mysql

# 2. Run application
./mvnw spring-boot:run

# 3. Verify
curl http://localhost:8080/api/categories
```

---

## Common Tasks

### Login & Get Token

```bash
curl -X POST http://localhost:8080/api/auth/token \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'
```

Response:
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiI...",
    "refreshToken": "eyJhbGciOiJIUzI1NiI...",
    "expiresIn": 3600
  }
}
```

### Use Token in Requests

```bash
curl -X GET http://localhost:8080/api/users/my-info \
  -H "Authorization: Bearer {accessToken}"
```

### Get Categories (Public, No Login)

```bash
curl http://localhost:8080/api/categories
```

Response:
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "name": "Thể thao",
      "slug": "the-thao",
      "icon": "sports",
      "eventCount": 5
    }
  ]
}
```

### Get Cities (Public, No Login)

```bash
curl http://localhost:8080/api/cities
```

---

## Default Credentials

| Type | Username | Password |
|------|----------|----------|
| Application Admin | admin | admin |
| Database Host | root | root |
| Database Port | 3306 | - |
| Database | ves_booking_api | - |

**Important:** Change admin password in production!

---

## Project Structure

```
src/main/java/com/uit/vesbookingapi/
├── configuration/        # Security, JWT, App init
├── controller/          # REST endpoints
├── service/             # Business logic
├── repository/          # Database access (JPA)
├── entity/              # JPA entities
├── dto/                 # Request/Response DTOs
├── mapper/              # Entity ↔ DTO mapping
├── exception/           # Exception handling
├── validator/           # Custom validators
└── constant/            # Constants & enums
```

---

## Key Concepts

### Authentication (JWT)
1. Login with username/password
2. Server returns accessToken (1 hour) + refreshToken (10 hours)
3. Include token in Authorization header: `Bearer {token}`
4. On expiry, use refreshToken to get new accessToken

### Authorization (RBAC)
1. Users assigned to Roles
2. Roles have Permissions
3. Endpoints check role/permission via @PreAuthorize

### Response Format
```json
{
  "statusCode": 200,
  "message": "Operation description",
  "data": { /* actual data */ }
}
```

### Error Format
```json
{
  "statusCode": 400,
  "message": "Error description",
  "errorCode": "1001",
  "errors": [ /* field-level errors */ ]
}
```

---

## Performance Tips

### Event Counting
- Category/City endpoints use single JOIN query
- Prevents N+1 query problem
- Fast response even with 1000s of events
- No pagination needed

### Database Indexes
- Event: slug, startDate, category_id
- Order: user_id, status
- Notification: user_id, isRead
- Check docs/system-architecture.md for full list

---

## Debugging

### Check Application Health

```bash
# MySQL running?
docker compose ps

# Application logs
tail -f logs/app.log

# Test database connection
curl http://localhost:8080/api/categories
```

### Common Issues

| Issue | Solution |
|-------|----------|
| Port 8080 in use | `lsof -i :8080` and kill process |
| Database connection error | Check MySQL container: `docker compose logs mysql` |
| JWT validation fails | Token expired? Use refreshToken endpoint |
| 403 Forbidden | Check user role/permissions |

---

## Documentation Map

| Document | Purpose | Audience |
|----------|---------|----------|
| [api-docs.md](./api-docs.md) | Complete API reference | API consumers, Frontend devs |
| [system-architecture.md](./system-architecture.md) | System design & diagrams | Architects, Backend devs |
| [entity-relationships.md](./entity-relationships.md) | Data model | DB admins, Backend devs |
| [codebase-summary.md](./codebase-summary.md) | Tech stack & overview | New team members |
| [phase-2-reference-data.md](./phase-2-reference-data.md) | Phase 2 implementation | Backend devs, Code reviewers |
| [QUICK-START.md](./QUICK-START.md) | This file | Everyone |

---

## What's Next

### Immediate (Phase 3)
- [ ] Event CRUD endpoints
- [ ] Event search & filtering
- [ ] Trending events

### Short Term (Phase 4)
- [ ] Order/Booking APIs
- [ ] Ticket generation
- [ ] Payment integration

### Medium Term (Phase 5+)
- [ ] Voucher system
- [ ] Organizer dashboard
- [ ] User notifications

---

## Need Help?

1. **API Questions?** → See [api-docs.md](./api-docs.md)
2. **Architecture Questions?** → See [system-architecture.md](./system-architecture.md)
3. **Data Model Questions?** → See [entity-relationships.md](./entity-relationships.md)
4. **Phase 2 Details?** → See [phase-2-reference-data.md](./phase-2-reference-data.md)

---

## Status Overview

| Component | Status | Details |
|-----------|--------|---------|
| Identity & Access | ✅ Complete | User, Role, Permission management |
| Reference Data | ✅ Complete | Categories & Cities with counts |
| Event Management | 🚧 In Progress | Coming Phase 3 |
| Booking & Tickets | 🚧 Planned | Coming Phase 4 |
| Vouchers & Promotions | 🚧 Planned | Coming Phase 5 |

---

**Last Updated:** 2024-12-17
**Current Phase:** Phase 2 - Reference Data APIs
**Next Review:** Phase 3 Planning
