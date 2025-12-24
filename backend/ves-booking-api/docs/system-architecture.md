# VES Booking API - System Architecture

**Last Updated:** December 23, 2025
**Version:** 1.0.0
**Status:** Production Ready

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Component Architecture](#component-architecture)
3. [Data Flow](#data-flow)
4. [Payment Processing Architecture](#payment-processing-architecture)
5. [Database Schema](#database-schema)
6. [Security Architecture](#security-architecture)
7. [API Gateway & Routing](#api-gateway--routing)
8. [Concurrency & Transactions](#concurrency--transactions)
9. [Deployment Architecture](#deployment-architecture)
10. [Monitoring & Observability](#monitoring--observability)

## Architecture Overview

### Architectural Style

**Pattern:** Layered Architecture + Microservices-Ready Design

The application follows a strict separation of concerns with:

- **Presentation Layer:** REST Controllers (HTTP endpoints)
- **Service Layer:** Business logic and orchestration
- **Repository Layer:** Data access abstraction
- **Entity Layer:** Domain models and JPA entities
- **Infrastructure Layer:** Configuration and utilities

### High-Level System Diagram

```
┌────────────────────────────────────────────────────────┐
│                  Client Applications                     │
│              (Web Browser, Mobile App, API Client)       │
└────────────┬─────────────────────────────────────────┘
             │
             └─────────────────────────────┐
                                           │
┌──────────────────────────────────────────▼──────────────────┐
│                    Spring Security Layer                     │
│              (JWT Tokens, OAuth2 Resource Server)            │
└──────────────────────────────────────────┬──────────────────┘
                                           │
┌──────────────────────────────────────────▼──────────────────┐
│                  REST API Controllers                        │
│  (Auth, User, Event, Booking, Order, Payment Callbacks)    │
└──────────────────────────────────────────┬──────────────────┘
                                           │
┌──────────────────────────────────────────▼──────────────────┐
│                    Service Layer                            │
│  (Authentication, Event, Booking, Payment, ZaloPay)        │
└──────────────────────────────────────────┬──────────────────┘
                                           │
        ┌──────────────────────────────────┼──────────────────────────────┐
        │                                  │                              │
┌───────▼──────────┐         ┌─────────────▼────────────┐    ┌──────────▼────────┐
│  Scheduler Layer │         │  Repository Layer        │    │ External Services │
│                  │         │  (JPA Repositories)      │    │  (ZaloPay API)    │
│ - Reconciliation │         └─────────────┬────────────┘    └──────────┬────────┘
│ - Refund Retry   │                       │                           │
│ - Expiration     │                       │                           │
└────────┬─────────┘         ┌─────────────▼────────────┐              │
         │                   │   MySQL Database         │              │
         │                   │                          │              │
         │                   │ - Users, Roles, Perms    │              │
         │                   │ - Events, Bookings       │              │
         │                   │ - Payments, Audits       │              │
         │                   │ - Transactions, Refunds  │              │
         │                   └──────────────────────────┘              │
         │                                                              │
         └──────────────────────────────────────────────────────────────┘
```

## Component Architecture

### Core Components

#### 1. Authentication & Authorization Module

```
SecurityConfig
├── JwtAuthenticationFilter
│   ├── Token extraction from headers
│   └── Token validation
├── JwtAuthenticationEntryPoint
│   └── Unauthorized error handling
├── JwtTokenProvider
│   ├── Token generation (access + refresh)
│   └── Token validation
└── PasswordEncoder
    └── BCrypt hashing (strength: 10)
```

**Responsibilities:**

- JWT token generation and validation
- User authentication and identity verification
- Role-based access control (RBAC) enforcement
- Token blacklisting for logout
- Password security management

#### 2. Event Management Module

```
EventService
├── Event CRUD operations
├── Event search and filtering
├── Event capacity management
└── Category/City management

EventController
├── GET /events - List events
├── POST /events - Create event
├── PUT /events/{id} - Update event
└── DELETE /events/{id} - Delete event
```

**Responsibilities:**

- Event lifecycle management
- Ticket type configuration
- Availability tracking
- Category and venue management

#### 3. Booking & Order Module

```
BookingService
├── Order creation
├── Ticket allocation
├── Reservation tracking
└── Booking status management

OrderService
├── Order lifecycle
├── Payment coordination
└── Inventory management

TicketService
├── Ticket generation
├── Status tracking
└── Refund handling
```

**Responsibilities:**

- Booking and order processing
- Ticket generation and management
- Inventory tracking and allocation
- Order status workflow

#### 4. Payment Processing Module (NEW)

```
ZaloPayService
├── Order creation (→ payment URL)
├── Order status queries
├── Refund requests
└── Signature generation (HMAC-SHA256)

PaymentCallbackService
├── Callback verification
├── Order/ticket status updates
├── Transaction logging
└── Audit trail

PaymentCallbackController
├── POST /payments/zalopay/callback
└── POST /payments/zalopay/refund-callback

Schedulers
├── PaymentReconciliationScheduler (5-min)
└── RefundRetryScheduler (30-min)
```

**Responsibilities:**

- Payment gateway integration
- Webhook callback processing
- Automated reconciliation
- Refund management
- Transaction audit logging

### Service Layer Architecture

```
┌────────────────────────────────────────┐
│      Service Layer (Business Logic)     │
├────────────────────────────────────────┤
│                                        │
│  Authentication Service                │
│  ├─ User login/logout                  │
│  ├─ Token management                   │
│  └─ Authorization checks               │
│                                        │
│  User Service                          │
│  ├─ User CRUD                          │
│  ├─ Profile management                 │
│  └─ Permission assignment              │
│                                        │
│  Event Service                         │
│  ├─ Event management                   │
│  ├─ Category/city management           │
│  └─ Search & filtering                 │
│                                        │
│  Booking Service                       │
│  ├─ Booking creation                   │
│  ├─ Order processing                   │
│  └─ Ticket management                  │
│                                        │
│  Payment Service (ZaloPay)             │
│  ├─ Order creation                     │
│  ├─ Payment verification               │
│  ├─ Refund processing                  │
│  └─ Transaction logging                │
│                                        │
└────────────────────────────────────────┘
        ↓
┌────────────────────────────────────────┐
│   Repository Layer (Data Access)       │
├────────────────────────────────────────┤
│  UserRepository                        │
│  RoleRepository                        │
│  PermissionRepository                  │
│  EventRepository                       │
│  TicketRepository                      │
│  OrderRepository                       │
│  PaymentTransactionRepository          │
│  RefundRepository                      │
│  PaymentAuditLogRepository             │
└────────────────────────────────────────┘
        ↓
┌────────────────────────────────────────┐
│    MySQL Database (InnoDB)             │
│    (UTF-8, Asia/Ho_Chi_Minh TZ)       │
└────────────────────────────────────────┘
```

## Data Flow

### User Registration & Login Flow

```
1. POST /auth/login
   ├─ AuthenticationController receives request
   ├─ AuthenticationService validates credentials
   ├─ PasswordEncoder compares with stored hash
   ├─ JwtTokenProvider generates access + refresh tokens
   └─ Return tokens to client

2. Subsequent Requests
   ├─ Client includes Bearer token in header
   ├─ JwtAuthenticationFilter extracts token
   ├─ JwtTokenProvider validates signature & expiry
   ├─ SecurityContext loaded with user details
   └─ Request proceeds to controller
```

### Event Booking Flow

```
1. POST /orders
   ├─ BookingController receives request
   ├─ OrderService validates request
   │  ├─ Check event exists and has capacity
   │  ├─ Check user has no duplicate booking
   │  └─ Calculate total amount
   ├─ Create Order entity (status: PENDING_PAYMENT)
   ├─ Allocate Ticket entities
   └─ Invoke ZaloPayService → createOrder()

2. ZaloPayService → createOrder()
   ├─ Generate appTransId (YYMMDD_orderId)
   ├─ Build request payload
   ├─ Generate HMAC-SHA256 signature (key1)
   ├─ POST to ZaloPay /create endpoint
   ├─ Receive payment URL
   ├─ Save PaymentTransaction (CREATE type)
   └─ Return payment URL to client

3. Client → ZaloPay Payment
   ├─ Redirect to payment URL
   ├─ Customer completes payment
   └─ ZaloPay initiates callback

4. ZaloPay → Callback Webhook
   ├─ POST /payments/zalopay/callback
   ├─ PaymentCallbackController receives
   ├─ Verify IP whitelist (log warning)
   ├─ Extract data & mac from payload
   ├─ Verify MAC using key2
   ├─ PaymentCallbackService processes
   │  ├─ Find Order by appTransId
   │  ├─ Idempotency check (skip if COMPLETED)
   │  ├─ Verify amount matches
   │  ├─ Update Order status to COMPLETED
   │  ├─ Update Ticket statuses to ACTIVE
   │  └─ Save PaymentTransaction (CALLBACK type)
   └─ Return success (return_code: 1)

5. Reconciliation (every 5 minutes)
   ├─ PaymentReconciliationScheduler runs
   ├─ Find pending orders older than 5 minutes
   ├─ For each: call ZaloPayService.queryOrder()
   ├─ Query ZaloPay /query endpoint
   ├─ Update Order based on return code
   │  ├─ return_code=1 → COMPLETED
   │  ├─ return_code=2 → Still pending
   │  └─ return_code=3 → FAILED/EXPIRED
   └─ Expire stale orders (after 15 minutes)
```

### Payment Refund Flow

```
1. POST /tickets/{ticketId}/refund
   ├─ TicketController receives request
   ├─ TicketService validates request
   ├─ Find associated Order and get zpTransId
   ├─ Create Refund entity (status: PENDING)
   ├─ Generate mRefundId (YYMMDD_ticketId_count)
   └─ Invoke ZaloPayService.refund()

2. ZaloPayService.refund()
   ├─ Build request with HMAC-SHA256 signature (key1)
   ├─ POST to ZaloPay /refund endpoint
   ├─ Refund status changes to PROCESSING
   └─ Return refund status

3. Scheduled Retry (every 30 minutes)
   ├─ RefundRetryScheduler runs
   ├─ Find failed/processing refunds
   ├─ Retry failed refunds
   ├─ Update status based on response
   └─ Track attempt count

4. ZaloPay Refund Callback
   ├─ POST /payments/zalopay/refund-callback
   ├─ PaymentCallbackController receives
   ├─ PaymentCallbackService processes
   ├─ Update Refund status (COMPLETED/FAILED)
   └─ Update Ticket refund status
```

## Payment Processing Architecture

### Payment State Machine

```
                    CREATE REQUEST
                          │
                          ▼
    ┌─────────────────────────────────────┐
    │  Payment Initiated (PENDING)        │
    │  ├─ Order created                   │
    │  ├─ Tickets allocated               │
    │  └─ appTransId generated            │
    └────────────┬────────────────────────┘
                 │
    ┌────────────▼────────────────────────┐
    │  Awaiting Customer Payment          │
    │  ├─ Customer redirected to ZaloPay  │
    │  ├─ 5-min timeout for reconciliation│
    │  └─ 15-min timeout for expiration   │
    └────────────┬────────────────────────┘
                 │
         ┌───────┴───────┬──────────┐
         │               │          │
    Callback      Query Result    Timeout
   Received      from Scheduler   Expires
         │               │          │
         ▼               ▼          ▼
    ┌─────────┐  ┌──────────┐  ┌─────────┐
    │COMPLETED│  │COMPLETED │  │ EXPIRED │
    │ (Paid)  │  │  (Paid)  │  │(Timeout)│
    └─────────┘  └──────────┘  └─────────┘
         │               │          │
         │               │          │
         ├─→ Tickets Activated
         ├─→ Transaction Logged
         └─→ Order Confirmed
```

### Reconciliation Architecture

```
┌─────────────────────────────────────────────────────┐
│   Payment Reconciliation Scheduler (every 5 min)    │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. Find pending orders older than 5 minutes        │
│                                                     │
│  2. For each pending order:                         │
│     ├─ Query ZaloPay using appTransId              │
│     ├─ Get current payment status                  │
│     └─ Update Order based on ZaloPay response      │
│                                                     │
│  3. Return codes handling:                          │
│     ├─ 1 = Paid → Update to COMPLETED             │
│     ├─ 2 = Processing → Wait for next cycle        │
│     └─ 3 = Failed → Mark as FAILED                 │
│                                                     │
│  4. Expiration Scheduler (every 15 min):           │
│     ├─ Find orders expired by timeout              │
│     ├─ Update to EXPIRED status                    │
│     └─ Release tickets back to inventory            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Database Schema

### Entity Relationship Diagram

```
┌──────────┐           ┌──────────┐
│   User   │◄──────────┤   Role   │
└────┬─────┘           └──────────┘
     │
     │
┌────▼──────────────────────────────────────────┐
│                                               │
│  ┌─────────────┐  ┌──────────────┐           │
│  │   Event     │  │ EventCategory│           │
│  └──────┬──────┘  └──────────────┘           │
│         │                                    │
│    ┌────▼────────────────────────────────┐  │
│    │                                      │  │
│    ├──→ TicketType ──→ Ticket            │  │
│    │                      │               │  │
│    │                      ├──→ Order ◄───┘  │
│    │                      │      │          │
│    │                      │      ├──→ PaymentTransaction
│    │                      │      │          │
│    │                      └──┬───┘          │
│    │                         │              │
│    └─────────────────────────┘              │
│                                               │
└───────────────────────────────────────────────┘

PaymentTransaction (1) ──────┐
                              │
PaymentAuditLog ◄──────────┐  │
                            │  │
Refund ◄──────────────────┴──┘
       │
       └──→ Ticket
       └──→ Order
```

### Core Tables

**Users**

- id, username, email, password_hash, created_at, updated_at

**Orders**

- id, user_id, event_id, quantity, total_amount, status, appTransId, zpTransId, expiresAt, paymentConfirmedAt

**PaymentTransactions**

- id, order_id, app_trans_id, zp_trans_id, type, status, amount, return_code, request_payload, response_payload

**PaymentAuditLogs**

- id, order_id, app_trans_id, action, ip_address, payload, created_at

**Refunds**

- id, ticket_id, m_refund_id, zp_trans_id, amount, status, attempt_count, completed_at

## Security Architecture

### Authentication Flow

```
1. Client Login
   └─→ POST /auth/login with credentials

2. Authentication Service
   ├─ Find User by username
   ├─ Compare password with BCrypt hash
   └─ Generate JWT tokens

3. Token Structure
   Access Token:
   {
     "sub": "user_id",
     "roles": ["USER", "ADMIN"],
     "exp": 1703354400,  // 1 hour
     "iat": 1703350800
   }

4. Subsequent Requests
   └─→ Authorization: Bearer {access_token}

5. Token Validation
   ├─ Extract from header
   ├─ Verify signature (HS256)
   ├─ Check expiry
   ├─ Load user details
   └─ Set SecurityContext
```

### Payment Security

```
Request Signing (Key1):
1. Build data string: "app_id|app_trans_id|app_user|amount|app_time|embed_data|item"
2. Generate HMAC-SHA256 hash using key1
3. Include mac in request

Callback Verification (Key2):
1. Receive callback with data (base64) and mac
2. Generate HMAC-SHA256 hash of data using key2
3. Compare computed mac with received mac
4. Only process if verified

IP Whitelist (Optional in sandbox):
├─ 113.20.108.14-15 (Production)
├─ 118.69.77.70 (Sandbox)
└─ 127.0.0.1 (Local testing)

Idempotency:
├─ appTransId: YYMMDD_orderId (unique per order)
├─ mRefundId: YYMMDD_ticketId_count (unique per refund)
└─ Check before processing to prevent duplicates
```

## API Gateway & Routing

### REST API Structure

```
/api
├─ /auth
│  ├─ POST /login
│  ├─ POST /logout
│  ├─ POST /introspect
│  └─ POST /refresh
│
├─ /users
│  ├─ POST / (create)
│  ├─ GET / (list)
│  ├─ GET /{id}
│  ├─ PUT /{id}
│  └─ DELETE /{id}
│
├─ /events
│  ├─ POST / (create)
│  ├─ GET / (list + search)
│  ├─ GET /{id}
│  ├─ PUT /{id}
│  └─ DELETE /{id}
│
├─ /orders
│  ├─ POST / (create with payment)
│  ├─ GET / (list user's orders)
│  ├─ GET /{id}
│  └─ GET /{id}/status
│
├─ /tickets
│  ├─ GET /{id}
│  ├─ POST /{id}/refund
│  └─ GET /{id}/refund-status
│
└─ /payments
   └─ /zalopay
      ├─ POST /callback (webhook)
      ├─ POST /refund-callback (refund webhook)
      └─ GET /status/{appTransId} (query)
```

### Request/Response Cycle

```
Client Request
    │
    ├─→ Spring DispatcherServlet
    ├─→ Handler Mapping → Controller
    ├─→ Security Filter → JWT validation
    ├─→ Authorization Filter → RBAC check
    ├─→ Controller → Service → Repository
    ├─→ Database Query
    ├─→ Response Builder
    ├─→ Exception Handler (if needed)
    └─→ HTTP Response
        └─→ Client
```

## Concurrency & Transactions

### Transaction Management

```
@Transactional
Service Method
    │
    ├─ BEGIN TRANSACTION
    │
    ├─ Read Operation
    │  └─ SELECT with READ_COMMITTED isolation
    │
    ├─ Write Operation
    │  ├─ INSERT/UPDATE/DELETE
    │  └─ Triggers foreign key constraints
    │
    ├─ Concurrency Check
    │  └─ Version/timestamp for optimistic locking
    │
    └─ COMMIT or ROLLBACK
```

### Isolation Levels

- **Default:** READ_COMMITTED (MySQL InnoDB)
- **Critical transactions:** SERIALIZABLE (e.g., payment processing)
- **Lock timeout:** 5 seconds (configurable)

### Idempotency Implementation

```
Payment Processing:
1. appTransId = YYMMDD_orderId (globally unique)
2. Before processing callback:
   - Check if order already COMPLETED
   - If yes: return success (idempotent)
   - If no: process and update

Refund Processing:
1. mRefundId = YYMMDD_ticketId_refundCount
2. Before creating refund:
   - Check if mRefundId already exists
   - If yes: return existing refund status
   - If no: create and process
```

## Deployment Architecture

### Container Deployment

```
┌─────────────────────────────────────────┐
│          Docker Container               │
├─────────────────────────────────────────┤
│                                         │
│  JVM (Java 21)                          │
│  └─ Spring Boot Application             │
│     ├─ Server (port 8080)               │
│     ├─ Context Path (/api)              │
│     └─ Services & Schedulers            │
│                                         │
└─────────────────────────────────────────┘
         │
    ┌────┴────┐
    │          │
Linked to   External
    │
    └─→ MySQL Container
        ├─ Port: 3306
        ├─ Database: ves_booking_api
        └─ Username: root
```

### Environment Configuration

```
Development:
- Spring profiles: dev, test
- Database: local MySQL
- ZaloPay: sandbox endpoints
- Logging level: DEBUG

Production:
- Spring profiles: prod
- Database: managed MySQL (RDS/Cloud SQL)
- ZaloPay: production endpoints
- Logging level: INFO
- HTTPS: enforced
- Security headers: enabled
```

## Monitoring & Observability

### Logging Architecture

```
Application Logs
    │
    ├─ SLF4J (facade)
    ├─ Logback (implementation)
    ├─ Rolling file appender
    └─ Console appender

Log Levels:
- DEBUG: Detailed flow (dev only)
- INFO: Business logic milestones
- WARN: Potential issues
- ERROR: Failures & exceptions

Payment-Specific Logs:
- "Creating ZaloPay order: appTransId=..."
- "Payment confirmed: orderId=..."
- "Reconciliation: found N pending orders"
- "Callback processing error: ..."
```

### Metrics

```
Application Metrics:
- Request count by endpoint
- Response times (p50, p95, p99)
- Error rates
- Database query times

Payment Metrics:
- Orders created per minute
- Payment success rate
- Callback processing time
- Reconciliation duration
- Refund success rate
```

### Health Checks

```
/actuator/health
├─ Database connectivity
├─ Disk space
└─ Memory usage

Custom health indicators:
├─ ZaloPay API connectivity
└─ MySQL connection pool status
```

### Error Handling

```
Exception Handling Chain:
│
├─ Controller → @ExceptionHandler
├─ GlobalExceptionHandler
├─ Custom exceptions
│  ├─ PaymentException
│  ├─ OrderNotFoundException
│  └─ UnauthorizedException
│
└─ Return standardized error response:
   {
     "code": "ERR_001",
     "message": "User not found",
     "timestamp": "2025-12-23T15:20:00Z",
     "path": "/api/users/123"
   }
```

## Performance Optimization

### Caching Strategy

```
Query caching (planned):
- Cache event list (30 min TTL)
- Cache category/city data (1 hour TTL)
- Cache user permissions (10 min TTL)

Connection pooling:
- HikariCP: 5-20 connections
- Idle timeout: 10 minutes
- Max lifetime: 30 minutes
- Validation: SELECT 1 every 5 min
```

### Database Optimization

```
Indexes:
- payment_transactions(order_id, app_trans_id, created_at)
- orders(user_id, status, created_at)
- tickets(order_id, status)

Batch operations:
- Ticket creation: batch 20 records
- Order updates: batch 20 records

Query optimization:
- Lazy loading for associations
- Join fetch for critical relationships
- Pagination for large result sets
```

## Scalability Considerations

### Horizontal Scaling

```
Load Balancer
    │
    ├─→ App Instance 1 (port 8080)
    ├─→ App Instance 2 (port 8080)
    └─→ App Instance N (port 8080)
         │
         └─→ Shared MySQL Database (replication possible)
         └─→ ZaloPay API (external)
```

### Database Scaling

```
Current: Single MySQL instance
Future:
- Read replicas for analytics
- Sharding by user_id or region
- Archive old transactions
```

## Summary

The VES Booking API follows a clean layered architecture with clear separation of concerns. The payment processing
system integrates seamlessly with ZaloPay through:

- Secure request signing (HMAC-SHA256)
- Webhook callback processing
- Automated reconciliation
- Comprehensive audit logging
- Transaction-safe operations

This design enables reliable, scalable, and maintainable payment processing while preserving system performance and
security.
