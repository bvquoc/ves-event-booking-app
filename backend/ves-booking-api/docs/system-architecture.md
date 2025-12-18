# VES Booking API - System Architecture

**Phase 2: Reference Data APIs - Complete**

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                             │
│  (Web, Mobile, Admin Portal)                                 │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTP/REST
┌────────────────────▼────────────────────────────────────────┐
│                  API LAYER                                   │
│  Spring Boot 3.2.2 Application                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Controllers                                          │   │
│  │ ├── AuthenticationController ✅ (Auth endpoints)     │   │
│  │ ├── UserController ✅ (User management)              │   │
│  │ ├── RoleController ✅ (Role RBAC)                    │   │
│  │ ├── PermissionController ✅                          │   │
│  │ ├── CategoryController ✅ (Reference data)           │   │
│  │ ├── CityController ✅ (Reference data)               │   │
│  │ ├── TicketController ✅ (Phase 6: GET/PUT cancel)     │   │
│  │ ├── EventController 🚧 (Event CRUD - Phase 3)        │   │
│  │ ├── VoucherController ✅ (Phase 7: Vouchers)         │   │
│  │ ├── OrderController 🚧 (Order mgmt - Phase 8+)       │   │
│  │ └── NotificationController 🚧                        │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Security Layer                                       │   │
│  │ ├── JWT Authentication (OAuth2 Resource Server)     │   │
│  │ ├── Role-Based Access Control (RBAC)                │   │
│  │ ├── Request Validation & Sanitization               │   │
│  │ └── Token Introspection & Refresh                    │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                  SERVICE LAYER                               │
│  Business Logic & Domain Services                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Authentication & Security                           │   │
│  │ ├── AuthenticationService ✅                         │   │
│  │ ├── JwtTokenProvider                                │   │
│  │ └── PasswordEncoder (BCrypt)                         │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ User & Access Management                            │   │
│  │ ├── UserService ✅                                   │   │
│  │ ├── RoleService ✅                                   │   │
│  │ └── PermissionService ✅                             │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Event Management 🚧                                  │   │
│  │ ├── EventService                                    │   │
│  │ ├── CategoryService                                 │   │
│  │ ├── CityService                                     │   │
│  │ └── VenueService                                    │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Booking & Ticket Management 🚧                       │   │
│  │ ├── OrderService                                    │   │
│  │ ├── TicketService                                   │   │
│  │ ├── TicketTypeService                               │   │
│  │ ├── SeatAvailabilityService                          │   │
│  │ └── QRCodeGeneratorService                           │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Promotions & Discounts ✅ (Phase 7)                  │   │
│  │ └── VoucherService                                  │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ User Experience 🚧                                   │   │
│  │ ├── NotificationService                             │   │
│  │ ├── FavoriteService                                 │   │
│  │ └── UserVoucherService                               │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Cross-cutting Concerns                              │   │
│  │ ├── ValidationService                               │   │
│  │ ├── NotificationPublisher                            │   │
│  │ └── ErrorHandler                                    │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│              REPOSITORY LAYER (Data Access)                  │
│  JPA/Hibernate Spring Data Repositories                     │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Identity Repositories                               │   │
│  │ ├── UserRepository ✅                                │   │
│  │ ├── RoleRepository ✅                                │   │
│  │ ├── PermissionRepository ✅                          │   │
│  │ └── InvalidatedTokenRepository ✅                    │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Event Repositories 🚧                                │   │
│  │ ├── EventRepository                                 │   │
│  │ ├── CategoryRepository                              │   │
│  │ ├── CityRepository                                  │   │
│  │ └── VenueRepository                                 │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Booking Repositories ✅ (Phase 5)                    │   │
│  │ ├── OrderRepository ✅                               │   │
│  │ ├── TicketRepository ✅                              │   │
│  │ ├── TicketTypeRepository ✅                          │   │
│  │ └── SeatRepository ✅                                │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Promotion Repositories ✅ (Phase 7)                  │   │
│  │ ├── VoucherRepository ✅                             │   │
│  │ └── UserVoucherRepository ✅                         │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ User Preference Repositories 🚧                      │   │
│  │ ├── FavoriteRepository                              │   │
│  │ └── NotificationRepository                          │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                 DATABASE LAYER                               │
│  MySQL 8.0                                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ 24 Tables with Strategic Indexes                     │   │
│  │ ├── Identity Management (6 tables + mappings)        │   │
│  │ ├── Event Management (4 tables + collections)        │   │
│  │ ├── Booking & Tickets (4 tables)                     │   │
│  │ ├── Promotions (2 tables)                            │   │
│  │ ├── User Preferences (2 tables)                      │   │
│  │ └── System (1 table)                                 │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────┘
```

---

## Component Details

### 1. API Layer

#### Controllers (Spring MVC)
Request handling, input validation, response formatting.

**Implemented:**
- AuthenticationController - Login, refresh, introspect, logout
- UserController - CRUD user operations
- RoleController - Role management
- PermissionController - Permission management
- CategoryController - Get all categories with event counts (public)
- CityController - Get all cities with event counts (public)

**To Implement:**
- EventController - Event discovery, search, details
- OrderController - Order creation, status tracking
- TicketController - Ticket details, QR codes, check-in
- VoucherController - Voucher discovery, validation
- NotificationController - Notification retrieval, marking read

#### Security & Validation
- JWT token extraction from Authorization header
- RBAC enforcement via @PreAuthorize annotations
- Input validation using Jakarta Validation
- Custom validators for business logic
- Exception handling & standardized error responses

### 2. Service Layer

#### AuthenticationService ✅
- User login with username/password
- Token generation (Access + Refresh tokens)
- Token validation & introspection
- Token refresh mechanism
- Logout & token invalidation
- Password verification using BCrypt

#### UserService ✅
- CRUD operations
- Profile management
- Batch operations
- Role assignment
- Active/inactive status

#### RoleService ✅
- Role creation & deletion
- Permission assignment
- Predefined roles initialization (ADMIN, USER)

#### PermissionService ✅
- Permission CRUD
- Permission codes & descriptions

#### CategoryService ✅
- Get all categories
- Retrieve event count per category
- Performance optimized with single JOIN query
- Prevents N+1 query problems

#### CityService ✅
- Get all cities
- Retrieve event count per city
- Optimized query execution
- Returns all cities regardless of event count

#### EventService 🚧 (Planned)
- Event CRUD operations
- Event publishing workflow
- Search & filtering (category, city, date range, trending)
- Event capacity validation
- Slug generation & uniqueness

#### TicketTypeService 🚧 (Planned)
- Ticket type management
- Availability tracking
- Price management
- Seat requirement validation

#### BookingService ✅ (Phase 5)

- Purchase ticket processing
- SERIALIZABLE transaction isolation
- Event & ticket type validation
- Seat availability checking & reservation
- Voucher validation & discount calculation
- Order creation (status: PENDING, 15min expiry)
- Ticket generation (status: ACTIVE)
- QR code generation (mock)
- Payment URL generation (mock)
- Optimistic locking prevents overselling

#### TicketService ✅ (Phase 6)

- List user tickets with status filter & pagination
- Get ticket details (with ownership validation)
- Cancel ticket with refund processing
- Refund status tracking (PENDING → PROCESSING → COMPLETED/FAILED)
- Status transitions (ACTIVE → CANCELLED → REFUNDED)
- Seat release on cancellation

#### CancellationService ✅ (Phase 6)

- Time-based refund calculation:
  - Greater than 48 hours before event: 80% refund
  - 24-48 hours before event: 50% refund
  - Less than 24 hours before event: NOT cancellable
- Refund amount calculation based on ticket price
- Refund percentage tracking

#### OrderService 🚧 (Planned - Phase 7+)

- Order completion workflow
- Payment status tracking
- Order expiration handling (15min timeout)
- Order cancellation & refund initiation
- Ticket generation completion

#### SeatAvailabilityService 🚧 (Planned - Phase 7+)
- Real-time seat status calculation
- Seat reservation (15 min temp hold)
- Seat release on order expiration
- Seat occupancy tracking per event

#### VoucherService ✅ (Phase 7)

- Get public vouchers (isPublic=true, not expired)
- Get user vouchers (status filter: active/used/expired/all)
- 10-step voucher validation process:
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
- Discount types: FIXED_AMOUNT or PERCENTAGE
- Percentage calculations use long to prevent integer overflow
- Cap percentage discount at maxDiscount if specified
- Applicability: Empty lists = all events/categories, non-empty = specific restrictions
- Returns VoucherValidationResponse with discount breakdown

#### NotificationService 🚧 (Planned)
- Notification creation
- Notification retrieval & filtering
- Mark as read
- Notification type handling (TICKET_PURCHASED, EVENT_REMINDER, etc.)
- Scheduled reminders (24h before event)

### 3. Repository Layer

**Data Access Objects using Spring Data JPA**

All repositories extend JpaRepository for standard CRUD + pagination support.

**Custom Query Methods:**
- findByUsername, findByEmail (User)
- findBySlug (Event, Category, City)
- findByCode (Voucher)
- findByUserAndStatus (Order filtering)
- findByEventAndStartDateBetween (Event search)
- etc.

### 4. Database Layer

24 tables organized by domain:

**Identity (6 tables):**
- user, role, permission
- user_role, role_permission (M:M mappings)
- invalidated_token

**Events (4 + collections):**
- event (+ event_images, event_tags)
- category, city, venue, seat

**Bookings (4 tables):**
- order, ticket, ticket_type, (+ ticket_type_benefits)

**Promotions (2 tables):**
- voucher (+ applicable_events, applicable_categories)
- user_voucher

**Preferences (2 tables):**
- favorite, notification (+ notification_data)

---

## Key Architectural Patterns

### 1. Layered Architecture
Clean separation: Controller → Service → Repository → Database
- Controllers handle HTTP
- Services contain business logic
- Repositories abstract data access
- Entities define data models

### 2. Dependency Injection (Spring)
Constructor injection for testability & immutability.

### 3. Data Transfer Objects (DTOs)
Request & response DTOs separate external API contracts from internal models.
MapStruct for automatic mapping between entities & DTOs.

### 4. Repository Pattern
Abstraction layer for data access. Supports testing with in-memory implementations.

### 5. Service-Oriented Architecture
Services encapsulate domain logic. Easy to test, reuse, and maintain.

### 6. JWT-based Stateless Authentication
No session storage. Scalable across multiple instances.
Token structure: Header.Payload.Signature
- Payload contains user ID, roles, permissions
- Signature verified using secret key
- Refresh tokens enable long sessions

### 7. Role-Based Access Control (RBAC)
- Users assigned to Roles
- Roles have Permissions
- @PreAuthorize("hasRole('ADMIN')") for endpoint security

### 8. Error Handling Strategy
- Centralized exception handling via @ControllerAdvice
- Standardized error response format
- Error codes mapped to HTTP status codes
- Messages support parameterization

---

## Data Flow Examples

### Authentication Flow
```
Client Login (username, password)
    ↓
AuthenticationController.login()
    ↓
AuthenticationService.authenticate()
    ↓
UserRepository.findByUsername()
    ↓
Password validation (BCrypt)
    ↓
JWT token generation
    ↓
Return {accessToken, refreshToken, expiresIn}
```

### Event Booking Flow (Phase 5 - Implemented)
```
User selects event & ticket type
    ↓
TicketController.purchaseTickets(PurchaseRequest)
    ↓
BookingService.purchaseTickets() [SERIALIZABLE isolation]
    ├─ Get current authenticated user
    ├─ Validate event exists
    ├─ Validate & lock ticket type (@Version)
    ├─ Check ticket availability (quantity)
    ├─ Validate max per order limit
    ├─ Handle seat selection if required
    │  ├─ Validate seat count matches quantity
    │  ├─ Check seats not already occupied
    │  └─ Load seat entities
    ├─ Validate voucher if provided
    │  ├─ Check validity period
    │  ├─ Check usage limit
    │  ├─ Check min order amount
    │  └─ Check event/category applicability
    ├─ Calculate pricing with discount
    ├─ Create Order (status: PENDING, 15min expiry)
    ├─ Create Ticket entities (status: ACTIVE)
    ├─ Reserve seats (if applicable)
    ├─ Decrement available count (optimistic lock prevents overselling)
    └─ Generate mock payment URL & QR codes
    ↓
Return OrderResponse with payment details
    ↓
User completes payment (external gateway)
    ↓
Payment webhook callback [Future Phase]
    ↓
OrderService.completeOrder() [Future]
    ├─ Confirm seat reservations → SOLD
    ├─ Generate QR code images [Future]
    ├─ Send confirmation notification
    └─ Update Order status: COMPLETED
    ↓
User receives tickets with QR codes
```

**Transaction Safety:**

- SERIALIZABLE isolation prevents dirty reads & phantom reads
- Optimistic locking (@Version) prevents concurrent overselling
- If concurrent purchase: OptimisticLockingFailureException thrown
- Client retries with exponential backoff
- Seats marked RESERVED during PENDING phase
- Auto-released if order expires (not completed within 15min)

### Event Discovery Flow (Future)
```
User searches events (category, city, date, keyword)
    ↓
EventController.search()
    ↓
EventService.search()
    ├─ Filter by category_id
    ├─ Filter by city_id
    ├─ Filter by startDate range
    ├─ Full-text search on name/description
    └─ Sort by trending, startDate
    ↓
EventRepository.findByCriteria()
    ↓
Return paginated results with availability
```

---

## Technical Constraints & Decisions

### 1. UUID for Primary Keys
- **Reason:** Distributed system readiness, no sequential ID leakage
- **Trade-off:** Larger indexes, slightly slower queries
- **Mitigation:** Strategic indexes on frequently queried columns

### 2. MySQL over NoSQL
- **Reason:** Relational data, ACID compliance needed, complex queries
- **Use Cases:** User-Role relationships, Order-Ticket-Seat relationships

### 3. JPA/Hibernate
- **Reason:** Standard Java ORM, reduces boilerplate SQL
- **Trade-off:** Less control over exact SQL, potential N+1 queries
- **Mitigation:** Proper fetch strategies, query optimization

### 4. JWT Stateless Auth
- **Reason:** Scalability, no session replication needed
- **Trade-off:** Cannot immediately invalidate token (use blacklist)
- **Solution:** InvalidatedToken table for logout support

### 5. Enum-based Error Codes
- **Reason:** Type safety, prevents invalid codes
- **Structure:** Range-based categorization (1xxx, 2xxx, etc.)

### 6. Element Collections over Separate Tables
- **Reason:** Simplify schema for small variable collections (tags, benefits)
- **Trade-off:** Cannot query element values directly
- **Mitigation:** Prefer separate tables if complex querying needed

---

## Security Architecture

### Authentication
1. Credentials validated against user table (BCrypt password)
2. JWT token generated (user ID, roles, permissions in payload)
3. Token signed with private key
4. Token returned to client

### Authorization
1. Token sent in Authorization: Bearer <token> header
2. TokenProvider validates signature
3. Payload extracted (user ID, roles, permissions)
4. @PreAuthorize checks role/permission

### Password Security
- BCrypt with strength 10 (rounds)
- Salted hashing
- Never stored in plaintext

### Token Security
- HTTPS/TLS in production
- Access tokens: 1 hour expiry
- Refresh tokens: 10 hours expiry
- Blacklist for logout support

### Input Validation
- Jakarta Validation annotations (@NotNull, @Email, etc.)
- Custom validators for business rules
- Sanitization of string inputs

---

## Performance Considerations

### Database Indexes
- Event: slug (unique), startDate, category_id
- Order: user_id, status
- Notification: user_id, isRead
- Voucher: code (unique)

### Query Optimization
- Lazy loading for relationships (avoid N+1)
- Select specific columns when possible
- Pagination for large result sets

### Caching (Future)
- User roles/permissions caching
- Event metadata caching
- Voucher validity caching

### Connection Pooling
- HikariCP (default in Spring Boot)
- Configurable pool size based on load

---

## Deployment Architecture

### Local Development
- MySQL in Docker (docker-compose)
- Spring Boot with hot reload
- H2 in-memory for unit tests

### Production
- MySQL in managed service (AWS RDS, Azure, GCP)
- Spring Boot JAR deployment
- Docker containerization
- Load balancing for horizontal scaling
- Environment-based configuration

---

## API Response Format

### Success Response
```json
{
  "statusCode": 200,
  "message": "Operation successful",
  "data": {}
}
```

### Error Response
```json
{
  "statusCode": 400,
  "message": "Field validation failed",
  "errorCode": "INVALID_KEY",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

---

---

## Implementation Timeline

### Phase 1 (Complete)
- ✅ All 12 entities implemented (User, Role, Permission, Event, Category, City, Venue, Seat, TicketType, Order, Ticket, Voucher, etc.)
- ✅ All 7 enums defined (OrderStatus, TicketStatus, PaymentMethod, etc.)
- ✅ 24 tables with relationships
- ✅ Strategic indexing complete
- ✅ Audit timestamps configured
- ✅ Identity & Access Management (IAM)

### Phase 2 (Complete)
- ✅ CategoryService with event counts
- ✅ CityService with event counts
- ✅ CategoryController (public GET endpoint)
- ✅ CityController (public GET endpoint)
- ✅ CategoryRepository with custom JOIN query
- ✅ CityRepository with custom JOIN query
- ✅ Performance optimized (single query prevents N+1)
- ✅ Public endpoints configured in SecurityConfig
- ✅ User entity @Table annotation
- ✅ Category & City seeding in ApplicationInitConfig

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
- ✅ OrderRepository with order queries
- ✅ TicketRepository with seat occupation queries
- ✅ VoucherRepository for code-based lookups
- ✅ OrderMapper for Entity ↔ DTO conversion
- ✅ TicketType optimistic locking (@Version)
- ✅ SERIALIZABLE transaction isolation
- ✅ Seat reservation logic (PENDING → SOLD)
- ✅ Voucher validation & discount calculation
- ✅ Mock payment URL generation
- ✅ QR code generation (mock)
- ✅ Order expiry (15 minutes)

### Phase 6 (Current - Complete)

**Ticket Management & Cancellation:**

- ✅ GET /tickets - List user tickets (status filter, pagination)
- ✅ GET /tickets/{ticketId} - Get ticket details
- ✅ PUT /tickets/{ticketId}/cancel - Cancel ticket with refund
- ✅ CancellationService - Time-based refund policy
- ✅ TicketService - Ticket retrieval & cancellation
- ✅ Ownership validation - Users can only view/cancel their own tickets
- ✅ Seat release - Cancelled tickets increment TicketType.available
- ✅ Refund tracking - cancellationReason, cancelledAt, refundAmount, refundStatus fields
- ✅ Ticket entity updates for cancellation workflow
- ✅ TicketRepository extended with filter methods

### Phase 7 (Complete)

**Vouchers & Discounts:**

- ✅ GET /vouchers - List public vouchers (no auth, not expired)
- ✅ GET /vouchers/my-vouchers?status={status} - List user vouchers (authenticated)
- ✅ POST /vouchers/validate - Validate voucher & calculate discount
- ✅ VoucherService - 10-step validation process
- ✅ VoucherRepository with custom JPA queries (findByCode, findPublicActiveVouchers)
- ✅ UserVoucherRepository with status-based filters (findActiveByUserId, findUsedByUserId, findExpiredByUserId)
- ✅ Voucher entity with applicableEvents & applicableCategories element collections
- ✅ UserVoucher entity for user-specific voucher assignments & tracking
- ✅ VoucherDiscountType enum (FIXED_AMOUNT, PERCENTAGE)
- ✅ Validation: expiry check, usage limit, quantity check, min order amount, applicability
- ✅ Discount calculation with overflow protection (long for percentage)
- ✅ Error codes: VOUCHER_NOT_FOUND, VOUCHER_INVALID_OR_EXPIRED, VOUCHER_NOT_APPLICABLE, VOUCHER_USAGE_LIMIT_REACHED,
  MIN_ORDER_AMOUNT_NOT_MET
- ✅ Input validation: Voucher code regex ^[A-Z0-9_-]{3,30}$

### Phase 8+ (Planned)

- Payment gateway integration (Stripe/Paypal)
- Order status webhooks
- Ticket QR code image generation
- Organizer entity & management
- Advanced audit logging
- Soft delete support
- Event series/recurring events
- Waiting list management
- Real-time seat availability WebSocket
- Notification system

---

## Future Enhancements

1. **Event Recommendations** - ML-based personalization
2. **Real-time Notifications** - WebSocket integration
3. **Payment Gateway Integration** - Stripe, PayPal
4. **Advanced Analytics** - Event performance, user behavior
5. **Social Features** - Reviews, ratings, sharing
6. **Organizer Platform** - Event management dashboard
7. **Refund Workflows** - Automated refund processing
8. **Queue Management** - High-traffic event bookings
9. **Caching Layer** - Redis for performance
10. **Message Queue** - RabbitMQ/Kafka for async processing
