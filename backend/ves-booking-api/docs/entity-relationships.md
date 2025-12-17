# VES Booking API - Entity Relationship Documentation

**Phase 1 Complete: 12 Core Entities + 7 Enums**

---

## Entity Class Hierarchy

### Identity & Access Management Entities

#### User Entity
JPA entity representing application users. Base for authentication & user management.

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- username: String (UNIQUE, NOT NULL)
- password: String (NOT NULL, BCrypt hashed)
- email: String (UNIQUE, NOT NULL)
- phone, firstName, lastName, avatar: String
- isActive: Boolean (default: true)
- createdAt, updatedAt: LocalDateTime

**Relationships:**
- roles: List<Role> (M:M via user_role table)
- orders: List<Order> (1:M)
- tickets: List<Ticket> (1:M)
- favorites: List<Favorite> (1:M)
- notifications: List<Notification> (1:M)
- userVouchers: List<UserVoucher> (1:M)

**Index:** id, username, email

**Lifecycle:**
- @PrePersist: Auto-set timestamps
- Password hashed via BCrypt before persistence

---

#### Role Entity
Represents user roles for authorization. Used for RBAC.

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- name: String (UNIQUE, NOT NULL) - e.g., "ADMIN", "USER"
- description: String

**Relationships:**
- users: List<User> (M:M via user_role table)
- permissions: List<Permission> (M:M via role_permission table)

**Index:** id, name

**Predefined Roles:**
- ADMIN - Full system access
- USER - Standard user for event booking
- ORGANIZER - Event organizer (future)

---

#### Permission Entity
Fine-grained permissions for authorization checks.

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- code: String (UNIQUE, NOT NULL) - e.g., "CREATE_EVENT", "DELETE_USER"
- description: String

**Relationships:**
- roles: List<Role> (M:M via role_permission table)

**Index:** id, code

---

#### InvalidatedToken Entity
Token blacklist for logout support. Stores JTI (JWT ID) of invalidated tokens.

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- jti: String (UNIQUE, NOT NULL) - JWT ID from token
- expiryTime: LocalDateTime - When token expires

**Relationships:** None

**Index:** id, jti

**Usage:**
- On logout, token JTI added to blacklist
- On token validation, check if JTI in blacklist
- Cleanup job removes expired tokens

---

### Event Management Entities

#### Event Entity
Core entity representing events. Contains comprehensive event information.

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- name: String (NOT NULL)
- slug: String (UNIQUE, NOT NULL) - URL-friendly identifier
- description: String (TEXT)
- longDescription: String (TEXT)
- thumbnail: String - Cover image URL
- startDate: LocalDateTime (NOT NULL)
- endDate: LocalDateTime
- currency: String - e.g., "VND"
- isTrending: Boolean
- organizerId: String - Future FK to Organizer
- organizerName: String
- organizerLogo: String
- terms: String (TEXT) - Event terms & conditions
- cancellationPolicy: String (TEXT)
- createdAt: LocalDateTime (NOT NULL)
- updatedAt: LocalDateTime

**Relationships:**
- category: Category (M:1, NOT NULL) - Event category
- city: City (M:1, NOT NULL) - Location
- venue: Venue (M:1, optional) - Physical venue
- ticketTypes: List<TicketType> (1:M) - Ticket tiers
- orders: List<Order> (1:M)
- tickets: List<Ticket> (1:M)
- favorites: List<Favorite> (1:M)

**Element Collections:**
- images: List<String> - Additional event images (table: event_images)
- tags: List<String> - Event tags for discovery (table: event_tags)

**Indexes:**
- idx_event_slug (slug)
- idx_event_start_date (startDate)
- idx_event_category (category_id)

**Denormalization:**
- venueName, venueAddress stored for search efficiency

**Lifecycle:**
- @PrePersist: Auto-set createdAt, updatedAt
- @PreUpdate: Auto-update updatedAt

---

#### Category Entity
Event categories (Music, Sports, Theater, etc.). Enables categorization & filtering.

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- name: String (UNIQUE, NOT NULL) - e.g., "Music", "Sports"
- slug: String (UNIQUE, NOT NULL) - URL-friendly
- icon: String - Icon image URL

**Relationships:**
- events: List<Event> (1:M)

**Indexes:**
- idx_category_name (name)
- idx_category_slug (slug)

---

#### City Entity
Geographic locations for event discovery & filtering.

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- name: String (NOT NULL) - e.g., "Ho Chi Minh City"
- slug: String (UNIQUE, NOT NULL) - e.g., "ho-chi-minh-city"

**Relationships:**
- events: List<Event> (1:M)
- venues: List<Venue> (1:M)

**Indexes:**
- idx_city_slug (slug)

---

#### Venue Entity
Physical venue information. Hosts events & seats.

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- name: String (NOT NULL)
- address: String (TEXT)
- capacity: Integer - Total venue capacity

**Relationships:**
- city: City (M:1)
- seats: List<Seat> (1:M) - Physical seats

**Indexes:** id, city_id

---

#### Seat Entity
Individual seats in a venue. Venue layout definition.

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- venue: Venue (M:1, NOT NULL)
- sectionName: String (NOT NULL) - e.g., "VIP Section", "General Admission"
- rowName: String (NOT NULL) - e.g., "A", "B", "VIP-01"
- seatNumber: String (NOT NULL) - e.g., "A12" - Composite: rowName + number

**Relationships:**
- venue: Venue (M:1)
- tickets: List<Ticket> (1:M) - Tickets assigned to seat (if reserved)

**Note:** Seat status (AVAILABLE, RESERVED, SOLD, BLOCKED) NOT stored. Calculated per-event by SeatAvailabilityService.

**Composite Unique:** (sectionName, rowName, seatNumber) per venue

---

### Ticket Management Entities

#### TicketType Entity
Defines ticket tiers for an event. E.g., VIP, Standard, Economy.

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- event: Event (M:1, NOT NULL)
- name: String (NOT NULL) - e.g., "VIP TICKET", "STANDARD TICKET"
- description: String (TEXT)
- price: Integer (NOT NULL) - Price in smallest unit (cents/satoshi)
- currency: String - e.g., "VND"
- available: Integer (NOT NULL) - Current available quantity
- maxPerOrder: Integer - Max tickets per single order
- requiresSeatSelection: Boolean (NOT NULL) - If seats required for this tier

**Relationships:**
- event: Event (M:1)
- tickets: List<Ticket> (1:M)

**Element Collections:**
- benefits: List<String> - Ticket benefits (table: ticket_type_benefits)
  - E.g., ["Free parking", "VIP lounge access", "Exclusive merchandise"]

**Indexes:** id, event_id

---

#### Order Entity
Purchase order representing user booking. Tracks order lifecycle.

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- user: User (M:1, NOT NULL)
- event: Event (M:1, NOT NULL)
- ticketType: TicketType (M:1, NOT NULL)
- quantity: Integer (NOT NULL)
- subtotal: Integer (NOT NULL) - Before discount
- discount: Integer - Applied discount amount
- total: Integer (NOT NULL) - Final amount
- currency: String
- voucher: Voucher (M:1, optional) - Applied voucher
- status: OrderStatus (NOT NULL) - PENDING, COMPLETED, CANCELLED, EXPIRED, REFUNDED
- paymentMethod: PaymentMethod - CREDIT_CARD, DEBIT_CARD, E_WALLET, BANK_TRANSFER
- paymentUrl: String - Mock payment gateway URL
- expiresAt: LocalDateTime - Payment timeout (15 min from creation)
- createdAt: LocalDateTime (NOT NULL)
- completedAt: LocalDateTime - When payment succeeded

**Relationships:**
- user: User (M:1)
- event: Event (M:1)
- ticketType: TicketType (M:1)
- voucher: Voucher (M:1, optional)
- tickets: List<Ticket> (1:M) - Tickets generated from order
- userVoucher: UserVoucher (1:1, optional) - If voucher was used

**Indexes:**
- idx_order_user (user_id)
- idx_order_status (status)

**Status Transitions:**
```
PENDING → COMPLETED (payment success)
       ↘ EXPIRED (timeout after 15 min)
       ↘ CANCELLED (user cancelled)

COMPLETED → REFUNDED (refund initiated)
```

**Lifecycle:**
- @PrePersist: Auto-set createdAt
- expiresAt calculated: createdAt + 15 minutes

---

#### Ticket Entity
Individual ticket issued from order. One ticket per seat (if required).

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- order: Order (M:1, NOT NULL)
- user: User (M:1, NOT NULL)
- event: Event (M:1, NOT NULL)
- ticketType: TicketType (M:1, NOT NULL)
- seat: Seat (M:1, optional) - If seat-based ticket
- qrCode: String (UNIQUE, NOT NULL) - QR code value
- qrCodeImage: String - QR code image URL
- status: TicketStatus (NOT NULL) - ACTIVE, USED, CANCELLED, REFUNDED
- refundStatus: RefundStatus - PENDING, PROCESSING, COMPLETED, FAILED
- checkedInAt: LocalDateTime - Event check-in time
- refundedAt: LocalDateTime - Refund completion time
- createdAt: LocalDateTime (NOT NULL)

**Relationships:**
- order: Order (M:1)
- user: User (M:1)
- event: Event (M:1)
- ticketType: TicketType (M:1)
- seat: Seat (M:1, optional)

**Indexes:** id, order_id, user_id, event_id, qrCode

**Unique Constraint:** qrCode

**Status Transitions:**
```
ACTIVE → USED (event check-in)
      ↘ CANCELLED (before event)
      ↘ REFUNDED (refund processing)
```

**Lifecycle:**
- @PrePersist: Auto-set createdAt
- QR code generated on order completion

---

### Promotion Entities

#### Voucher Entity
Discount vouchers. Supports fixed amount or percentage-based discounts.

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- code: String (UNIQUE, NOT NULL) - e.g., "SUMMER2024", "FIRST20"
- title: String (NOT NULL) - Display name
- description: String (TEXT)
- discountType: VoucherDiscountType (NOT NULL) - FIXED_AMOUNT or PERCENTAGE
- discountValue: Integer (NOT NULL) - Amount or percentage
- minOrderAmount: Integer - Minimum order to apply
- maxDiscount: Integer - Max discount for percentage type
- startDate: LocalDateTime (NOT NULL)
- endDate: LocalDateTime (NOT NULL)
- usageLimit: Integer - Max uses (null = unlimited)
- usedCount: Integer (NOT NULL) - Current usage count
- isPublic: Boolean - Visible to all users

**Relationships:**
- orders: List<Order> (1:M)
- userVouchers: List<UserVoucher> (1:M)

**Element Collections:**
- applicableEvents: List<String> - Event IDs (table: voucher_applicable_events)
  - Empty = applicable to all events
- applicableCategories: List<String> - Category slugs (table: voucher_applicable_categories)
  - Empty = applicable to all categories

**Indexes:**
- idx_voucher_code (code)

**Validation Logic:**
- Check if within date range (startDate ≤ now ≤ endDate)
- Check usage count < usageLimit (if limit set)
- Check order total ≥ minOrderAmount
- Check event in applicableEvents (if list not empty)
- Check event category in applicableCategories (if list not empty)

---

#### UserVoucher Entity
User-voucher assignment & usage tracking.

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- user: User (M:1, NOT NULL)
- voucher: Voucher (M:1, NOT NULL)
- isUsed: Boolean (NOT NULL) - Voucher consumed or not
- usedAt: LocalDateTime - When voucher was used
- order: Order (M:1, optional) - Which order used it
- addedAt: LocalDateTime (NOT NULL) - When added to user

**Relationships:**
- user: User (M:1)
- voucher: Voucher (M:1)
- order: Order (M:1, optional)

**Unique Constraint:** (user_id, voucher_id) - One voucher per user

**Lifecycle:**
- @PrePersist: Auto-set addedAt, isUsed = false

**Status Transitions:**
```
isUsed: false → true (when applied to order)
usedAt: null → timestamp (on usage)
order: null → Order (which order used it)
```

---

### User Preference Entities

#### Favorite Entity
User favorite events for quick access & discovery.

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- user: User (M:1, NOT NULL)
- event: Event (M:1, NOT NULL)
- createdAt: LocalDateTime (NOT NULL)

**Relationships:**
- user: User (M:1)
- event: Event (M:1)

**Unique Constraint:** (user_id, event_id) - One favorite per event per user

**Lifecycle:**
- @PrePersist: Auto-set createdAt

---

#### Notification Entity
User notifications (order confirmations, event reminders, promotions).

**Package:** `com.uit.vesbookingapi.entity`

**Key Fields:**
- id: UUID (PK)
- user: User (M:1, NOT NULL)
- type: NotificationType (NOT NULL) - TICKET_PURCHASED, EVENT_REMINDER, etc.
- title: String (NOT NULL)
- message: String (TEXT, NOT NULL)
- isRead: Boolean (NOT NULL) - Marking as read
- createdAt: LocalDateTime (NOT NULL)

**Relationships:**
- user: User (M:1)

**Element Collections:**
- data: Map<String, String> (table: notification_data)
  - Stores contextual data: eventId, orderId, ticketId, etc.
  - E.g., {"eventId": "uuid-123", "orderId": "uuid-456"}

**Indexes:**
- idx_notification_user (user_id) - For listing user notifications
- idx_notification_read (isRead) - For unread count queries

**Lifecycle:**
- @PrePersist: Auto-set createdAt, isRead = false

---

## Relationship Summary

### One-to-Many Relationships
- User → Order, Ticket, Favorite, Notification, UserVoucher (1:M)
- Event → TicketType, Order, Ticket, Favorite (1:M)
- TicketType → Ticket (1:M)
- Order → Ticket (1:M)
- Category → Event (1:M)
- City → Event, Venue (1:M)
- Venue → Seat (1:M)
- Voucher → Order, UserVoucher (1:M)
- Role → Permission (M:M via user_role, role_permission)

### Many-to-One Relationships
- Order → User, Event, TicketType, Voucher
- Ticket → Order, User, Event, TicketType, Seat
- Event → Category, City, Venue
- Venue → City
- Seat → Venue
- TicketType → Event
- UserVoucher → User, Voucher, Order
- Favorite → User, Event
- Notification → User

### Many-to-Many Relationships
- User ↔ Role (via user_role join table)
- Role ↔ Permission (via role_permission join table)

---

## Element Collections

Collections of values stored in separate tables:

| Parent Entity | Collection | Table | Column |
|---------------|-----------|-------|--------|
| Event | images | event_images | image_url |
| Event | tags | event_tags | tag |
| TicketType | benefits | ticket_type_benefits | benefit |
| Voucher | applicableEvents | voucher_applicable_events | event_id |
| Voucher | applicableCategories | voucher_applicable_categories | category_slug |
| Notification | data | notification_data | data_key, data_value (Map) |

---

## Unique Constraints

| Table | Constraint | Purpose |
|-------|-----------|---------|
| user | username, email | Prevent duplicates |
| event | slug | URL-friendly ID |
| category | name, slug | Unique category |
| city | slug | Unique city identifier |
| voucher | code | Unique voucher code |
| ticket | qrCode | Unique ticket identifier |
| favorite | (user_id, event_id) | One favorite per event per user |
| user_voucher | (user_id, voucher_id) | One instance per user per voucher |

---

## Inheritance Patterns

**No table inheritance used.** All entities are concrete classes with individual tables.

**Reason:** Simplicity, direct SQL mapping, performance.

---

## Cascade Strategies

| Parent → Child | Strategy | Behavior |
|----------------|----------|----------|
| Event → TicketType | CascadeType.ALL | Delete event → delete ticket types |
| Order → Ticket | CascadeType.ALL | Delete order → delete tickets |
| Venue → Seat | CascadeType.ALL | Delete venue → delete seats |
| Notification → data | CascadeType.ALL | Delete notification → delete data |
| Event → images | CascadeType.ALL | Delete event → delete images |
| Event → tags | CascadeType.ALL | Delete event → delete tags |
| TicketType → benefits | CascadeType.ALL | Delete type → delete benefits |
| Voucher → applicable_events | CascadeType.ALL | Delete voucher → delete applicability |
| Voucher → applicable_categories | CascadeType.ALL | Delete voucher → delete applicability |

**Careful:** Deleting high-level entities cascades to children. Use soft deletes or archive tables for audit.

---

## Fetch Strategies

### Current Configuration
Most relationships use **Lazy Loading** (default for @ManyToOne, @OneToMany).

**Reason:** Avoid N+1 queries, reduce memory usage.

**Optimization:** Explicitly join fetch in queries when loading related data:
```java
// Example: Load event with eager ticket types
@Query("SELECT e FROM Event e JOIN FETCH e.ticketTypes WHERE e.id = :id")
Event findWithTicketTypes(@Param("id") String id);
```

---

## Audit Columns

Timestamp tracking for compliance & debugging:

| Entity | Columns | Auto-set | Mutable |
|--------|---------|----------|--------|
| User | createdAt, updatedAt | @PrePersist, @PreUpdate | updatedAt only |
| Event | createdAt, updatedAt | @PrePersist, @PreUpdate | updatedAt only |
| Order | createdAt, completedAt | @PrePersist, manual | Both |
| Ticket | createdAt, checkedInAt, refundedAt | @PrePersist, manual | Manual |
| Favorite | createdAt | @PrePersist | No |
| Notification | createdAt | @PrePersist | No |
| UserVoucher | addedAt, usedAt | @PrePersist, manual | usedAt only |

---

## Foreign Key Constraints

**ON DELETE behavior:**

| FK | On Delete | Reason |
|----|-----------|--------|
| Order.user_id | RESTRICT/NO ACTION | Keep audit trail |
| Order.event_id | RESTRICT | Maintain history |
| Order.voucher_id | SET NULL | Voucher removal permitted |
| Ticket.order_id | CASCADE | Tickets tied to order |
| Ticket.seat_id | SET NULL | Seat can be released |
| UserVoucher.voucher_id | CASCADE | Clean up user references |

---

## Index Strategy

### Primary Keys
All entities have clustered index on UUID id.

### Secondary Indexes
High-cardinality columns & foreign keys:

| Table | Column | Type | Reason |
|-------|--------|------|--------|
| user | username, email | UNIQUE | Authentication |
| event | slug, startDate, category_id | NORMAL | Search/filter |
| order | user_id, status | NORMAL | Query user orders by status |
| ticket | qrCode, order_id | NORMAL | QR lookup, order tickets |
| voucher | code | UNIQUE | Voucher validation |
| notification | user_id, isRead | NORMAL | Unread notification count |

**Total indexes: 20+**

---

## Version History

**Phase 1 (Current):**
- ✅ All 12 entities implemented
- ✅ All 7 enums defined
- ✅ 24 tables with relationships
- ✅ Strategic indexing complete
- ✅ Audit timestamps configured

**Phase 2 (Planned):**
- Organizer entity
- Advanced audit logging
- Soft delete support
- Event series/recurring
- Waiting list management
