# VES Booking API - API Documentation

**Base URL:** `http://localhost:8080/api`

**Version:** Phase 8 - Favorites & Notifications APIs

---

## Table of Contents

1. [Authentication Endpoints](#authentication-endpoints)
2. [User Management Endpoints](#user-management-endpoints)
3. [Role Management Endpoints](#role-management-endpoints)
4. [Permission Management Endpoints](#permission-management-endpoints)
5. [Reference Data Endpoints](#reference-data-endpoints)
6. [Booking & Ticket Purchase Endpoints](#booking--ticket-purchase-endpoints)
7. [Voucher Endpoints](#voucher-endpoints)
8. [Favorites Endpoints](#favorites-endpoints)
9. [Notifications Endpoints](#notifications-endpoints)
10. [Response Format](#response-format)
11. [Error Handling](#error-handling)

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

## Ticket Management Endpoints (Phase 6)

### Base Path: `/tickets`

#### GET /tickets

Retrieve user's tickets with optional status filter and pagination.

**Authentication:** Required (authenticated users only)

**Query Parameters:**

- `status` (enum, optional): Filter by ticket status (ACTIVE, USED, CANCELLED, REFUNDED)
- `page` (integer, default: 0): Page number for pagination
- `size` (integer, default: 10): Page size for pagination
- `sort` (string, default: purchaseDate,desc): Sort field and direction

**Response (200 OK):**

```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {
    "content": [
      {
        "id": "880e8400-e29b-41d4-a716-446655440000",
        "orderId": "770e8400-e29b-41d4-a716-446655440000",
        "eventId": "550e8400-e29b-41d4-a716-446655440000",
        "eventName": "Tech Conference 2024",
        "ticketTypeId": "660e8400-e29b-41d4-a716-446655440000",
        "ticketTypeName": "VIP TICKET",
        "qrCode": "QR-CODE-123456",
        "status": "ACTIVE",
        "purchaseDate": "2024-12-25T16:30:00Z",
        "seatNumber": "A12"
      },
      {
        "id": "880e8400-e29b-41d4-a716-446655440001",
        "orderId": "770e8400-e29b-41d4-a716-446655440001",
        "eventId": "550e8400-e29b-41d4-a716-446655440001",
        "eventName": "Summer Festival 2025",
        "ticketTypeId": "660e8400-e29b-41d4-a716-446655440001",
        "ticketTypeName": "STANDARD TICKET",
        "qrCode": "QR-CODE-234567",
        "status": "CANCELLED",
        "purchaseDate": "2024-12-20T10:15:00Z",
        "seatNumber": null
      }
    ],
    "page": 0,
    "size": 10,
    "totalElements": 25,
    "totalPages": 3,
    "hasNext": true
  }
}
```

**Status Codes:**

- 200: Success
- 401: Unauthorized
- 500: Server error

---

#### GET /tickets/{ticketId}

Retrieve detailed information about a specific ticket.

**Authentication:** Required (authenticated users only)

**Authorization:** User can only view their own tickets

**Path Parameters:**

- `ticketId` (string, UUID): Ticket ID

**Response (200 OK):**

```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {
    "id": "880e8400-e29b-41d4-a716-446655440000",
    "orderId": "770e8400-e29b-41d4-a716-446655440000",
    "eventId": "550e8400-e29b-41d4-a716-446655440000",
    "eventName": "Tech Conference 2024",
    "eventStartDate": "2025-01-15T09:00:00Z",
    "ticketTypeId": "660e8400-e29b-41d4-a716-446655440000",
    "ticketTypeName": "VIP TICKET",
    "ticketPrice": 500000,
    "qrCode": "QR-CODE-123456",
    "qrCodeImage": "https://example.com/qr/QR-CODE-123456.png",
    "status": "ACTIVE",
    "purchaseDate": "2024-12-25T16:30:00Z",
    "checkedInAt": null,
    "seatId": "990e8400-e29b-41d4-a716-446655440000",
    "seatNumber": "A12",
    "sectionName": "VIP Section",
    "rowName": "A",
    "cancellationReason": null,
    "refundAmount": null,
    "refundStatus": null,
    "cancelledAt": null
  }
}
```

**Status Codes:**

- 200: Success
- 401: Unauthorized
- 403: Forbidden (ticket belongs to another user)
- 404: Ticket not found
- 500: Server error

---

#### PUT /tickets/{ticketId}/cancel

Cancel a ticket and process refund based on time-based policy.

**Authentication:** Required (authenticated users only)

**Authorization:** User can only cancel their own tickets

**Path Parameters:**

- `ticketId` (string, UUID): Ticket ID to cancel

**Request Body (optional):**

```json
{
  "reason": "Personal reasons"
}
```

**Request Fields:**

- `reason` (string, optional): Cancellation reason provided by user

**Response (200 OK):**

```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {
    "ticketId": "880e8400-e29b-41d4-a716-446655440000",
    "status": "CANCELLED",
    "refundAmount": 400000,
    "refundPercentage": 80,
    "refundStatus": "PENDING",
    "cancelledAt": "2024-12-25T17:00:00Z",
    "message": "Ticket cancelled successfully. Refund will be processed within 3-5 business days."
  }
}
```

**Refund Policy (Time-based):**

Based on hours remaining until event start:

- Greater than 48 hours: 80% refund
- 24-48 hours: 50% refund
- Less than 24 hours: Cannot cancel (returns error 3005)

**Example Calculations:**

If event starts in 60 hours and ticket price is 500,000 VND:

- Refund: 500,000 * 0.80 = 400,000 VND (80% refund)

If event starts in 36 hours and ticket price is 500,000 VND:

- Refund: 500,000 * 0.50 = 250,000 VND (50% refund)

**Response Fields:**

- `ticketId` (UUID): Cancelled ticket ID
- `status` (enum): CANCELLED
- `refundAmount` (integer): Calculated refund in currency units
- `refundPercentage` (integer): Refund percentage (80 or 50)
- `refundStatus` (enum): PENDING (refund processing status)
- `cancelledAt` (timestamp): When cancellation was processed
- `message` (string): Confirmation message

**Side Effects:**

1. Ticket status changes to CANCELLED
2. TicketType.available incremented (seat released)
3. Seat association cleared (if applicable)
4. RefundStatus set to PENDING
5. Cancellation timestamp recorded

**Status Codes:**

- 200: Cancellation processed successfully
- 401: Unauthorized
- 403: Forbidden (ticket belongs to another user)
- 404: Ticket not found
- 409: Conflict (ticket already cancelled, used, or refunded)
- 500: Server error

**Error Examples:**

**Cannot cancel - less than 24 hours:**

```json
{
  "statusCode": 409,
  "message": "Ticket cannot be cancelled",
  "errorCode": "3005"
}
```

**Ticket already cancelled:**

```json
{
  "statusCode": 409,
  "message": "Ticket cannot be cancelled",
  "errorCode": "3005"
}
```

---

## Booking & Ticket Purchase Endpoints (Phase 5)

### Base Path: `/tickets`

#### POST /tickets/purchase

Purchase event tickets with optional voucher discount. Creates order & reserves tickets.

**Authentication:** Required (authenticated users only)

**Authorization:** USER role or higher

**Transaction Guarantees:**

- SERIALIZABLE isolation level
- Optimistic locking on TicketType (prevents overselling)
- Atomic ticket reservation & order creation

**Request:**

```json
{
  "eventId": "550e8400-e29b-41d4-a716-446655440000",
  "ticketTypeId": "660e8400-e29b-41d4-a716-446655440000",
  "quantity": 2,
  "seatIds": [
    "770e8400-e29b-41d4-a716-446655440000",
    "770e8400-e29b-41d4-a716-446655440001"
  ],
  "voucherCode": "SUMMER2024",
  "paymentMethod": "CREDIT_CARD"
}
```

**Field Descriptions:**

- `eventId` (UUID): Target event ID
- `ticketTypeId` (UUID): Ticket type to purchase
- `quantity` (integer): Number of tickets (1-maxPerOrder)
- `seatIds` (array, optional): Seat IDs if ticket requires seat selection. Must match quantity if provided.
- `voucherCode` (string, optional): Valid voucher code for discount
- `paymentMethod` (enum): CREDIT_CARD | DEBIT_CARD | E_WALLET | BANK_TRANSFER

**Response (201 Created):**

```json
{
  "statusCode": 201,
  "message": "Success",
  "data": {
    "orderId": "880e8400-e29b-41d4-a716-446655440000",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "eventId": "550e8400-e29b-41d4-a716-446655440000",
    "eventName": "Tech Conference 2024",
    "ticketTypeId": "660e8400-e29b-41d4-a716-446655440000",
    "ticketTypeName": "VIP TICKET",
    "quantity": 2,
    "subtotal": 500000,
    "discount": 50000,
    "total": 450000,
    "currency": "VND",
    "voucherCode": "SUMMER2024",
    "status": "PENDING",
    "paymentMethod": "CREDIT_CARD",
    "paymentUrl": "http://ves-booking.io.vn/payments/order/a1b2c3d4-e5f6-7890-abcd",
    "expiresAt": "2024-12-25T16:45:00Z",
    "createdAt": "2024-12-25T16:30:00Z",
    "completedAt": null
  }
}
```

**Order Creation Flow:**

1. Validates event exists
2. Validates ticket type exists & belongs to event
3. Checks ticket availability (quantity)
4. Validates max per order limit
5. Validates seat selection if required
6. Validates voucher if provided
7. Calculates pricing with discount
8. Creates Order (status: PENDING, 15min expiry)
9. Creates Ticket entities (status: ACTIVE)
10. Reserves seats (if applicable)
11. Decrements ticket availability
12. Generates mock payment URL & QR codes

**Validation Rules:**

- Quantity must be ≥ 1 and ≤ maxPerOrder
- If ticket requires seat selection: seatIds.length == quantity
- Selected seats must be AVAILABLE
- Voucher must be valid & applicable to event
- Event start date must be in future
- Order expires in 15 minutes (must complete payment)

**Error Handling:**

- 401: User not authenticated
- 400: Validation failed (see errors array)
- 404: Event, ticket type, seat, or voucher not found
- 409: Seats already taken, tickets unavailable
- 500: Transaction conflict (retry after brief delay)

**Seat Reservation Logic:**

- Seats marked as RESERVED during PENDING order
- Auto-released if order expires (not completed within 15min)
- Converted to SOLD on order completion (payment confirmed)

**Optimistic Locking:**

- TicketType.version incremented on each purchase
- Prevents concurrent overselling via @Version annotation
- Throws OptimisticLockingFailureException if version mismatch
- Client should retry with exponential backoff

**Pricing Calculation:**

```
subtotal = price * quantity
discount = applyVoucher(voucher, subtotal)
total = subtotal - discount
discount never exceeds order amount
```

**Voucher Rules:**

- Code-based lookup
- Validity period checked (startDate ≤ now ≤ endDate)
- Usage limit enforced (usedCount < usageLimit)
- Min order amount validated
- Applicable events/categories validated
- Discount types: PERCENTAGE (capped by maxDiscount) | FIXED_AMOUNT

**Status Codes:**

- 201: Order created (awaiting payment)
- 400: Invalid request or validation failed
- 401: Unauthorized (no token or expired)
- 404: Resource not found
- 409: Conflict (seats taken, inventory exhausted)
- 500: Server error (transaction failed)

---

## Favorites Endpoints

### Base Path: `/favorites`

#### GET /favorites

Retrieve user's favorite events with pagination.

**Authentication:** Required (authenticated users only)

**Query Parameters:**

- `page` (integer, default: 0): Page number for pagination
- `size` (integer, default: 10): Page size for pagination
- `sort` (string, default: createdAt,desc): Sort field and direction

**Response (200 OK):**

```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {
    "content": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "name": "Tech Conference 2024",
        "slug": "tech-conference-2024",
        "description": "Annual tech conference",
        "thumbnail": "https://example.com/event1.jpg",
        "startDate": "2025-02-15T09:00:00Z",
        "endDate": "2025-02-17T18:00:00Z",
        "categoryId": "660e8400-e29b-41d4-a716-446655440000",
        "categoryName": "Technology",
        "cityId": "770e8400-e29b-41d4-a716-446655440000",
        "cityName": "Ho Chi Minh",
        "venueName": "International Convention Center",
        "isFavorite": true,
        "isTrending": false
      }
    ],
    "page": 1,
    "size": 10,
    "totalElements": 15,
    "totalPages": 2,
    "first": true,
    "last": false
  }
}
```

**Status Codes:**

- 200: Success
- 401: Unauthorized
- 500: Server error

---

#### POST /favorites/{eventId}

Add an event to user's favorites (idempotent operation).

**Authentication:** Required (authenticated users only)

**Path Parameters:**

- `eventId` (string, UUID): Event ID to add to favorites. Format: ^[a-fA-F0-9-]{36}$

**Response (200 OK):**

```json
{
  "statusCode": 200,
  "message": "Event added to favorites"
}
```

**Side Effects:**

1. Creates Favorite record linking user to event
2. If favorite already exists (idempotent), silently succeeds
3. Database constraint (user_id, event_id) prevents duplicates

**Status Codes:**

- 200: Event added to favorites
- 400: Invalid event ID format
- 401: Unauthorized
- 404: Event not found
- 500: Server error

---

#### DELETE /favorites/{eventId}

Remove an event from user's favorites.

**Authentication:** Required (authenticated users only)

**Path Parameters:**

- `eventId` (string, UUID): Event ID to remove from favorites. Format: ^[a-fA-F0-9-]{36}$

**Response (200 OK):**

```json
{
  "statusCode": 200,
  "message": "Event removed from favorites"
}
```

**Status Codes:**

- 200: Event removed from favorites
- 400: Invalid event ID format
- 401: Unauthorized
- 404: Favorite not found
- 500: Server error

---

## Notifications Endpoints

### Base Path: `/notifications`

#### GET /notifications

Retrieve user's notifications with optional filtering and pagination.

**Authentication:** Required (authenticated users only)

**Query Parameters:**

- `unreadOnly` (boolean, optional): Filter only unread notifications (default: false - all)
- `page` (integer, default: 0): Page number for pagination
- `size` (integer, default: 20): Page size for pagination
- `sort` (string, default: createdAt,desc): Sort field and direction

**Response (200 OK):**

```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {
    "content": [
      {
        "id": "880e8400-e29b-41d4-a716-446655440000",
        "type": "TICKET_PURCHASED",
        "title": "Mua vé thành công",
        "message": "Bạn đã mua 2 vé cho sự kiện 'Tech Conference 2024'",
        "isRead": false,
        "data": {
          "orderId": "990e8400-e29b-41d4-a716-446655440000",
          "eventId": "550e8400-e29b-41d4-a716-446655440000",
          "ticketCount": "2"
        },
        "createdAt": "2024-12-18T10:30:00Z"
      },
      {
        "id": "880e8400-e29b-41d4-a716-446655440001",
        "type": "EVENT_REMINDER",
        "title": "Nhắc nhở sự kiện",
        "message": "Sự kiện 'Summer Festival 2025' sẽ diễn ra trong 24 giờ nữa!",
        "isRead": true,
        "data": {
          "eventId": "660e8400-e29b-41d4-a716-446655440000"
        },
        "createdAt": "2024-12-17T15:00:00Z"
      }
    ],
    "page": 1,
    "size": 20,
    "totalElements": 45,
    "totalPages": 3,
    "first": true,
    "last": false
  }
}
```

**Notification Types:**

- `TICKET_PURCHASED` - User purchased tickets for an event
- `EVENT_REMINDER` - Event starts in 24 hours (for favorited events)
- `EVENT_CANCELLED` - Event user has tickets for was cancelled
- `PROMOTION` - Promotional offers and discounts
- `SYSTEM` - System announcements and updates

**Status Codes:**

- 200: Success
- 401: Unauthorized
- 500: Server error

---

#### PUT /notifications/{notificationId}/read

Mark a single notification as read.

**Authentication:** Required (authenticated users only)

**Path Parameters:**

- `notificationId` (string, UUID): Notification ID. Format: ^[a-fA-F0-9-]{36}$

**Response (200 OK):**

```json
{
  "statusCode": 200,
  "message": "Notification marked as read"
}
```

**Side Effects:**

1. Sets Notification.isRead = true
2. Updates Notification.updatedAt timestamp
3. Ownership verified (notification must belong to authenticated user)

**Status Codes:**

- 200: Notification marked as read
- 400: Invalid notification ID format
- 401: Unauthorized
- 403: Forbidden (notification belongs to another user)
- 404: Notification not found
- 500: Server error

---

#### PUT /notifications/read-all

Mark all user notifications as read.

**Authentication:** Required (authenticated users only)

**Response (200 OK):**

```json
{
  "statusCode": 200,
  "message": "All notifications marked as read"
}
```

**Side Effects:**

1. Updates all Notification records with isRead = false for current user
2. Sets isRead = true for all matching records
3. Updates Notification.updatedAt for each record

**Status Codes:**

- 200: All notifications marked as read
- 401: Unauthorized
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

#### Ticket & Booking Errors (3xxx - 5xxx)

| Code | Message                 | Status      | Cause                                   |
|------|-------------------------|-------------|-----------------------------------------|
| 3001 | Ticket type not found   | NOT_FOUND   | TicketType ID invalid                   |
| 3002 | Tickets unavailable     | CONFLICT    | Insufficient inventory                  |
| 3003 | Invalid ticket quantity | BAD_REQUEST | Quantity ≤ 0 or > maxPerOrder           |
| 3004 | Seat selection required | BAD_REQUEST | Ticket requires seats but none provided |
| 4001 | Seat not found          | NOT_FOUND   | Seat ID invalid                         |
| 4002 | Seat already taken      | CONFLICT    | Seat already sold/reserved              |
| 5001 | Order not found         | NOT_FOUND   | Order ID invalid                        |
| 5002 | Order expired           | CONFLICT    | 15min PENDING timeout elapsed           |
| 5003 | Order already completed | CONFLICT    | Cannot modify completed order           |

#### Voucher Errors (6xxx)

| Code | Message                     | Status      | Cause                      |
|------|-----------------------------|-------------|----------------------------|
| 6001 | Voucher not found           | NOT_FOUND   | Code invalid               |
| 6002 | Voucher invalid             | BAD_REQUEST | Outside validity period    |
| 6003 | Voucher usage limit reached | CONFLICT    | Max redemptions exceeded   |
| 6004 | Voucher min order not met   | BAD_REQUEST | Order amount below minimum |
| 6005 | Voucher not applicable      | BAD_REQUEST | Event/category mismatch    |

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

Current API version: **Phase 8 - Favorites & Notifications APIs**

**Version History:**
- Phase 1: Identity & Access Management
- Phase 2: Reference Data APIs (Categories, Cities)
- Phase 3 (Planned): Event Management APIs
- Phase 4 (Planned): Order Status Tracking
- Phase 5: Booking & Ticket Purchase APIs
- Phase 6: Ticket Management & Cancellation APIs
- Phase 7: Vouchers & Discounts Management
- Phase 8 (Current): Favorites & Notifications APIs
- Phase 9+ (Planned): Payment Gateway Integration

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

## Voucher Endpoints

### Base Path: `/vouchers`

#### GET /vouchers

List all public vouchers that are currently valid (not expired). No authentication required.

**Authentication:** Not required (public endpoint)

**Query Parameters:** None

**Response (200 OK):**

```json
{
  "statusCode": 200,
  "message": "Success",
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "code": "SUMMER2024",
      "title": "Summer Sale 2024",
      "description": "20% off on all summer events",
      "discountType": "PERCENTAGE",
      "discountValue": 20,
      "minOrderAmount": 50000,
      "maxDiscount": 500000,
      "startDate": "2024-06-01T00:00:00",
      "endDate": "2024-08-31T23:59:59",
      "usageLimit": 1000,
      "usedCount": 245,
      "isPublic": true,
      "applicableEvents": [],
      "applicableCategories": [
        "music",
        "sports"
      ]
    }
  ]
}
```

**Field Descriptions:**

- `id` (UUID): Unique voucher identifier
- `code` (string): Voucher code (uppercase, format: ^[A-Z0-9_-]{3,30}$)
- `title` (string): Display name
- `description` (string): Detailed description
- `discountType` (enum): FIXED_AMOUNT or PERCENTAGE
- `discountValue` (integer): Amount (for FIXED) or percentage (for PERCENTAGE)
- `minOrderAmount` (integer): Minimum order amount to apply (nullable)
- `maxDiscount` (integer): Maximum discount cap for PERCENTAGE type (nullable)
- `startDate` (datetime): Validity period start
- `endDate` (datetime): Validity period end
- `usageLimit` (integer): Max uses limit (null = unlimited)
- `usedCount` (integer): Current usage count
- `isPublic` (boolean): Visible to all users
- `applicableEvents` (array): Specific event IDs (empty = all events)
- `applicableCategories` (array): Specific category slugs (empty = all categories)

**Status Codes:**

- 200: Success
- 500: Server error

---

#### GET /vouchers/my-vouchers

List user's vouchers with optional status filtering. Requires authentication.

**Authentication:** Required (Bearer token)

**Query Parameters:**

- `status` (string, optional): Filter by status - "active", "used", "expired", or "all" (default: "all")

**Response (200 OK):**

```json
{
  "statusCode": 200,
  "message": "Success",
  "data": [
    {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "userId": "770e8400-e29b-41d4-a716-446655440000",
      "voucherId": "550e8400-e29b-41d4-a716-446655440000",
      "isUsed": false,
      "usedAt": null,
      "orderId": null,
      "addedAt": "2024-05-15T10:30:00",
      "voucher": {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "code": "SUMMER2024",
        "title": "Summer Sale 2024",
        "discountType": "PERCENTAGE",
        "discountValue": 20,
        "endDate": "2024-08-31T23:59:59",
        "isPublic": true
      }
    }
  ]
}
```

**Field Descriptions:**

- `id` (UUID): UserVoucher record ID
- `userId` (UUID): User ID
- `voucherId` (UUID): Voucher ID
- `isUsed` (boolean): Whether voucher has been redeemed
- `usedAt` (datetime): When voucher was used (null if unused)
- `orderId` (UUID): Order that used this voucher (null if unused)
- `addedAt` (datetime): When voucher was assigned to user
- `voucher` (object): Voucher details

**Status Codes:**

- 200: Success
- 400: Invalid status filter
- 401: Unauthenticated
- 500: Server error

---

#### POST /vouchers/validate

Validate voucher and calculate discount for a specific order. Requires authentication.

**Authentication:** Required (Bearer token)

**Request Body:**

```json
{
  "voucherCode": "SUMMER2024",
  "eventId": "330e8400-e29b-41d4-a716-446655440000",
  "ticketTypeId": "440e8400-e29b-41d4-a716-446655440000",
  "quantity": 2
}
```

**Request Field Descriptions:**

- `voucherCode` (string, required): Voucher code to validate (pattern: ^[A-Z0-9_-]{3,30}$)
- `eventId` (UUID, required): Event ID to check applicability
- `ticketTypeId` (UUID, required): Ticket type for pricing calculation
- `quantity` (integer, required): Number of tickets (min: 1)

**Response (200 OK - Valid Voucher):**

```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {
    "isValid": true,
    "message": "Voucher is valid",
    "orderAmount": 200000,
    "discountAmount": 40000,
    "finalAmount": 160000,
    "voucher": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "code": "SUMMER2024",
      "title": "Summer Sale 2024",
      "discountType": "PERCENTAGE",
      "discountValue": 20
    }
  }
}
```

**Response (200 OK - Invalid Voucher):**

```json
{
  "statusCode": 200,
  "message": "Success",
  "data": {
    "isValid": false,
    "message": "Voucher is expired or not yet valid",
    "orderAmount": 200000,
    "discountAmount": null,
    "finalAmount": null,
    "voucher": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "code": "SUMMER2024",
      "title": "Summer Sale 2024"
    }
  }
}
```

**Response Field Descriptions:**

- `isValid` (boolean): Whether voucher passes all validation steps
- `message` (string): Validation result message
- `orderAmount` (integer): Subtotal before discount
- `discountAmount` (integer): Discount amount (null if invalid)
- `finalAmount` (integer): Final amount after discount (null if invalid)
- `voucher` (object): Voucher details

**Validation Steps (10-step process):**

1. Voucher exists by code
2. Not expired (startDate <= now <= endDate)
3. Usage limit not exceeded (usedCount < usageLimit)
4. Event & ticket type exist
5. Quantity within maxPerOrder limit
6. Order amount >= minOrderAmount
7. Applicability check (event or category match, OR logic)
8. Discount value valid (positive for FIXED, 0-100 for PERCENTAGE)
9. Overflow protection for percentage calculations (uses long)
10. Discount capped at maxDiscount (for PERCENTAGE)

**Possible Validation Failures:**

- "Voucher is expired or not yet valid"
- "Voucher usage limit reached"
- "Quantity exceeds maximum per order: X"
- "Minimum order amount not met: X"
- "Voucher not applicable for this event"
- "Invalid voucher discount value"
- "Invalid voucher discount percentage"

**Status Codes:**

- 200: Success (valid or invalid voucher)
- 400: Invalid request (missing fields, invalid format, not found)
- 401: Unauthenticated
- 404: Event or ticket type not found, voucher not found
- 500: Server error

---

## Rate Limiting

(To be implemented in future phases)

---

## Changelog

### Phase 8 Updates (Current)

**New Favorites Endpoints:**

- NEW: GET /favorites - List user's favorite events (paginated, authenticated)
- NEW: POST /favorites/{eventId} - Add event to favorites (idempotent)
- NEW: DELETE /favorites/{eventId} - Remove event from favorites

**New Notifications Endpoints:**

- NEW: GET /notifications - List user notifications (paginated, with unreadOnly filter)
- NEW: PUT /notifications/{notificationId}/read - Mark single notification as read
- NEW: PUT /notifications/read-all - Mark all notifications as read

**New Services:**

- NEW: FavoriteService - Favorites management with idempotent add operation
    - getUserFavorites() - Paginated retrieval
    - addFavorite() - Idempotent (handles DataIntegrityViolationException)
    - removeFavorite() - Delete favorite
- NEW: NotificationService - Notification management (6 methods)
    - getUserNotifications() - Paginated with unreadOnly filter
    - markAsRead() - Mark single notification as read
    - markAllAsRead() - Mark all as read
    - notifyTicketPurchased() - Type: TICKET_PURCHASED
    - notifyEventReminder() - Type: EVENT_REMINDER
    - notifyEventCancelled() - Type: EVENT_CANCELLED

**New Repositories:**

- NEW: FavoriteRepository extended with findByUserIdWithEvent()
- NEW: NotificationRepository extended with:
    - findUnreadByUserId() - Unread notifications only
    - findByUserIdOrderByCreatedAtDesc() - All user notifications
    - markAllAsReadByUserId() - Bulk update for mark all read
    - countByUserIdAndIsRead() - Unread count

**New Controllers:**

- NEW: FavoriteController (3 endpoints)
- NEW: NotificationController (3 endpoints)

**Features:**

- Pagination support: @PageableDefault on all list endpoints
- Input validation: @Pattern regex for UUID validation on path variables
- Security: @PreAuthorize("isAuthenticated()") on all endpoints
- Idempotent add: Favorites silently ignore duplicates (DataIntegrityViolationException)
- Notification types: TICKET_PURCHASED, EVENT_REMINDER, EVENT_CANCELLED, PROMOTION, SYSTEM
- Notification data: Map-based flexible data storage per notification
- Unread filtering: Optional unreadOnly parameter on GET /notifications

**DTOs:**

- NEW: EventResponse - Event data returned in favorites list
- NEW: NotificationResponse - Notification with type, title, message, data
- NEW: PageResponse - Pagination wrapper for list responses

---

### Phase 7 Updates

**New Voucher Endpoints:**

- NEW: GET /vouchers - List public vouchers (no auth, not expired)
- NEW: GET /vouchers/my-vouchers?status={status} - List user vouchers (authenticated)
- NEW: POST /vouchers/validate - Validate voucher & calculate discount (authenticated)

**New Services:**

- NEW: VoucherService - Comprehensive voucher validation with 10-step process:
    1. Find voucher by code
    2. Check expiry (startDate, endDate)
    3. Check usage limit (usedCount vs usageLimit)
    4. Load event & ticket type validation
    5. Validate quantity against maxPerOrder
    6. Calculate order amount (price * quantity)
    7. Check minimum order amount requirement
    8. Verify event/category applicability (OR logic)
    9. Calculate discount (fixed or percentage with overflow protection)
    10. Return validation result with final amount

**New Repositories:**

- NEW: VoucherRepository custom queries:
    - findByCode(String code) - Find voucher by code
    - findPublicActiveVouchers(LocalDateTime now) - Find public non-expired vouchers
- NEW: UserVoucherRepository status-based filters:
    - findByUserIdOrderByAddedAtDesc(String userId) - All user vouchers
    - findActiveByUserId(String userId, LocalDateTime now) - Active (not used, not expired)
    - findUsedByUserId(String userId) - Used vouchers
    - findExpiredByUserId(String userId, LocalDateTime now) - Expired (not used, expired)

**Entities & Enums:**

- Voucher entity with applicableEvents & applicableCategories element collections
- UserVoucher entity for user-specific voucher assignments & tracking
- VoucherDiscountType enum (FIXED_AMOUNT, PERCENTAGE)

**DTOs:**

- NEW: VoucherResponse - Public voucher information
- NEW: UserVoucherResponse - User's assigned voucher with status
- NEW: VoucherValidationResponse - Validation result with discount breakdown
- NEW: ValidateVoucherRequest - Validation request with input validation

**Features:**

- Discount types: FIXED_AMOUNT or PERCENTAGE
- Overflow protection: Uses long for percentage calculations
- Applicability: Empty lists = all events/categories, non-empty = specific restrictions (OR logic)
- Input validation: Voucher code regex ^[A-Z0-9_-]{3,30}$
- Error codes: VOUCHER_NOT_FOUND (6001), VOUCHER_INVALID_OR_EXPIRED (6002), VOUCHER_NOT_APPLICABLE (6003),
  VOUCHER_USAGE_LIMIT_REACHED (6004), MIN_ORDER_AMOUNT_NOT_MET (6005)

### Phase 6 Updates

**New Ticket Management Endpoints:**

- NEW: GET /tickets - List user tickets with status filter & pagination
- NEW: GET /tickets/{ticketId} - Get ticket details (ownership validated)
- NEW: PUT /tickets/{ticketId}/cancel - Cancel ticket with refund

**New Services:**

- NEW: TicketService - Ticket retrieval & cancellation operations
- NEW: CancellationService - Time-based refund calculation
  - 80% refund: >48 hours before event
  - 50% refund: 24-48 hours before event
  - Not cancellable: <24 hours before event

**Ticket Entity Enhancements:**

- NEW: cancellationReason (string) - User-provided cancellation reason
- NEW: cancelledAt (LocalDateTime) - Cancellation timestamp
- NEW: refundAmount (integer) - Calculated refund in currency units
- NEW: refundStatus (RefundStatus enum) - Refund processing status

**Business Logic Implementation:**

- NEW: Ownership validation - Users can only view/cancel their own tickets
- NEW: Seat release on cancellation - TicketType.available incremented
- NEW: Refund status tracking (PENDING → PROCESSING → COMPLETED/FAILED)
- NEW: TicketRepository extended with filter methods

**DTOs:**

- NEW: CancellationResponse - Cancellation result with refund details
- NEW: TicketResponse - List view of tickets with status
- NEW: TicketDetailResponse - Detailed ticket information
- NEW: CancelTicketRequest - Cancellation request with optional reason

### Phase 5 Updates

- NEW: POST /tickets/purchase (authenticated)
- NEW: Transactional booking with SERIALIZABLE isolation
- NEW: Optimistic locking via @Version on TicketType
- NEW: Seat reservation logic (PENDING → SOLD)
- NEW: Voucher validation & discount calculation
- NEW: Mock payment URL & QR code generation
- NEW: Order expiry (15 minutes for PENDING orders)
- NEW: Error codes for tickets (3xxx), seats (4xxx), orders (5xxx), vouchers (6xxx)
- NEW: OrderRepository with custom queries
- NEW: TicketRepository with seat occupation checks
- NEW: VoucherRepository for code lookups
- NEW: BookingService with transactional guarantees
- NEW: OrderMapper for Entity ↔ DTO conversion

### Phase 2 Updates

- GET /categories (public)
- GET /cities (public)
- Performance-optimized event counting queries
- Security config updated for public GET endpoints
- User entity @Table annotation
