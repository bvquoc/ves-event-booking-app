# VES Booking API - Codebase Summary

**Phase 1: Foundation & Core Entities - COMPLETE**

Database schema with 24 tables. Core entities for identity management & event booking system.

---

## Project Overview

VES Booking API: Spring Boot 3.2.2 + MySQL 8.0. Comprehensive event booking platform with:
- Identity & Access Management (IAM)
- Event management & discovery
- Ticket booking & seat selection
- Order management & payment handling
- Voucher system with discounts
- User notifications
- Favorites & user preferences

---

## Technology Stack

| Component | Technology |
|-----------|-----------|
| Build Tool | Maven 3.9.5+ |
| Language | Java 21 |
| Framework | Spring Boot 3.2.2 |
| Database | MySQL 8.0 |
| ORM | JPA/Hibernate |
| Security | Spring Security + JWT OAuth2 |
| Mapping | MapStruct 1.5.5 |
| Validation | Jakarta Validation |
| Utilities | Lombok, Jackson |

---

## Entity Relationship Diagram

```
User ◄──────────────► Role (M:M)
  │
  ├──► Order (1:M)
  │      │
  │      ├──► Event (M:1)
  │      ├──► TicketType (M:1)
  │      ├──► Ticket (1:M)
  │      └──► Voucher (M:1)
  │
  ├──► Ticket (1:M)
  │      ├──► Event (M:1)
  │      ├──► TicketType (M:1)
  │      └──► Seat (M:1)
  │
  ├──► Favorite (1:M)
  │      └──► Event (M:1)
  │
  ├──► Notification (1:M)
  │
  └──► UserVoucher (1:M)
         ├──► Voucher (M:1)
         └──► Order (M:1)

Event
  ├──► Category (M:1)
  ├──► City (M:1)
  ├──► Venue (M:1)
  ├──► TicketType (1:M)
  └──► event_images (Element Collection)
  └──► event_tags (Element Collection)

Category
  └──► Event (1:M)

City
  ├──► Event (1:M)
  └──► Venue (1:M)

Venue
  ├──► City (M:1)
  └──► Seat (1:M)

Seat
  └──► Venue (M:1)

TicketType
  ├──► Event (M:1)
  ├──► ticket_type_benefits (Element Collection)
  └──► Ticket (1:M)

Voucher
  ├──► voucher_applicable_events (Element Collection)
  ├──► voucher_applicable_categories (Element Collection)
  └──► UserVoucher (1:M)

Notification
  └──► User (M:1)
```

---

## Database Schema (24 Tables)

### Identity & Access Management

#### `user`
Core user entity. JWT-based authentication.

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| username | VARCHAR | NOT NULL, UNIQUE |
| password | VARCHAR | NOT NULL, BCrypt hashed |
| email | VARCHAR | NOT NULL, UNIQUE |
| phone | VARCHAR | |
| firstName | VARCHAR | |
| lastName | VARCHAR | |
| avatar | VARCHAR | |
| isActive | BOOLEAN | NOT NULL, default=true |
| createdAt | TIMESTAMP | NOT NULL |
| updatedAt | TIMESTAMP | |

**Indexes:** id, username, email

---

#### `role`
User roles for RBAC. Predefined: ADMIN, USER, ORGANIZER.

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| name | VARCHAR | NOT NULL, UNIQUE |
| description | VARCHAR | |

**Indexes:** id, name

---

#### `user_role`
M:M relationship. User to Role mapping.

| Column | Type | Constraints |
|--------|------|-------------|
| user_id | UUID | FK → user.id |
| role_id | UUID | FK → role.id |

**PK:** (user_id, role_id)

---

#### `permission`
Fine-grained permissions for authorization.

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| code | VARCHAR | NOT NULL, UNIQUE |
| description | VARCHAR | |

**Indexes:** id, code

---

#### `role_permission`
M:M relationship. Role to Permission mapping.

| Column | Type | Constraints |
|--------|------|-------------|
| role_id | UUID | FK → role.id |
| permission_id | UUID | FK → permission.id |

**PK:** (role_id, permission_id)

---

#### `invalidated_token`
Token blacklist for logout & token invalidation.

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| jti | VARCHAR | NOT NULL, UNIQUE |
| expiryTime | TIMESTAMP | NOT NULL |

**Indexes:** id, jti

---

### Event Management

#### `category`
Event categories (Music, Sports, Theater, etc.).

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| name | VARCHAR | NOT NULL, UNIQUE |
| slug | VARCHAR | NOT NULL, UNIQUE |
| icon | VARCHAR | Icon URL |

**Indexes:** id, name, slug

---

#### `city`
Geographic locations for events.

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| name | VARCHAR | NOT NULL |
| slug | VARCHAR | NOT NULL, UNIQUE |

**Indexes:** id, slug

---

#### `event`
Core event entity. Comprehensive event info.

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| name | VARCHAR | NOT NULL |
| slug | VARCHAR | NOT NULL, UNIQUE |
| description | VARCHAR | TEXT |
| longDescription | VARCHAR | TEXT |
| category_id | UUID | FK → category.id, NOT NULL |
| thumbnail | VARCHAR | Image URL |
| startDate | TIMESTAMP | NOT NULL |
| endDate | TIMESTAMP | |
| city_id | UUID | FK → city.id, NOT NULL |
| venue_id | UUID | FK → venue.id |
| venueName | VARCHAR | Denormalized |
| venueAddress | VARCHAR | Denormalized |
| currency | VARCHAR | e.g., VND |
| isTrending | BOOLEAN | |
| organizerId | VARCHAR | FK to future Organizer |
| organizerName | VARCHAR | |
| organizerLogo | VARCHAR | |
| terms | VARCHAR | TEXT |
| cancellationPolicy | VARCHAR | TEXT |
| createdAt | TIMESTAMP | NOT NULL |
| updatedAt | TIMESTAMP | |

**Indexes:** idx_event_slug (slug), idx_event_start_date (startDate), idx_event_category (category_id)

**Collections:**
- event_images (image_url)
- event_tags (tag)

---

#### `venue`
Physical venue info. Capacity & location.

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| name | VARCHAR | NOT NULL |
| address | VARCHAR | TEXT |
| capacity | INTEGER | |
| city_id | UUID | FK → city.id |

**Indexes:** id

---

#### `seat`
Physical seats in venue. Status per event (not stored).

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| venue_id | UUID | FK → venue.id, NOT NULL |
| sectionName | VARCHAR | NOT NULL (e.g., "VIP Section") |
| rowName | VARCHAR | NOT NULL (e.g., "A") |
| seatNumber | VARCHAR | NOT NULL (e.g., "A12") |

**Indexes:** id, venue_id

---

#### `ticket_type`
Ticket tiers for events (VIP, Standard, etc.).

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| event_id | UUID | FK → event.id, NOT NULL |
| name | VARCHAR | NOT NULL (e.g., "VIP TICKET") |
| description | VARCHAR | TEXT |
| price | INTEGER | NOT NULL (in cents/smallest unit) |
| currency | VARCHAR | |
| available | INTEGER | NOT NULL, available qty |
| maxPerOrder | INTEGER | Max per single order |
| requiresSeatSelection | BOOLEAN | NOT NULL |

**Indexes:** id, event_id

**Collections:**
- ticket_type_benefits (benefit)

---

### Order & Ticket Management

#### `order`
Purchase orders. Tracks user bookings.

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| user_id | UUID | FK → user.id, NOT NULL |
| event_id | UUID | FK → event.id, NOT NULL |
| ticket_type_id | UUID | FK → ticket_type.id, NOT NULL |
| quantity | INTEGER | NOT NULL |
| subtotal | INTEGER | NOT NULL (before discount) |
| discount | INTEGER | Discount amount |
| total | INTEGER | NOT NULL (final amount) |
| currency | VARCHAR | |
| voucher_id | UUID | FK → voucher.id |
| status | ENUM(OrderStatus) | NOT NULL |
| paymentMethod | ENUM(PaymentMethod) | |
| paymentUrl | VARCHAR | Mock payment gateway URL |
| expiresAt | TIMESTAMP | Payment timeout |
| createdAt | TIMESTAMP | NOT NULL |
| completedAt | TIMESTAMP | When payment succeeded |

**Indexes:** idx_order_user (user_id), idx_order_status (status)

---

#### `ticket`
Individual tickets issued from orders.

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| order_id | UUID | FK → order.id, NOT NULL |
| user_id | UUID | FK → user.id, NOT NULL |
| event_id | UUID | FK → event.id, NOT NULL |
| ticket_type_id | UUID | FK → ticket_type.id, NOT NULL |
| seat_id | UUID | FK → seat.id |
| qrCode | VARCHAR | NOT NULL, UNIQUE |
| qrCodeImage | VARCHAR | QR code image URL |
| status | ENUM(TicketStatus) | NOT NULL |
| refundStatus | ENUM(RefundStatus) | |
| checkedInAt | TIMESTAMP | Check-in timestamp |
| refundedAt | TIMESTAMP | Refund timestamp |
| createdAt | TIMESTAMP | NOT NULL |

**Indexes:** id, order_id, user_id, event_id, qrCode

---

### Voucher Management

#### `voucher`
Discount vouchers. Fixed or percentage-based.

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| code | VARCHAR | NOT NULL, UNIQUE |
| title | VARCHAR | NOT NULL |
| description | VARCHAR | TEXT |
| discountType | ENUM(VoucherDiscountType) | NOT NULL |
| discountValue | INTEGER | Amount or percentage |
| minOrderAmount | INTEGER | Minimum order to apply |
| maxDiscount | INTEGER | Max discount for percentage type |
| startDate | TIMESTAMP | NOT NULL |
| endDate | TIMESTAMP | NOT NULL |
| usageLimit | INTEGER | Max uses (null = unlimited) |
| usedCount | INTEGER | NOT NULL, tracking usage |
| isPublic | BOOLEAN | Visible to all users |

**Indexes:** idx_voucher_code (code)

**Collections:**
- voucher_applicable_events (event_id) - empty = all events
- voucher_applicable_categories (category_slug) - empty = all categories

---

#### `user_voucher`
User-voucher assignments & tracking.

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| user_id | UUID | FK → user.id, NOT NULL |
| voucher_id | UUID | FK → voucher.id, NOT NULL |
| isUsed | BOOLEAN | NOT NULL |
| usedAt | TIMESTAMP | When voucher was used |
| order_id | UUID | FK → order.id, which order used it |
| addedAt | TIMESTAMP | NOT NULL |

**Unique Constraint:** (user_id, voucher_id)

---

### User Preferences

#### `favorite`
User favorite events.

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| user_id | UUID | FK → user.id, NOT NULL |
| event_id | UUID | FK → event.id, NOT NULL |
| createdAt | TIMESTAMP | NOT NULL |

**Unique Constraint:** (user_id, event_id)

---

### Notifications

#### `notification`
User notifications (order, event reminders, promotions).

| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, auto-generated |
| user_id | UUID | FK → user.id, NOT NULL |
| type | ENUM(NotificationType) | NOT NULL |
| title | VARCHAR | NOT NULL |
| message | VARCHAR | TEXT, NOT NULL |
| isRead | BOOLEAN | NOT NULL |
| createdAt | TIMESTAMP | NOT NULL |

**Indexes:** idx_notification_user (user_id), idx_notification_read (isRead)

**Collections:**
- notification_data (data_key, data_value) - Event ID, Order ID, etc.

---

## Enums (7 Total)

### OrderStatus
- PENDING - Payment pending
- COMPLETED - Payment successful
- CANCELLED - Cancelled by user
- EXPIRED - Payment timeout
- REFUNDED - Refunded after cancellation

### TicketStatus
- ACTIVE - Valid ticket
- USED - Checked in
- CANCELLED - Cancelled
- REFUNDED - Refunded

### SeatStatus
- AVAILABLE
- RESERVED - Temp hold during purchase
- SOLD
- BLOCKED - Not for sale

### PaymentMethod
- CREDIT_CARD
- DEBIT_CARD
- E_WALLET
- BANK_TRANSFER

### NotificationType
- TICKET_PURCHASED
- EVENT_REMINDER
- EVENT_CANCELLED
- PROMOTION
- SYSTEM

### VoucherDiscountType
- FIXED_AMOUNT (e.g., 100,000 VND off)
- PERCENTAGE (e.g., 10% off)

### RefundStatus
- PENDING
- PROCESSING
- COMPLETED
- FAILED

---

## Error Codes (30+)

**Range System:**
- 1xxx - User & Auth errors
- 2xxx - Event errors
- 3xxx - Ticket errors
- 4xxx - Seat errors
- 5xxx - Order errors
- 6xxx - Voucher errors
- 7xxx - Venue errors
- 8xxx - Category/City errors
- 9xxx - Notification & system errors

| Code | Message | Status |
|------|---------|--------|
| 1001 | Uncategorized error | BAD_REQUEST |
| 1002 | User existed | BAD_REQUEST |
| 1003 | Username must be at least {min} characters | BAD_REQUEST |
| 1004 | Password must be at least {min} characters | BAD_REQUEST |
| 1005 | User not existed | NOT_FOUND |
| 1006 | Unauthenticated | UNAUTHORIZED |
| 1007 | You do not have permission | FORBIDDEN |
| 1008 | Your age must be at least {min} | BAD_REQUEST |
| 2001 | Event not found | NOT_FOUND |
| 2002 | Event slug already exists | BAD_REQUEST |
| 2003 | Invalid event date range | BAD_REQUEST |
| 3001 | Ticket type not found | NOT_FOUND |
| 3002 | Requested tickets are not available | BAD_REQUEST |
| 3003 | Invalid ticket quantity | BAD_REQUEST |
| 3004 | Ticket not found | NOT_FOUND |
| 3005 | Ticket cannot be cancelled | BAD_REQUEST |
| 4001 | Seat not found | NOT_FOUND |
| 4002 | Seat is already taken | CONFLICT |
| 4003 | Seat selection is required for this ticket type | BAD_REQUEST |
| 5001 | Order not found | NOT_FOUND |
| 5002 | Order has expired | BAD_REQUEST |
| 5003 | Order already completed | BAD_REQUEST |
| 6001 | Voucher not found | NOT_FOUND |
| 6002 | Voucher is invalid or expired | BAD_REQUEST |
| 6003 | Voucher not applicable for this event | BAD_REQUEST |
| 6004 | Voucher usage limit reached | BAD_REQUEST |
| 6005 | Minimum order amount not met | BAD_REQUEST |
| 7001 | Venue not found | NOT_FOUND |
| 8001 | Category not found | NOT_FOUND |
| 8002 | City not found | NOT_FOUND |
| 9001 | Notification not found | NOT_FOUND |
| 9999 | Uncategorized error | INTERNAL_SERVER_ERROR |

---

## Constants

### EventConstants
- SEAT_RESERVATION_TIMEOUT_MINUTES = 15
- MAX_TICKETS_PER_ORDER = 10
- NOTIFICATION_REMINDER_HOURS_BEFORE_EVENT = 24
- DEFAULT_CURRENCY = "VND"

### PredefinedRole
- ADMIN
- USER
- ORGANIZER (future)

---

## Key Design Patterns

### 1. UUID Primary Keys
All entities use UUID for distributed systems support & scalability.

### 2. Denormalization
Event entity stores venueName & venueAddress for search/display efficiency. Reduces joins.

### 3. Element Collections
Used for variable-length fields:
- event_images, event_tags
- ticket_type_benefits
- voucher_applicable_events, voucher_applicable_categories
- notification_data (Map)

### 4. Timestamps
- createdAt: Auto-set on @PrePersist
- updatedAt: Auto-updated on @PreUpdate
- Auditing-ready for future enhancements

### 5. Enums for Status Fields
Type-safe status management (OrderStatus, TicketStatus, etc.). Prevents invalid values.

### 6. Unique Constraints
- Event slug, Category name/slug, City slug
- User username, email
- Voucher code
- QR code on Ticket
- (user_id, event_id) on Favorite
- (user_id, voucher_id) on UserVoucher

### 7. Strategic Indexes
Performance optimization on frequently queried columns:
- Event: slug, startDate, category_id
- Order: user_id, status
- Notification: user_id, isRead
- Voucher: code

### 8. Optional Relationships
Seat, Venue not required for events (virtual events support).
Refund tracking separate from ticket (clean separation).

---

## Implementation Phases

### Phase 1 (Complete)

- ✅ 24 core database entities with relationships
- ✅ 7 enums for status management
- ✅ Identity & Access Management (IAM)
- ✅ Strategic indexes on frequently queried columns

### Phase 2 (Complete)

- ✅ CategoryService with event counts (single JOIN query)
- ✅ CityService with event counts
- ✅ Public GET /categories endpoint
- ✅ Public GET /cities endpoint
- ✅ Performance optimized (N+1 query prevention)

### Phase 3 (Planned)

- Event Management APIs (CRUD, search, filtering)
- Event discovery endpoints
- Trending events functionality
- Event filtering by category, city, date range

### Phase 4 (Planned)

- Order status tracking APIs
- Ticket retrieval & QR code endpoints
- Refund workflows

### Phase 5 (Complete)

- ✅ BookingService with transactional guarantees
- ✅ TicketController with POST /tickets/purchase
- ✅ SERIALIZABLE transaction isolation
- ✅ Optimistic locking (@Version on TicketType)
- ✅ Seat reservation logic (PENDING → SOLD)
- ✅ Voucher validation & discount calculation
- ✅ Mock payment URL & QR code generation
- ✅ Order expiry (15 minutes for PENDING orders)

### Phase 6 (Current - Complete)

**Ticket Management & Cancellation:**

- ✅ GET /tickets - List user tickets with status filter & pagination
- ✅ GET /tickets/{ticketId} - Get ticket details
- ✅ PUT /tickets/{ticketId}/cancel - Cancel ticket with refund
- ✅ CancellationService - Refund calculation (time-based policy)
- ✅ TicketService - Ticket management operations
- ✅ Ownership validation - Users can only view/cancel their own tickets
- ✅ Seat release - Cancelled tickets release seats to inventory
- ✅ Available count increment - TicketType.available incremented on cancellation

**Refund Policy (Time-based):**

- Greater than 48 hours before event: 80% refund
- 24-48 hours before event: 50% refund
- Less than 24 hours before event: NOT cancellable

**New Fields in Ticket Entity:**

- cancellationReason (string)
- cancelledAt (LocalDateTime)
- refundAmount (integer)
- refundStatus (RefundStatus enum: PENDING, PROCESSING, COMPLETED, FAILED)

### Phase 7+ (Planned)

- Payment gateway integration (Stripe/Paypal)
- Order status webhooks
- Ticket QR code image generation
- Organizer entity & management
- Advanced audit logging
- Soft delete support
- Event series/recurring events
- Waiting list management
- Real-time seat availability WebSocket
- Notification system (Phase 8)

## Future Enhancements

- Organizer entity (currently string organizerId)
- Seat availability service (not stored in DB)
- Payment gateway integration
- Refund workflows
- Event series/recurring events
- Dynamic pricing/surge pricing
- Waitlist management
- Social sharing & reviews
- Advanced reporting & analytics
