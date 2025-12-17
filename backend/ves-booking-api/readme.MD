# VES Booking API

VES Booking API is a comprehensive Spring Boot application that provides both **Identity & Access Management** and **Event Booking** functionality. It handles user authentication, authorization, role-based access control (RBAC), and complete event booking lifecycle management.

## Features

### Identity & Access Management

- ✅ User management (CRUD operations)
- ✅ JWT-based authentication
- ✅ Role-based access control (RBAC)
- ✅ Permission management
- ✅ Token introspection and refresh
- ✅ Secure password hashing (BCrypt)

### Event Booking (In Development)

- 🚧 Event creation and management
- 🚧 Event booking and reservations
- 🚧 Booking status management
- 🚧 Event capacity and availability tracking
- 🚧 Booking history and reporting

## Tech Stack

- **Build Tool:** Maven >= 3.9.5
- **Language:** Java 21
- **Framework:** Spring Boot 3.2.2
- **Database:** MySQL 8.0
- **Security:** Spring Security + OAuth2 Resource Server
- **Mapping:** MapStruct 1.5.5
- **Validation:** Jakarta Validation

## Quick Start (Local Development)

### Prerequisites

- Java 21 SDK
- Docker & Docker Compose (for MySQL)
- Maven 3.9.5+ (or use included `./mvnw`)

### Step 1: Start MySQL Database

```bash
# Start MySQL using Docker Compose
docker compose up -d mysql

# Verify MySQL is running
docker compose ps
```

### Step 2: Start Application

```bash
# Using Maven wrapper (recommended)
./mvnw spring-boot:run

# OR using Maven
mvn spring-boot:run
```

### Step 3: Verify Application

- **Application URL:** `http://localhost:8080/api`
- **API Base Path:** `/api`

### Default Credentials

**Database (MySQL):**

- Host: `localhost:3306`
- Database: `ves_booking_api`
- Username: `root`
- Password: `root`

**Application Admin User (auto-created on first startup):**

- Username: `admin`
- Password: `admin`
- Role: `ADMIN`

⚠️ **Important:** Change the default admin password after first login!

### Quick Test

```bash
# Login as admin
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'
```

## Architecture

### Project Structure

```
ves-booking-api/
├── src/main/java/com/uit/vesbookingapi/
│   ├── configuration/     # Security, JWT, Application init
│   ├── controller/         # REST endpoints
│   │   ├── AuthenticationController.java ✅
│   │   ├── UserController.java ✅
│   │   ├── RoleController.java ✅
│   │   ├── PermissionController.java ✅
│   │   ├── EventController.java 🚧 (to be implemented)
│   │   └── BookingController.java 🚧 (to be implemented)
│   ├── service/            # Business logic
│   │   ├── AuthenticationService.java ✅
│   │   ├── UserService.java ✅
│   │   ├── RoleService.java ✅
│   │   ├── PermissionService.java ✅
│   │   ├── EventService.java 🚧 (to be implemented)
│   │   └── BookingService.java 🚧 (to be implemented)
│   ├── repository/         # Data access layer
│   │   ├── UserRepository.java ✅
│   │   ├── RoleRepository.java ✅
│   │   ├── PermissionRepository.java ✅
│   │   ├── EventRepository.java 🚧 (to be implemented)
│   │   └── BookingRepository.java 🚧 (to be implemented)
│   ├── entity/             # JPA entities
│   │   ├── User.java ✅
│   │   ├── Role.java ✅
│   │   ├── Permission.java ✅
│   │   ├── InvalidatedToken.java ✅
│   │   ├── Event.java 🚧 (to be implemented)
│   │   └── Booking.java 🚧 (to be implemented)
│   ├── dto/                # Data transfer objects
│   │   ├── request/        # Request DTOs
│   │   └── response/      # Response DTOs
│   ├── mapper/             # MapStruct mappers
│   ├── exception/          # Exception handling
│   ├── validator/         # Custom validators
│   └── constant/          # Constants
├── src/main/resources/
│   ├── application.yaml    # Main configuration
│   └── application-prod.yaml
└── src/test/               # Test files
```

**Legend:**

- ✅ Implemented
- 🚧 In Development / To be implemented

### Database Schema

**Identity & Access Management Entities:**

- `User` - User accounts with roles
- `Role` - User roles (ADMIN, USER, etc.)
- `Permission` - Fine-grained permissions
- `InvalidatedToken` - Token blacklist for logout

**Event Booking Entities (To be implemented):**

- `Event` - Event information and details
- `Booking` - User event bookings/reservations
- `EventCategory` - Event categorization
- `Venue` - Event venue information (if applicable)

**Relationships:**

- User ↔ Role: Many-to-Many
- Role ↔ Permission: Many-to-Many
- User ↔ Booking: One-to-Many (planned)
- Event ↔ Booking: One-to-Many (planned)

### Security Architecture

- **Authentication:** JWT tokens
- **Authorization:** Role-based (RBAC)
- **Password:** BCrypt hashing (strength: 10)
- **Token Management:** Access tokens (1 hour) + Refresh tokens (10 hours)

## API Endpoints

Base URL: `http://localhost:8080/api`

### Authentication (`/api/auth`)

- `POST /auth/login` - Authenticate user
- `POST /auth/introspect` - Validate token
- `POST /auth/logout` - Invalidate token
- `POST /auth/refresh` - Refresh access token

### User Management (`/api/users`)

- `POST /users` - Create user
- `GET /users/{id}` - Get user by ID
- `GET /users/my-info` - Get current user info
- `PUT /users/{id}` - Update user
- `DELETE /users/{id}` - Delete user
- `GET /users` - List all users

### Role Management (`/api/roles`)

- `POST /roles` - Create role
- `GET /roles` - List all roles
- `DELETE /roles/{role}` - Delete role

### Permission Management (`/api/permissions`)

- `POST /permissions` - Create permission
- `GET /permissions` - List all permissions

### Event Booking (`/api/events`) - In Development

- 🚧 `POST /events` - Create event
- 🚧 `GET /events` - List all events
- 🚧 `GET /events/{id}` - Get event details
- 🚧 `PUT /events/{id}` - Update event
- 🚧 `DELETE /events/{id}` - Delete event
- 🚧 `GET /events/{id}/availability` - Check event availability

### Booking Management (`/api/bookings`) - In Development

- 🚧 `POST /bookings` - Create booking
- 🚧 `GET /bookings` - List user bookings
- 🚧 `GET /bookings/{id}` - Get booking details
- 🚧 `PUT /bookings/{id}/cancel` - Cancel booking
- 🚧 `GET /bookings/my-bookings` - Get current user's bookings

## Configuration

### Application Configuration

**Server:**

- Port: `8080`
- Context Path: `/api`

**Database:**

- URL: `jdbc:mysql://localhost:3306/ves_booking_api`
- Username: `root` (default)
- Password: `root` (default)
- DDL Mode: `update` (auto-create/update tables)

**JWT:**

- Access Token Validity: 3600 seconds (1 hour)
- Refresh Token Validity: 36000 seconds (10 hours)

### Environment Variables

Override database settings:

```bash
export DBMS_CONNECTION=jdbc:mysql://localhost:3306/ves_booking_api
export DBMS_USERNAME=root
export DBMS_PASSWORD=root
```

## Build Application

```bash
# Clean and compile
./mvnw clean compile

# Run tests
./mvnw test

# Package application
./mvnw clean package

# Run JAR
java -jar target/ves-booking-api-0.0.1.jar
```

## Docker Deployment

### Build Docker Image

```bash
docker build -t ves-booking-api:0.9.0 .
```

### Run with Docker Compose

```bash
# Start MySQL and application
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down
```

### Manual Docker Deployment

```bash
# Create network
docker network create ves-booking-network

# Start MySQL
docker run --network ves-booking-network --name mysql \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=ves_booking_api \
  -d mysql:8.0

# Run application
docker run --name ves-booking-api \
  --network ves-booking-network \
  -p 8080:8080 \
  -e DBMS_CONNECTION=jdbc:mysql://mysql:3306/ves_booking_api \
  -e DBMS_USERNAME=root \
  -e DBMS_PASSWORD=root \
  ves-booking-api:0.9.0
```

### Push to Docker Hub

```bash
docker tag ves-booking-api:0.9.0 <account>/ves-booking-api:0.9.0
docker push <account>/ves-booking-api:0.9.0
```

## Development Resources

- **Local Setup Guide:** See [LOCAL_SETUP.md](./LOCAL_SETUP.md) for detailed local development instructions
- **Postman Collection:** Import `Identity Service.postman_collection.json` for API testing
- **API Documentation:** Check `API-DOCS.md` in parent directory
- **Source Code:** Explore `src/main/java/com/uit/vesbookingapi/` for implementation details
