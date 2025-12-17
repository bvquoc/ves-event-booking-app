# VES Booking API - API Documentation

**Base URL:** `http://localhost:8080/api`

**Version:** Phase 2 - Reference Data APIs

---

## Table of Contents

1. [Authentication Endpoints](#authentication-endpoints)
2. [User Management Endpoints](#user-management-endpoints)
3. [Role Management Endpoints](#role-management-endpoints)
4. [Permission Management Endpoints](#permission-management-endpoints)
5. [Reference Data Endpoints](#reference-data-endpoints)
6. [Response Format](#response-format)
7. [Error Handling](#error-handling)

---

## Authentication Endpoints

### Base Path: `/auth`

#### POST /auth/token
Authenticate user with username and password. Returns access and refresh tokens.

**Request:**
```json
{
  "username": "admin",
  "password": "admin"
}
```

**Response (200 OK):**
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600
  }
}
```

**Status Codes:**
- 200: Success
- 401: Invalid credentials
- 400: Missing fields

---

#### POST /auth/introspect
Validate a JWT token. Returns token validity and extracted claims.

**Request:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200 OK):**
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {
    "valid": true,
    "jti": "token-uuid",
    "username": "admin",
    "roles": ["ADMIN"],
    "issuedAt": 1702000000,
    "expiresAt": 1702003600
  }
}
```

---

#### POST /auth/refresh
Generate new access token using refresh token.

**Request:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200 OK):**
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600
  }
}
```

---

#### POST /auth/logout
Invalidate current JWT token (add to blacklist).

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "statusCode": 200,
  "message": "Logout successful"
}
```

---

## User Management Endpoints

### Base Path: `/users`

#### POST /users
Create new user account.

**Authentication:** Not required (public endpoint)

**Request:**
```json
{
  "username": "john_doe",
  "password": "SecurePassword123!",
  "email": "john@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+84123456789"
}
```

**Response (201 Created):**
```json
{
  "statusCode": 201,
  "message": "Success",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "username": "john_doe",
    "email": "john@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phone": "+84123456789",
    "isActive": true,
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

**Validation Rules:**
- username: 3-50 characters, unique
- password: 6+ characters
- email: Valid email format, unique
- firstName, lastName: Optional, max 100 chars

**Status Codes:**
- 201: User created
- 400: Invalid input or username/email exists
- 500: Server error

---

#### GET /users/{id}
Retrieve user information by ID.

**Authentication:** Required (any authenticated user)

**Path Parameters:**
- `id` (string, UUID): User ID

**Response (200 OK):**
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "username": "john_doe",
    "email": "john@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phone": "+84123456789",
    "avatar": "https://example.com/avatar.jpg",
    "isActive": true,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-16T14:20:00Z",
    "roles": ["USER"]
  }
}
```

**Status Codes:**
- 200: Success
- 401: Unauthorized
- 404: User not found

---

#### GET /users/my-info
Retrieve current authenticated user's information.

**Authentication:** Required

**Response (200 OK):**
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "username": "john_doe",
    "email": "john@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phone": "+84123456789",
    "avatar": "https://example.com/avatar.jpg",
    "isActive": true,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-16T14:20:00Z",
    "roles": ["USER"]
  }
}
```

---

#### PUT /users/{id}
Update user information.

**Authentication:** Required (own account or ADMIN)

**Path Parameters:**
- `id` (string, UUID): User ID

**Request:**
```json
{
  "firstName": "Jane",
  "lastName": "Doe",
  "phone": "+84987654321",
  "avatar": "https://example.com/new-avatar.jpg"
}
```

**Response (200 OK):**
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "username": "john_doe",
    "email": "john@example.com",
    "firstName": "Jane",
    "lastName": "Doe",
    "phone": "+84987654321",
    "avatar": "https://example.com/new-avatar.jpg",
    "isActive": true,
    "updatedAt": "2024-01-17T09:45:00Z"
  }
}
```

---

#### DELETE /users/{id}
Delete user account.

**Authentication:** Required (ADMIN only)

**Path Parameters:**
- `id` (string, UUID): User ID

**Response (200 OK):**
```json
{
  "statusCode": 200,
  "message": "User deleted successfully"
}
```

**Status Codes:**
- 200: Success
- 401: Unauthorized
- 403: Forbidden (not ADMIN)
- 404: User not found

---

#### GET /users
List all users with pagination.

**Authentication:** Required (ADMIN only)

**Query Parameters:**
- `page` (integer): Page number (0-indexed, default: 0)
- `size` (integer): Page size (default: 20, max: 100)
- `sort` (string): Sort field and direction (e.g., `username,asc`)

**Response (200 OK):**
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {
    "content": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "username": "admin",
        "email": "admin@example.com",
        "firstName": "Admin",
        "lastName": "User",
        "isActive": true,
        "createdAt": "2024-01-01T00:00:00Z"
      },
      {
        "id": "550e8400-e29b-41d4-a716-446655440001",
        "username": "john_doe",
        "email": "john@example.com",
        "firstName": "John",
        "lastName": "Doe",
        "isActive": true,
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ],
    "page": 0,
    "size": 20,
    "totalElements": 2,
    "totalPages": 1,
    "hasNext": false
  }
}
```

---

## Role Management Endpoints

### Base Path: `/roles`

#### POST /roles
Create new role.

**Authentication:** Required (ADMIN only)

**Request:**
```json
{
  "name": "ORGANIZER",
  "description": "Event organizer role"
}
```

**Response (201 Created):**
```json
{
  "statusCode": 201,
  "message": "Success",
  "data": {
    "id": "660e8400-e29b-41d4-a716-446655440000",
    "name": "ORGANIZER",
    "description": "Event organizer role"
  }
}
```

---

#### GET /roles
List all available roles.

**Authentication:** Required (ADMIN only)

**Response (200 OK):**
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": [
    {
      "id": "770e8400-e29b-41d4-a716-446655440000",
      "name": "ADMIN",
      "description": "System administrator"
    },
    {
      "id": "770e8400-e29b-41d4-a716-446655440001",
      "name": "USER",
      "description": "Regular user"
    },
    {
      "id": "660e8400-e29b-41d4-a716-446655440000",
      "name": "ORGANIZER",
      "description": "Event organizer role"
    }
  ]
}
```

---

#### DELETE /roles/{role}
Delete a role.

**Authentication:** Required (ADMIN only)

**Path Parameters:**
- `role` (string): Role name (e.g., "ORGANIZER")

**Response (200 OK):**
```json
{
  "statusCode": 200,
  "message": "Role deleted successfully"
}
```

---

## Permission Management Endpoints

### Base Path: `/permissions`

#### POST /permissions
Create new permission.

**Authentication:** Required (ADMIN only)

**Request:**
```json
{
  "code": "CREATE_EVENT",
  "description": "Permission to create events"
}
```

**Response (201 Created):**
```json
{
  "statusCode": 201,
  "message": "Success",
  "data": {
    "id": "880e8400-e29b-41d4-a716-446655440000",
    "code": "CREATE_EVENT",
    "description": "Permission to create events"
  }
}
```

---

#### GET /permissions
List all permissions.

**Authentication:** Required (ADMIN only)

**Response (200 OK):**
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": [
    {
      "id": "880e8400-e29b-41d4-a716-446655440001",
      "code": "CREATE_EVENT",
      "description": "Permission to create events"
    },
    {
      "id": "880e8400-e29b-41d4-a716-446655440002",
      "code": "DELETE_USER",
      "description": "Permission to delete users"
    }
  ]
}
```

---

## Reference Data Endpoints

### Public GET Endpoints (No Authentication Required)

---

### GET /categories
Retrieve all event categories with event count.

**Authentication:** Not required (public endpoint)

**Query Parameters:** None

**Response (200 OK):**
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": [
    {
      "id": "990e8400-e29b-41d4-a716-446655440000",
      "name": "Thể thao",
      "slug": "the-thao",
      "icon": "sports",
      "eventCount": 5
    },
    {
      "id": "990e8400-e29b-41d4-a716-446655440001",
      "name": "Hòa nhạc",
      "slug": "hoa-nhac",
      "icon": "music",
      "eventCount": 12
    },
    {
      "id": "990e8400-e29b-41d4-a716-446655440002",
      "name": "Sân khấu kịch",
      "slug": "san-khau-kich",
      "icon": "theater",
      "eventCount": 3
    },
    {
      "id": "990e8400-e29b-41d4-a716-446655440003",
      "name": "Triển lãm",
      "slug": "trien-lam",
      "icon": "gallery",
      "eventCount": 8
    }
  ]
}
```

**Field Descriptions:**
- `id` (UUID): Unique category identifier
- `name` (string): Display name (Vietnamese)
- `slug` (string): URL-friendly identifier
- `icon` (string): Material Icons identifier for category icon
- `eventCount` (long): Number of events in this category

**Performance Notes:**
- Uses single JOIN query to calculate event counts (prevents N+1 queries)
- Results cached per request
- Fast response even with large event datasets

**Status Codes:**
- 200: Success
- 500: Server error

---

### GET /cities
Retrieve all cities with event count.

**Authentication:** Not required (public endpoint)

**Query Parameters:** None

**Response (200 OK):**
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": [
    {
      "id": "110e8400-e29b-41d4-a716-446655440000",
      "name": "Ho Chi Minh",
      "slug": "ho-chi-minh",
      "eventCount": 15
    },
    {
      "id": "110e8400-e29b-41d4-a716-446655440001",
      "name": "Hanoi",
      "slug": "hanoi",
      "eventCount": 10
    },
    {
      "id": "110e8400-e29b-41d4-a716-446655440002",
      "name": "Da Nang",
      "slug": "da-nang",
      "eventCount": 4
    }
  ]
}
```

**Field Descriptions:**
- `id` (UUID): Unique city identifier
- `name` (string): Display name
- `slug` (string): URL-friendly identifier
- `eventCount` (long): Number of events in this city

**Performance Notes:**
- Optimized with single JOIN query for event counting
- All cities returned regardless of event count (includes 0 events)
- Consistent response time across datasets

**Status Codes:**
- 200: Success
- 500: Server error

---

## Response Format

### Success Response Format

All successful API responses follow this structure:

```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {}
}
```

**Fields:**
- `statusCode` (integer): HTTP status code
- `message` (string): Human-readable success message
- `data` (object/array): Response payload (varies by endpoint)

---

### Error Response Format

```json
{
  "statusCode": 400,
  "message": "Field validation failed",
  "errorCode": "INVALID_KEY",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email format"
    },
    {
      "field": "password",
      "message": "Password must be at least 6 characters"
    }
  ]
}
```

**Fields:**
- `statusCode` (integer): HTTP status code
- `message` (string): Error description
- `errorCode` (string, optional): Error code for programmatic handling
- `errors` (array, optional): Field-level validation errors

---

## Error Handling

### HTTP Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | OK | Successful request |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid input or validation error |
| 401 | Unauthorized | Missing or invalid authentication token |
| 403 | Forbidden | User lacks required permissions |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Resource already exists (e.g., duplicate username) |
| 500 | Internal Server Error | Server error |

---

### Error Codes

#### Identity & Authentication Errors (1xxx)

| Code | Message | Status | Cause |
|------|---------|--------|-------|
| 1001 | Uncategorized error | BAD_REQUEST | General error without specific code |
| 1002 | User existed | CONFLICT | Username or email already registered |
| 1003 | Username must be at least {min} characters | BAD_REQUEST | Username too short |
| 1004 | Password must be at least {min} characters | BAD_REQUEST | Password too short |
| 1005 | User not existed | NOT_FOUND | User ID not found |
| 1006 | Unauthenticated | UNAUTHORIZED | Invalid or missing token |
| 1007 | You do not have permission | FORBIDDEN | User role lacks required permission |
| 1008 | Your age must be at least {min} | BAD_REQUEST | Age validation failed |

#### Event Errors (2xxx)

| Code | Message | Status |
|------|---------|--------|
| 2001 | Event not found | NOT_FOUND |
| 2002 | Event slug already exists | CONFLICT |
| 2003 | Invalid event date range | BAD_REQUEST |

#### Category/City Errors (8xxx)

| Code | Message | Status |
|------|---------|--------|
| 8001 | Category not found | NOT_FOUND |
| 8002 | City not found | NOT_FOUND |

---

### Authentication Error Examples

**Missing Token:**
```json
{
  "statusCode": 401,
  "message": "Unauthenticated",
  "errorCode": "1006"
}
```

**Invalid Token:**
```json
{
  "statusCode": 401,
  "message": "Token validation failed",
  "errorCode": "1006"
}
```

**Expired Token:**
```json
{
  "statusCode": 401,
  "message": "Token expired",
  "errorCode": "1006"
}
```

---

### Validation Error Example

**Request:**
```json
{
  "username": "ab",
  "password": "123",
  "email": "invalid-email"
}
```

**Response (400):**
```json
{
  "statusCode": 400,
  "message": "Field validation failed",
  "errorCode": "1001",
  "errors": [
    {
      "field": "username",
      "message": "Username must be at least 3 characters"
    },
    {
      "field": "password",
      "message": "Password must be at least 6 characters"
    },
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

---

## Request Headers

### Common Headers

**Authentication:**
```
Authorization: Bearer {accessToken}
```

**Content-Type:**
```
Content-Type: application/json
```

---

## Testing with cURL

### Login Example
```bash
curl -X POST http://localhost:8080/api/auth/token \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin"
  }'
```

### Get Categories (Public)
```bash
curl -X GET http://localhost:8080/api/categories
```

### Get Cities (Public)
```bash
curl -X GET http://localhost:8080/api/cities
```

### Get User Info (Protected)
```bash
curl -X GET http://localhost:8080/api/users/my-info \
  -H "Authorization: Bearer {accessToken}"
```

---

## API Versioning

Current API version: **Phase 2 - Reference Data APIs**

**Version History:**
- Phase 1: Identity & Access Management
- Phase 2: Reference Data APIs (Categories, Cities)
- Phase 3 (Planned): Event Management APIs
- Phase 4 (Planned): Booking & Order Management

---

## Pagination

For endpoints that support pagination, use these query parameters:

```
GET /users?page=0&size=20&sort=username,asc
```

**Response includes:**
```json
{
  "content": [],
  "page": 0,
  "size": 20,
  "totalElements": 42,
  "totalPages": 3,
  "hasNext": true
}
```

---

## Rate Limiting

(To be implemented in future phases)

---

## Changelog

### Phase 2 Updates (Current)
- NEW: GET /categories (public)
- NEW: GET /cities (public)
- NEW: Performance-optimized event counting queries
- NEW: Security config updated for public GET endpoints
- CHANGED: User entity now has @Table annotation
