# Local Development Setup Guide

## Project Overview

**VES Booking API** is a Spring Boot 3.2.2 application that provides:

### Identity & Access Management (✅ Completed)

- User onboarding and management
- Role-based access control (RBAC)
- JWT-based authentication
- Permission management

### Event Booking (🚧 In Development)

- Event creation and management
- Event booking and reservations
- Booking status management
- Event availability tracking

**Tech Stack:**

- Java 21
- Spring Boot 3.2.2
- MySQL 8.0
- Maven 3.9.5+
- JWT for authentication

## Prerequisites

Before starting, ensure you have:

1. **Java 21** installed

   ```bash
   java -version  # Should show version 21.x
   ```

2. **Maven 3.9.5+** (or use the included Maven wrapper `./mvnw`)

   ```bash
   ./mvnw --version
   ```

3. **Docker & Docker Compose** (for MySQL infrastructure)

   ```bash
   docker --version
   docker compose version
   ```

4. **MySQL 8.0** (if not using Docker)

## Quick Start (Recommended: Using Docker Compose)

### Step 1: Start MySQL Database

```bash
# From the ves-booking-api directory
docker compose up -d mysql
```

This will:

- Start MySQL 8.0 container
- Create database `ves_booking_api`
- Expose MySQL on port `3306`
- Create a Docker network `ves-booking-network`

**Verify MySQL is running:**

```bash
docker compose ps
# Should show mysql container as "Up (healthy)"
```

### Step 2: Start the Application

```bash
# Using Maven wrapper
./mvnw spring-boot:run

# OR using Maven (if installed)
mvn spring-boot:run
```

The application will:

- Start on port `8080`
- Context path: `/api`
- Auto-create database tables (via `ddl-auto: update`)
- Initialize default admin user (username: `admin`, password: `admin`)

### Step 3: Verify Application is Running

```bash
# Check health (if actuator is enabled)
curl http://localhost:8080/api/actuator/health

# Or check logs
tail -f logs/ves-booking-api-local.log
```

**Application URL:** `http://localhost:8080/api`

## Alternative: Manual MySQL Setup

If you prefer to use a local MySQL installation instead of Docker:

### Step 1: Install and Start MySQL

**macOS (using Homebrew):**

```bash
brew install mysql
brew services start mysql
```

**Linux:**

```bash
sudo apt-get install mysql-server
sudo systemctl start mysql
```

### Step 2: Create Database

```bash
mysql -u root -p
```

Then run:

```sql
CREATE DATABASE ves_booking_api;
CREATE USER 'vesbooking'@'localhost' IDENTIFIED BY 'vesbooking';
GRANT ALL PRIVILEGES ON ves_booking_api.* TO 'vesbooking'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Step 3: Update Configuration (if needed)

Edit `src/main/resources/application.yaml` if your MySQL credentials differ:

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/ves_booking_api
    username: vesbooking # or root
    password: vesbooking # or your password
```

### Step 4: Start Application

```bash
./mvnw spring-boot:run
```

## Configuration Details

### Application Configuration (`application.yaml`)

**Server Configuration:**

- **Port:** `8080`
- **Context Path:** `/api`
- **Base URL:** `http://localhost:8080/api`

**Database Configuration:**

- **Type:** MySQL 8.0
- **Host:** `localhost`
- **Port:** `3306`
- **Database Name:** `ves_booking_api`
- **Username:** `root` (default, can be overridden)
- **Password:** `root` (default, can be overridden)
- **Connection URL:** `jdbc:mysql://localhost:3306/ves_booking_api`
- **DDL Mode:** `update` (auto-create/update tables)
- **SQL Logging:** Enabled (`show-sql: true`)

**JWT Configuration:**

- **Access Token Validity:** 3600 seconds (1 hour)
- **Refresh Token Validity:** 36000 seconds (10 hours)
- **Signer Key:** Pre-configured (change in production!)

**Application Initialization:**

- Auto-creates default roles (ADMIN, USER) on first startup
- Auto-creates default admin user if not exists
- Only runs when using MySQL (not H2 for tests)

### Environment Variables

You can override database settings using environment variables:

```bash
export DBMS_CONNECTION=jdbc:mysql://localhost:3306/ves_booking_api
export DBMS_USERNAME=root
export DBMS_PASSWORD=root

./mvnw spring-boot:run
```

## Default Accounts & Credentials

### Database Credentials (MySQL)

**Local Development (Docker):**

- **Host:** `localhost`
- **Port:** `3306`
- **Database:** `ves_booking_api`
- **Root Username:** `root`
- **Root Password:** `root`
- **Connection String:** `jdbc:mysql://localhost:3306/ves_booking_api`

**Connect via MySQL Client:**

```bash
mysql -h localhost -P 3306 -u root -proot ves_booking_api
```

**Connect via Docker:**

```bash
docker compose exec mysql mysql -u root -proot ves_booking_api
```

### Application Default Admin User

**Auto-created on first startup:**

- **Username:** `admin`
- **Password:** `admin`
- **Role:** `ADMIN`
- **Permissions:** Full system access

⚠️ **Security Warning:**

- The default admin user is automatically created if it doesn't exist
- **Change the password immediately** after first login
- This user has full administrative privileges

**Login Example:**

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'
```

### Default Roles

The application initializes with these roles:

1. **ADMIN**

   - Description: "Admin role"
   - Full system access
   - Assigned to default admin user

2. **USER**
   - Description: "User role"
   - Standard user access
   - Default role for new users

## API Endpoints

Base URL: `http://localhost:8080/api`

### Authentication Endpoints

- `POST /api/auth/login` - Login
- `POST /api/auth/introspect` - Validate token
- `POST /api/auth/logout` - Logout
- `POST /api/auth/refresh` - Refresh token

### User Management

- `POST /api/users` - Create user
- `GET /api/users/{id}` - Get user by ID
- `GET /api/users/my-info` - Get current user info
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user
- `GET /api/users` - List all users

### Role & Permission Management

- `POST /api/roles` - Create role
- `GET /api/roles` - List all roles
- `DELETE /api/roles/{role}` - Delete role
- `POST /api/permissions` - Create permission
- `GET /api/permissions` - List all permissions

### Event Booking (🚧 In Development)

**Event Management:**

- `POST /api/events` - Create event
- `GET /api/events` - List all events
- `GET /api/events/{id}` - Get event details
- `PUT /api/events/{id}` - Update event
- `DELETE /api/events/{id}` - Delete event
- `GET /api/events/{id}/availability` - Check event availability

**Booking Management:**

- `POST /api/bookings` - Create booking
- `GET /api/bookings` - List bookings (admin)
- `GET /api/bookings/{id}` - Get booking details
- `GET /api/bookings/my-bookings` - Get current user's bookings
- `PUT /api/bookings/{id}/cancel` - Cancel booking
- `PUT /api/bookings/{id}/confirm` - Confirm booking (admin)

## Testing the API

### 1. Login as Admin

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin"
  }'
```

Response will include `accessToken` and `refreshToken`.

### 2. Use Token for Authenticated Requests

```bash
# Replace YOUR_TOKEN with the accessToken from login response
curl -X GET http://localhost:8080/api/users \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Troubleshooting

### MySQL Connection Issues

**Problem:** `Communications link failure`

**Solutions:**

1. Verify MySQL is running:

   ```bash
   docker compose ps  # For Docker
   # OR
   mysql -u root -p  # For local MySQL
   ```

2. Check MySQL port:

   ```bash
   lsof -i :3306
   ```

3. Verify database exists:
   ```bash
   mysql -u root -p -e "SHOW DATABASES;"
   ```

### Port Already in Use

**Problem:** `Port 8080 is already in use`

**Solution:**

```bash
# Find process using port 8080
lsof -i :8080

# Kill the process or change port in application.yaml
server:
  port: 8081  # Change to different port
```

### Java Version Issues

**Problem:** `Unsupported class file major version`

**Solution:**

- Ensure Java 21 is installed and active:

  ```bash
  java -version
  # Should show: openjdk version "21.x.x"

  # Set JAVA_HOME if needed
  export JAVA_HOME=$(/usr/libexec/java_home -v 21)
  ```

## Building the Application

```bash
# Build JAR file
./mvnw clean package

# JAR will be created at: target/ves-booking-api-0.0.1.jar

# Run JAR directly
java -jar target/ves-booking-api-0.0.1.jar
```

## Stopping Services

### Stop Application

Press `Ctrl+C` in the terminal running the application

### Stop MySQL (Docker)

```bash
docker compose down

# To also remove volumes (⚠️ deletes data):
docker compose down -v
```

## Development Tips

1. **Hot Reload:** Use Spring Boot DevTools (if added) or IDE auto-reload
2. **Database Changes:** Tables are auto-created/updated via `ddl-auto: update`
3. **Logs:** Check `logs/ves-booking-api-local.log` for application logs
4. **SQL Logging:** SQL queries are logged (see `show-sql: true` in config)

## Architecture Overview

### Current Implementation

**Identity & Access Management Layer:**

```
Controller Layer (REST APIs)
    ↓
Service Layer (Business Logic)
    ↓
Repository Layer (Data Access)
    ↓
Entity Layer (JPA Entities)
```

**Key Components:**

- `AuthenticationController` - Handles login, logout, token refresh
- `UserController` - User CRUD operations
- `RoleController` - Role management
- `PermissionController` - Permission management
- `SecurityConfig` - Spring Security configuration
- `CustomJwtDecoder` - JWT token validation

### Planned Event Booking Implementation

**Event Booking Layer (To be implemented):**

```
EventController → EventService → EventRepository → Event Entity
BookingController → BookingService → BookingRepository → Booking Entity
```

**Planned Components:**

- `EventController` - Event CRUD operations
- `BookingController` - Booking management
- `EventService` - Event business logic
- `BookingService` - Booking business logic
- Event and Booking entities with relationships

## Development Workflow

### Adding New Event Booking Features

1. **Create Entity:**

   - Add `Event.java` and `Booking.java` in `entity/` package
   - Define relationships with `User` entity

2. **Create Repository:**

   - Add `EventRepository.java` and `BookingRepository.java`
   - Extend `JpaRepository`

3. **Create DTOs:**

   - Add request/response DTOs in `dto/request/` and `dto/response/`
   - Use validation annotations

4. **Create Mapper:**

   - Add MapStruct mappers for Entity ↔ DTO conversion

5. **Create Service:**

   - Implement business logic in `EventService` and `BookingService`
   - Handle validation and business rules

6. **Create Controller:**

   - Add REST endpoints in `EventController` and `BookingController`
   - Apply security annotations (`@PreAuthorize`)

7. **Write Tests:**
   - Add unit tests for services
   - Add integration tests for controllers

## Next Steps

- Import Postman collection: `Identity Service.postman_collection.json`
- Review API documentation: Check `API-DOCS.md` in parent directory
- Explore source code in `src/main/java/com/uit/vesbookingapi/`
- Start implementing Event Booking features following the architecture pattern
