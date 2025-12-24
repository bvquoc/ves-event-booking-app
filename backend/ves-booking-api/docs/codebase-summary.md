# VES Booking API - Codebase Summary

**Last Updated:** December 23, 2025
**Version:** 1.0.0
**Status:** Active Development with Payment Integration

## Project Overview

VES Booking API is a comprehensive Spring Boot 3.2.2 application providing Identity & Access Management (IAM) and Event
Booking capabilities with integrated ZaloPay payment processing. The system handles user authentication (JWT),
role-based access control (RBAC), complete event booking lifecycle, and secure payment processing with automated
reconciliation.

**Key Statistics:**

- Total Files: 194
- Total Tokens: 123,849
- Total Characters: 535,263

## Architecture Overview

The system follows a layered architecture:

```
┌─────────────────────────────┐
│   REST API Controllers      │
└────────────┬────────────────┘
             ↓
┌─────────────────────────────┐
│   Service Layer             │
└────────────┬────────────────┘
             ↓
┌─────────────────────────────┐
│   Repository Layer (JPA)    │
└────────────┬────────────────┘
             ↓
┌─────────────────────────────┐
│   MySQL Database            │
└─────────────────────────────┘
```

## Core Components

### 1. Authentication & Authorization

- JWT-based authentication with access/refresh tokens
- Role-based access control (RBAC)
- Token blacklist for logout
- BCrypt password hashing (strength: 10)

### 2. Identity & Access Management

- User management (CRUD)
- Role and permission management
- Token introspection and validation

### 3. Event Booking System

- Event creation and management
- Ticket type management with inventory
- Order/booking lifecycle
- Ticket status tracking

### 4. Payment Processing (NEW)

- ZaloPay payment gateway integration
- HMAC-SHA256 signature verification
- Webhook/callback processing
- Automated payment reconciliation (5-min intervals)
- Refund processing and retry logic
- Comprehensive audit logging
- IP whitelisting for security

## Database Schema

### Core Entities

**Authentication:**

- User, Role, Permission, InvalidatedToken

**Event Booking:**

- Event, EventCategory, City, TicketType, Ticket, Order

**Payment Processing (NEW):**

- PaymentTransaction, PaymentAuditLog, Refund

### Key Relationships

```
User (1) ─── (M) Order
User (M) ─── (M) Role
Role (M) ─── (M) Permission
Event (1) ─── (M) Order
TicketType (1) ─── (M) Ticket
Order (1) ─── (M) PaymentTransaction
```

## Technology Stack

### Core

- **Language:** Java 21
- **Framework:** Spring Boot 3.2.2
- **Database:** MySQL 8.0
- **ORM:** JPA/Hibernate
- **Security:** Spring Security + OAuth2

### Additional

- **Build Tool:** Maven 3.9.5+
- **Mapping:** MapStruct 1.5.5
- **Validation:** Jakarta Validation
- **Logging:** SLF4J + Logback
- **HTTP Client:** RestTemplate
- **Documentation:** SpringDoc OpenAPI (Swagger)
- **DevOps:** Docker & Docker Compose

## Directory Structure

```
ves-booking-api/
├── src/main/java/com/uit/vesbookingapi/
│   ├── configuration/        # Spring configurations
│   ├── controller/           # REST endpoints
│   ├── service/              # Business logic
│   ├── scheduler/            # Scheduled tasks
│   ├── repository/           # Data access
│   ├── entity/               # JPA entities
│   ├── dto/                  # Data transfer objects
│   ├── enums/                # Enumeration types
│   ├── mapper/               # MapStruct mappers
│   ├── util/                 # Utility classes
│   ├── exception/            # Custom exceptions
│   └── VesBookingApiApplication.java
│
├── src/main/resources/
│   ├── application.yaml
│   └── application-prod.yaml
│
├── docs/                     # Documentation
├── pom.xml
└── docker-compose.yml
```

## Features Status

### Implemented

- User Management (CRUD)
- JWT Authentication & Authorization
- Role-Based Access Control (RBAC)
- Event Management & Booking
- Ticket Management with Inventory
- ZaloPay Payment Integration
- Payment Reconciliation Scheduler
- Refund Processing
- Audit Logging

### In Development

- Advanced event filtering
- Booking analytics
- Notification system
- Review and rating system

## Configuration

### Application (application.yaml)

- Server: Port 8080, Context path /api
- Database: MySQL 8.0
- JWT: Access (1h), Refresh (10h) tokens
- ZaloPay: Sandbox/Production endpoints

### Environment Variables

```bash
DBMS_CONNECTION=jdbc:mysql://localhost:3306/ves_booking_api
DBMS_USERNAME=root
DBMS_PASSWORD=root

ZALOPAY_APP_ID=your_app_id
ZALOPAY_KEY1=your_key1
ZALOPAY_KEY2=your_key2
ZALOPAY_ENDPOINT=https://sb-openapi.zalopay.vn/v2
ZALOPAY_CALLBACK_URL=https://your-domain.com/api/payments/zalopay/callback
```

## Security Features

### Authentication

- JWT tokens with secure signing
- BCrypt password hashing
- Token blacklist management
- Refresh token rotation

### Payment Security

- HMAC-SHA256 signature verification
- IP whitelisting for callbacks
- Idempotent transaction IDs
- Amount validation
- Comprehensive audit trail
- TLS/HTTPS enforcement

## API Endpoints

### Base: http://localhost:8080/api

**Authentication:**

- POST /auth/login
- POST /auth/introspect
- POST /auth/logout
- POST /auth/refresh

**Payment Processing:**

- POST /orders (create order with payment)
- POST /payments/zalopay/callback (payment webhook)
- POST /payments/zalopay/refund-callback (refund webhook)
- GET /orders/{id} (order with payment status)

## Testing

- Unit tests for services
- Integration tests for repositories
- Controller tests with MockMvc
- **Test Results:** 5/7 passing

```bash
./mvnw test
./mvnw test -Dtest=ZaloPayServiceTest
```

## Deployment

### Local Development

```bash
docker compose up -d mysql
./mvnw spring-boot:run
```

### Production

```bash
./mvnw clean package
docker build -t ves-booking-api:1.0.0 .
docker push your-registry/ves-booking-api:1.0.0
```

## Documentation

- [API Documentation](./api-docs.md)
- [System Architecture](./system-architecture.md)
- [Payment Integration Guide](./payment-integration-guide.md)
- [Deployment Guide](./deployment-guide.md)

## Change Log

### Version 1.0.0 (December 23, 2025)

- ZaloPay payment gateway integration
- Payment reconciliation scheduler (5-min interval)
- Refund processing with retry logic (30-min)
- Payment audit logging system
- IP whitelisting for callback security
- Comprehensive transaction tracking
