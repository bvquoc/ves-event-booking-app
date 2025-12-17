# VES Booking API - Documentation Index

**Current Phase:** Phase 1 - Foundation & Core Entities (Complete)

---

## Quick Navigation

### For Getting Started
1. Read main project **[README.md](/README.md)** for overview & setup
2. Review **[system-architecture.md](./system-architecture.md)** for design
3. Check **[codebase-summary.md](./codebase-summary.md)** for data model

### For Development
- **Database Schema:** [codebase-summary.md](./codebase-summary.md#database-schema-24-tables)
- **Entity Details:** [entity-relationships.md](./entity-relationships.md)
- **Error Codes:** [codebase-summary.md](./codebase-summary.md#error-codes-30)
- **Architecture:** [system-architecture.md](./system-architecture.md)

### For Reference
- **Entity Relationship Diagram:** [codebase-summary.md](./codebase-summary.md#entity-relationship-diagram)
- **Design Patterns:** [codebase-summary.md](./codebase-summary.md#key-design-patterns)
- **Service Layer:** [system-architecture.md](./system-architecture.md#2-service-layer)

---

## Documentation Files

### 1. codebase-summary.md
**Comprehensive reference for database & entities**

- Project overview & tech stack
- 24-table database schema documentation
- Complete entity descriptions with fields & constraints
- 7 enum definitions with value explanations
- 30+ error codes organized by range
- Entity relationship diagram
- Key design patterns
- Constants & future enhancements

**Use when:** Designing features, understanding data model, looking up error codes

---

### 2. system-architecture.md
**High-level system design & component organization**

- Architecture layers (API → Service → Repository → Database)
- Component details (Controllers, Services, Repositories)
- Security architecture (JWT, RBAC)
- Database layer organization
- Key architectural patterns
- Data flow examples (Auth, Booking, Discovery)
- Technical constraints & decisions
- Performance considerations
- Deployment architecture

**Use when:** Understanding system design, implementing new features, performance tuning

---

### 3. entity-relationships.md
**Detailed entity & relationship documentation**

- 12 entity class documentation
  - Identity: User, Role, Permission, InvalidatedToken
  - Events: Event, Category, City, Venue, Seat
  - Bookings: TicketType, Order, Ticket
  - Promotions: Voucher, UserVoucher
  - Preferences: Favorite, Notification
- 7 enum specifications
- Relationship summary (1:M, M:1, M:M)
- Element collections
- Unique constraints & indexes
- Cascade strategies
- Fetch strategies
- Audit column tracking
- Foreign key constraints

**Use when:** Writing entity code, understanding relationships, working with specific entities

---

## Database Schema Overview

**24 Tables organized by domain:**

### Identity & Access Management
- user, role, permission
- user_role, role_permission (M:M mappings)
- invalidated_token

### Event Management
- event (with element collections: images, tags)
- category, city, venue, seat

### Booking & Tickets
- order, ticket, ticket_type (with element collection: benefits)

### Promotions
- voucher (with element collections: applicable_events, applicable_categories)
- user_voucher

### User Preferences
- favorite, notification (with element collection: data)

**Total Elements:** 24 tables + 8 element collections + 2 join tables

---

## Entity Overview

### 12 Core Entities

| Category | Entities | Status |
|----------|----------|--------|
| Identity | User, Role, Permission, InvalidatedToken | ✅ Complete |
| Events | Event, Category, City, Venue, Seat | ✅ Complete |
| Bookings | TicketType, Order, Ticket | ✅ Complete |
| Promotions | Voucher, UserVoucher | ✅ Complete |
| Preferences | Favorite, Notification | ✅ Complete |

---

## Enums (7 Total)

| Enum | Values | Usage |
|------|--------|-------|
| OrderStatus | PENDING, COMPLETED, CANCELLED, EXPIRED, REFUNDED | Order lifecycle |
| TicketStatus | ACTIVE, USED, CANCELLED, REFUNDED | Ticket state |
| SeatStatus | AVAILABLE, RESERVED, SOLD, BLOCKED | Seat availability |
| PaymentMethod | CREDIT_CARD, DEBIT_CARD, E_WALLET, BANK_TRANSFER | Payment options |
| NotificationType | TICKET_PURCHASED, EVENT_REMINDER, EVENT_CANCELLED, PROMOTION, SYSTEM | Notification types |
| VoucherDiscountType | FIXED_AMOUNT, PERCENTAGE | Discount calculation |
| RefundStatus | PENDING, PROCESSING, COMPLETED, FAILED | Refund tracking |

---

## API Architecture

### Layers

```
Controllers → Services → Repositories → Database
```

**Implemented ✅:**
- AuthenticationController, UserController, RoleController, PermissionController
- AuthenticationService, UserService, RoleService, PermissionService

**Planned 🚧:**
- Event, Order, Ticket, Voucher, Notification management

---

## Key Technologies

- **Framework:** Spring Boot 3.2.2
- **Language:** Java 21
- **Database:** MySQL 8.0
- **ORM:** JPA/Hibernate
- **Mapping:** MapStruct 1.5.5
- **Security:** Spring Security + JWT OAuth2
- **Validation:** Jakarta Validation
- **Build:** Maven 3.9.5+

---

## Design Highlights

### 1. UUID Primary Keys
Distributed system ready, no ID leakage.

### 2. Strategic Indexing
High-cardinality columns indexed:
- Event: slug, startDate, category_id
- Order: user_id, status
- Notification: user_id, isRead
- Voucher: code

### 3. Type-Safe Enums
All status fields use enums, preventing invalid values.

### 4. Audit Timestamps
All entities have createdAt (auto-set). Many have updatedAt (auto-updated).

### 5. Flexible Vouchers
Fixed amount or percentage discounts. Event/category applicability via element collections.

### 6. Optional Relationships
Seat & venue optional in Event (supports virtual events).

### 7. Clean Separation
Refund workflow separate from ticket lifecycle.

---

## Error Code Ranges

| Range | Category | Examples |
|-------|----------|----------|
| 1xxx | User & Auth | Username/password validation, authentication |
| 2xxx | Event errors | Event not found, invalid dates |
| 3xxx | Ticket errors | Type not found, unavailable, invalid quantity |
| 4xxx | Seat errors | Seat not found, already taken |
| 5xxx | Order errors | Order not found, expired, already completed |
| 6xxx | Voucher errors | Not found, invalid/expired, limit reached |
| 7xxx | Venue errors | Venue not found |
| 8xxx | Category/City | Category/City not found |
| 9xxx | Notifications | Notification not found |

Full list in [codebase-summary.md](./codebase-summary.md#error-codes-30)

---

## Development Workflow

### Adding a New Feature

1. **Understand Data Model**
   - Check [entity-relationships.md](./entity-relationships.md) for involved entities
   - Review relationships & constraints

2. **Design Database Changes**
   - Reference [codebase-summary.md](./codebase-summary.md#database-schema-24-tables) for schema
   - Plan indexes for query optimization

3. **Implement Services**
   - Follow patterns in [system-architecture.md](./system-architecture.md#2-service-layer)
   - Handle transactions carefully for booking flows

4. **Create Endpoints**
   - Follow controller patterns
   - Use error codes from [codebase-summary.md](./codebase-summary.md#error-codes-30)
   - Return standardized response format

5. **Add Tests**
   - Test entity relationships
   - Test service business logic
   - Mock repositories

---

## Relationship Examples

### User → Order → Ticket
```
User creates Order
  ↓
Order contains 1+ Tickets
  ↓
Ticket linked to Seat (if required), TicketType, Event
```

### Event → TicketType → Ticket
```
Event has multiple TicketTypes (VIP, Standard, etc.)
  ↓
Each TicketType has quantity available
  ↓
Order reserves TicketType quantity
  ↓
Tickets generated from completed Order
```

### Voucher → UserVoucher → Order
```
Voucher created (fixed or percentage)
  ↓
Assigned to User via UserVoucher
  ↓
Applied to Order for discount
  ↓
Marked as used in UserVoucher.isUsed
```

---

## Common Queries

### Find User Orders
```sql
SELECT o.* FROM orders o
WHERE o.user_id = ?
ORDER BY o.createdAt DESC;
```

### Check Ticket Availability
```sql
SELECT tt.available FROM ticket_type tt
WHERE tt.event_id = ? AND tt.id = ?;
```

### Get Event with Details
```sql
SELECT e.*, c.name as categoryName, city.name as cityName
FROM event e
JOIN category c ON e.category_id = c.id
JOIN city ON e.city_id = city.id
WHERE e.slug = ?;
```

### Validate Voucher
```sql
SELECT v.* FROM voucher v
WHERE v.code = ?
AND v.startDate <= NOW()
AND v.endDate >= NOW()
AND (v.usageLimit IS NULL OR v.usedCount < v.usageLimit);
```

---

## Status Indicators

- ✅ **Complete** - Implemented & documented
- 🚧 **In Progress** - Currently being worked on
- 📋 **Planned** - Scheduled for future phase
- ⚠️ **Deprecated** - No longer used

---

## Quick Reference

### Phase 1: Foundation & Core Entities
- ✅ 12 entities implemented
- ✅ 24 tables created
- ✅ 7 enums defined
- ✅ 30+ error codes
- ✅ Complete documentation

### Phase 2: Service Layer & APIs (Planned)
- 📋 Service implementation for all entities
- 📋 REST API endpoints
- 📋 Request/Response DTOs
- 📋 Comprehensive error handling

### Phase 3+: Advanced Features (Future)
- 📋 Payment gateway integration
- 📋 Notification system
- 📋 Analytics & reporting
- 📋 Admin dashboard

---

## For Questions or Issues

1. **Database schema:** See [codebase-summary.md](./codebase-summary.md)
2. **Architecture decisions:** See [system-architecture.md](./system-architecture.md)
3. **Entity details:** See [entity-relationships.md](./entity-relationships.md)
4. **Error handling:** See error codes in [codebase-summary.md](./codebase-summary.md#error-codes-30)
5. **Design patterns:** See [codebase-summary.md](./codebase-summary.md#key-design-patterns)

---

**Last Updated:** 2025-12-17
**Phase 1 Status:** ✅ COMPLETE
**Documentation Coverage:** 100%
