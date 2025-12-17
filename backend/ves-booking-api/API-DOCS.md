# TKGDND API Documentation

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [API Endpoints](#api-endpoints)
4. [Data Models](#data-models)
5. [Error Handling](#error-handling)
6. [Rate Limiting](#rate-limiting)
7. [Webhooks](#webhooks)
8. [Examples](#examples)

---

## Overview

### Base URL

- Production: `https://ves-booking.io.vn/v1`
- Development: `http://localhost:3000/v1`

### API Design Principles

- RESTful architecture
- JSON request/response format
- JWT-based authentication
- Consistent error responses
- Pagination for list endpoints
- Filter and search capabilities

### Supported HTTP Methods

- `GET` - Retrieve resources
- `POST` - Create new resources
- `PUT` - Update existing resources
- `DELETE` - Remove resources

### Response Format

All API responses follow this structure:

```json
{
  "success": true,
  "data": {
    /* response data */
  },
  "error": null
}
```

For errors:

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": [
      /* optional additional details */
    ]
  }
}
```

---

## Authentication

### JWT Token-Based Authentication

The API uses JWT (JSON Web Tokens) for authentication. After successful login or registration, you'll receive an access token and refresh token.

#### Token Types

1. **Access Token**

   - Short-lived (1 hour)
   - Used for API requests
   - Include in `Authorization` header

2. **Refresh Token**
   - Long-lived (30 days)
   - Used to obtain new access tokens
   - Store securely

#### Using Access Tokens

Include the access token in the `Authorization` header:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Refreshing Tokens

When access token expires (401 error), use refresh token to get a new one:

**Request:**

```http
POST /v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "your-refresh-token"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "accessToken": "new-access-token",
    "expiresIn": 3600
  }
}
```

---

## API Endpoints

### Authentication Endpoints

#### 1. Register New User

**Endpoint:** `POST /auth/register`

**Description:** Create a new user account

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "fullName": "Nguyễn Văn A",
  "phoneNumber": "0912345678",
  "dateOfBirth": "1990-01-01"
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "usr_123456",
      "email": "user@example.com",
      "fullName": "Nguyễn Văn A",
      "phoneNumber": "0912345678",
      "dateOfBirth": "1990-01-01",
      "avatar": null,
      "createdAt": "2024-03-15T10:30:00Z"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600
  }
}
```

**Validation Rules:**

- Email: Valid email format, unique
- Password: Minimum 8 characters, must include uppercase, lowercase, and number
- Phone: 10 digits, Vietnamese format
- Full name: Required, 2-100 characters

---

#### 2. User Login

**Endpoint:** `POST /auth/login`

**Description:** Authenticate user and receive tokens

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "usr_123456",
      "email": "user@example.com",
      "fullName": "Nguyễn Văn A",
      "phoneNumber": "0912345678",
      "avatar": "https://example.com/avatars/user_123456.jpg"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600
  }
}
```

**Error Response (401 Unauthorized):**

```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Email or password is incorrect"
  }
}
```

---

#### 3. User Logout

**Endpoint:** `POST /auth/logout`

**Authentication Required:** Yes

**Description:** Invalidate user's access token

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

### Event Endpoints

#### 1. Get Events List

**Endpoint:** `GET /events`

**Description:** Retrieve paginated list of events with filtering

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| page | integer | No | Page number (default: 1) | `?page=2` |
| limit | integer | No | Items per page (default: 20, max: 100) | `?limit=50` |
| category | string | No | Filter by category | `?category=concert` |
| city | string | No | Filter by city | `?city=Ho+Chi+Minh` |
| startDate | date | No | Events from this date | `?startDate=2024-03-15` |
| endDate | date | No | Events until this date | `?endDate=2024-03-30` |
| trending | boolean | No | Only trending events | `?trending=true` |
| sortBy | string | No | Sort field (date, popularity, price_low, price_high, newest) | `?sortBy=popularity` |
| search | string | No | Search in name/description | `?search=Van+Gogh` |

**Example Request:**

```http
GET /v1/events?category=exhibition&city=Ho+Chi+Minh&page=1&limit=10&sortBy=date
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "events": [
      {
        "id": "evt_123456",
        "name": "Van Gogh: The Immersive Experience",
        "slug": "van-gogh-immersive-experience",
        "description": "Trải nghiệm triển lãm Van Gogh đầy ấn tượng",
        "category": "exhibition",
        "thumbnail": "https://example.com/events/vangogh.jpg",
        "startDate": "2024-03-15T18:00:00Z",
        "endDate": "2024-03-15T22:00:00Z",
        "city": "Ho Chi Minh",
        "venueName": "Nhà hát Thành phố",
        "minPrice": 150000,
        "maxPrice": 999000,
        "currency": "VND",
        "isTrending": true,
        "isFavorite": false,
        "availableTickets": 250
      }
      // ... more events
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 150,
      "totalPages": 15,
      "hasNextPage": true,
      "hasPrevPage": false
    }
  }
}
```

---

#### 2. Get Event Details

**Endpoint:** `GET /events/{eventId}`

**Description:** Get detailed information about a specific event

**Path Parameters:**

- `eventId` (string, required) - Event ID

**Example Request:**

```http
GET /v1/events/evt_123456
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": "evt_123456",
    "name": "Van Gogh: The Immersive Experience",
    "slug": "van-gogh-immersive-experience",
    "description": "Trải nghiệm triển lãm Van Gogh đầy ấn tượng",
    "longDescription": "Triển lãm Van Gogh là một trải nghiệm nghệ thuật tương tác độc đáo, mang đến cho khán giả cơ hội đắm mình trong thế giới của nghệ sĩ thiên tài Vincent van Gogh...",
    "category": "exhibition",
    "thumbnail": "https://example.com/events/vangogh.jpg",
    "images": [
      "https://example.com/events/vangogh_1.jpg",
      "https://example.com/events/vangogh_2.jpg",
      "https://example.com/events/vangogh_3.jpg"
    ],
    "startDate": "2024-03-15T18:00:00Z",
    "endDate": "2024-03-15T22:00:00Z",
    "city": "Ho Chi Minh",
    "venueId": "ven_789",
    "venueName": "Nhà hát Thành phố",
    "venueAddress": "123 Lê Lợi, Quận 1, TP.HCM",
    "venueCapacity": 500,
    "minPrice": 150000,
    "maxPrice": 999000,
    "currency": "VND",
    "isTrending": true,
    "isFavorite": false,
    "availableTickets": 250,
    "ticketTypes": [
      {
        "id": "tt_starry_001",
        "name": "STARRY NIGHT",
        "description": "Gói vé cao cấp nhất với trải nghiệm VIP",
        "price": 999000,
        "currency": "VND",
        "available": 20,
        "maxPerOrder": 5,
        "benefits": [
          "Ghế ngồi hạng sang tầng 1",
          "Tặng catalog đặc biệt",
          "Gặp gỡ curator",
          "Ưu tiên vào cửa sớm 30 phút"
        ],
        "requiresSeatSelection": true
      },
      {
        "id": "tt_vip_001",
        "name": "VIP TICKET",
        "description": "Ghế VIP tầng 1, tầm nhìn tốt nhất",
        "price": 450000,
        "currency": "VND",
        "available": 50,
        "maxPerOrder": 10,
        "benefits": [
          "Ghế ngồi tầng 1",
          "Tặng poster Van Gogh",
          "Ưu tiên vào cửa"
        ],
        "requiresSeatSelection": true
      },
      {
        "id": "tt_standard_001",
        "name": "STANDARD TICKET",
        "description": "Vé tiêu chuẩn",
        "price": 150000,
        "currency": "VND",
        "available": 180,
        "maxPerOrder": 10,
        "benefits": ["Vào cửa theo giờ đã chọn"],
        "requiresSeatSelection": false
      }
    ],
    "organizer": {
      "id": "org_456",
      "name": "Van Gogh Exhibition Vietnam",
      "logo": "https://example.com/orgs/vangogh_vn.png"
    },
    "terms": "- Vé đã mua không được hoàn trả\n- Vui lòng đến trước 30 phút để làm thủ tục\n- Không mang đồ ăn thức uống vào trong\n- Không chụp ảnh có flash",
    "cancellationPolicy": "Có thể hủy vé trước 48 giờ và được hoàn 80% giá vé. Hủy trong vòng 24-48 giờ được hoàn 50%. Không hoàn tiền nếu hủy trong vòng 24 giờ.",
    "tags": ["art", "exhibition", "van-gogh", "immersive", "family-friendly"]
  }
}
```

---

#### 3. Search Events

**Endpoint:** `GET /events/search`

**Description:** Search for events by keyword

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| q | string | Yes | Search query |
| page | integer | No | Page number |
| limit | integer | No | Items per page |

**Example Request:**

```http
GET /v1/events/search?q=concert&page=1&limit=20
```

**Response:** Same format as "Get Events List"

---

### Ticket Endpoints

#### 1. Get Available Tickets for Event

**Endpoint:** `GET /events/{eventId}/tickets`

**Description:** Get all available ticket types for a specific event

**Path Parameters:**

- `eventId` (string, required) - Event ID

**Example Request:**

```http
GET /v1/events/evt_123456/tickets
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "id": "tt_vip_001",
      "name": "VIP TICKET",
      "description": "Ghế VIP tầng 1, tầm nhìn tốt nhất",
      "price": 450000,
      "currency": "VND",
      "available": 50,
      "maxPerOrder": 10,
      "benefits": [
        "Ghế ngồi tầng 1",
        "Tặng poster Van Gogh",
        "Ưu tiên vào cửa"
      ],
      "requiresSeatSelection": true
    }
    // ... more ticket types
  ]
}
```

---

#### 2. Purchase Tickets

**Endpoint:** `POST /tickets/purchase`

**Authentication Required:** Yes

**Description:** Create a ticket purchase order

**Request Body:**

```json
{
  "eventId": "evt_123456",
  "ticketTypeId": "tt_vip_001",
  "quantity": 2,
  "seatIds": ["seat_A12", "seat_A13"],
  "voucherCode": "SUMMER2024",
  "paymentMethod": "e_wallet"
}
```

**Field Descriptions:**

- `eventId` (required) - Event ID
- `ticketTypeId` (required) - Selected ticket type ID
- `quantity` (required) - Number of tickets (1-10)
- `seatIds` (conditional) - Required if ticket type requires seat selection
- `voucherCode` (optional) - Discount voucher code
- `paymentMethod` (required) - Payment method: `credit_card`, `debit_card`, `e_wallet`, `bank_transfer`

**Response (201 Created):**

```json
{
  "success": true,
  "data": {
    "orderId": "ord_345678",
    "status": "pending",
    "eventId": "evt_123456",
    "eventName": "Van Gogh: The Immersive Experience",
    "ticketType": {
      "id": "tt_vip_001",
      "name": "VIP TICKET",
      "price": 450000
    },
    "quantity": 2,
    "subtotal": 900000,
    "discount": 100000,
    "total": 800000,
    "currency": "VND",
    "paymentUrl": "https://payment.tkgdnd.com/order/ord_345678",
    "expiresAt": "2024-03-15T11:00:00Z",
    "createdAt": "2024-03-15T10:45:00Z"
  }
}
```

**Payment Flow:**

1. Client calls `/tickets/purchase` endpoint
2. Server creates order and returns `paymentUrl`
3. Client redirects user to `paymentUrl`
4. User completes payment
5. Payment gateway redirects back to app
6. Server sends webhook notification when payment is confirmed
7. Tickets become available in user's account

**Error Responses:**

```json
// Tickets not available
{
  "success": false,
  "error": {
    "code": "TICKETS_UNAVAILABLE",
    "message": "The requested tickets are no longer available"
  }
}

// Seats already taken
{
  "success": false,
  "error": {
    "code": "SEATS_TAKEN",
    "message": "One or more selected seats are already taken",
    "details": [
      {"seatId": "seat_A13", "status": "taken"}
    ]
  }
}

// Invalid voucher
{
  "success": false,
  "error": {
    "code": "INVALID_VOUCHER",
    "message": "Voucher code is invalid or expired"
  }
}
```

---

#### 3. Get User's Tickets

**Endpoint:** `GET /tickets`

**Authentication Required:** Yes

**Description:** Get all tickets purchased by the authenticated user

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| status | string | Filter: `all`, `upcoming`, `completed`, `cancelled` |
| page | integer | Page number |
| limit | integer | Items per page |

**Example Request:**

```http
GET /v1/tickets?status=upcoming&page=1&limit=20
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "tickets": [
      {
        "id": "tkt_789012",
        "orderId": "ord_345678",
        "event": {
          "id": "evt_123456",
          "name": "Van Gogh: The Immersive Experience",
          "thumbnail": "https://example.com/events/vangogh.jpg",
          "startDate": "2024-03-15T18:00:00Z",
          "venueName": "Nhà hát Thành phố",
          "city": "Ho Chi Minh"
        },
        "ticketType": {
          "id": "tt_vip_001",
          "name": "VIP TICKET",
          "price": 450000
        },
        "qrCode": "TKT789012",
        "status": "active",
        "purchaseDate": "2024-03-10T14:30:00Z",
        "seatNumber": "A12"
      }
      // ... more tickets
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 15,
      "totalPages": 1,
      "hasNextPage": false,
      "hasPrevPage": false
    }
  }
}
```

---

#### 4. Get Ticket Details

**Endpoint:** `GET /tickets/{ticketId}`

**Authentication Required:** Yes

**Description:** Get detailed information about a specific ticket

**Example Request:**

```http
GET /v1/tickets/tkt_789012
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": "tkt_789012",
    "orderId": "ord_345678",
    "event": {
      "id": "evt_123456",
      "name": "Van Gogh: The Immersive Experience",
      "thumbnail": "https://example.com/events/vangogh.jpg",
      "startDate": "2024-03-15T18:00:00Z",
      "endDate": "2024-03-15T22:00:00Z",
      "venueName": "Nhà hát Thành phố",
      "venueAddress": "123 Lê Lợi, Quận 1, TP.HCM",
      "city": "Ho Chi Minh"
    },
    "ticketType": {
      "id": "tt_vip_001",
      "name": "VIP TICKET",
      "description": "Ghế VIP tầng 1, tầm nhìn tốt nhất",
      "price": 450000,
      "benefits": ["Ghế ngồi tầng 1", "Tặng poster Van Gogh", "Ưu tiên vào cửa"]
    },
    "qrCode": "TKT789012",
    "qrCodeImage": "https://example.com/qr/tkt_789012.png",
    "status": "active",
    "purchaseDate": "2024-03-10T14:30:00Z",
    "seatNumber": "A12",
    "checkedInAt": null,
    "cancellationReason": null,
    "refundAmount": null,
    "refundStatus": null
  }
}
```

---

#### 5. Cancel Ticket

**Endpoint:** `PUT /tickets/{ticketId}/cancel`

**Authentication Required:** Yes

**Description:** Cancel a purchased ticket (within cancellation policy)

**Request Body:**

```json
{
  "reason": "Unable to attend due to personal reasons"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "ticketId": "tkt_789012",
    "status": "cancelled",
    "refundAmount": 360000,
    "refundStatus": "processing",
    "message": "Your ticket has been cancelled. Refund will be processed within 5-7 business days."
  }
}
```

**Error Response (400 Bad Request):**

```json
{
  "success": false,
  "error": {
    "code": "CANCELLATION_NOT_ALLOWED",
    "message": "This ticket cannot be cancelled as it's within 24 hours of the event",
    "details": {
      "eventStartTime": "2024-03-15T18:00:00Z",
      "cancellationDeadline": "2024-03-14T18:00:00Z"
    }
  }
}
```

---

### Venue & Seating Endpoints

#### Get Venue Seating Map

**Endpoint:** `GET /venues/{venueId}/seats`

**Description:** Get venue seating layout and seat availability

**Query Parameters:**

- `eventId` (required) - Event ID to check seat availability

**Example Request:**

```http
GET /v1/venues/ven_789/seats?eventId=evt_123456
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "venueId": "ven_789",
    "venueName": "Nhà hát Thành phố",
    "eventId": "evt_123456",
    "sections": [
      {
        "id": "sec_vip",
        "name": "VIP Section",
        "rows": [
          {
            "row": "A",
            "seats": [
              {
                "id": "seat_A1",
                "number": "A1",
                "status": "available",
                "price": 450000,
                "ticketTypeId": "tt_vip_001"
              },
              {
                "id": "seat_A2",
                "number": "A2",
                "status": "sold",
                "price": 450000,
                "ticketTypeId": "tt_vip_001"
              },
              {
                "id": "seat_A3",
                "number": "A3",
                "status": "reserved",
                "price": 450000,
                "ticketTypeId": "tt_vip_001"
              }
              // ... more seats
            ]
          }
          // ... more rows
        ]
      }
      // ... more sections
    ]
  }
}
```

**Seat Status Values:**

- `available` - Can be purchased
- `reserved` - Temporarily held during someone's purchase flow
- `sold` - Already purchased
- `blocked` - Not available for sale

---

### Favorites Endpoints

#### 1. Get User's Favorites

**Endpoint:** `GET /favorites`

**Authentication Required:** Yes

**Example Response:**

```json
{
  "success": true,
  "data": {
    "events": [
      {
        "id": "evt_123456",
        "name": "Van Gogh: The Immersive Experience",
        "thumbnail": "https://example.com/events/vangogh.jpg",
        "startDate": "2024-03-15T18:00:00Z",
        "city": "Ho Chi Minh",
        "minPrice": 150000,
        "isFavorite": true
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 8,
      "totalPages": 1,
      "hasNextPage": false,
      "hasPrevPage": false
    }
  }
}
```

---

#### 2. Add to Favorites

**Endpoint:** `POST /favorites/{eventId}`

**Authentication Required:** Yes

**Response (201 Created):**

```json
{
  "success": true,
  "message": "Event added to favorites"
}
```

---

#### 3. Remove from Favorites

**Endpoint:** `DELETE /favorites/{eventId}`

**Authentication Required:** Yes

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Event removed from favorites"
}
```

---

### Voucher Endpoints

#### 1. Get Available Vouchers

**Endpoint:** `GET /vouchers`

**Description:** Get all public and available vouchers

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "vouchers": [
      {
        "id": "vch_111222",
        "code": "SUMMER2024",
        "title": "Giảm giá mùa hè",
        "description": "Giảm 100.000đ cho đơn hàng từ 500.000đ",
        "discountType": "fixed_amount",
        "discountValue": 100000,
        "minOrderAmount": 500000,
        "maxDiscount": null,
        "startDate": "2024-03-01T00:00:00Z",
        "endDate": "2024-06-30T23:59:59Z",
        "usageLimit": 1000,
        "usedCount": 567,
        "applicableEvents": [],
        "applicableCategories": ["exhibition", "concert"]
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 12,
      "totalPages": 1,
      "hasNextPage": false,
      "hasPrevPage": false
    }
  }
}
```

---

#### 2. Get User's Vouchers

**Endpoint:** `GET /vouchers/my-vouchers`

**Authentication Required:** Yes

**Query Parameters:**

- `status` - Filter: `all`, `active`, `used`, `expired` (default: `active`)

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "vouchers": [
      {
        "id": "vch_111222",
        "code": "SUMMER2024",
        "title": "Giảm giá mùa hè",
        "description": "Giảm 100.000đ cho đơn hàng từ 500.000đ",
        "discountType": "fixed_amount",
        "discountValue": 100000,
        "minOrderAmount": 500000,
        "startDate": "2024-03-01T00:00:00Z",
        "endDate": "2024-06-30T23:59:59Z",
        "userVoucherId": "uv_333444",
        "isUsed": false,
        "usedAt": null,
        "orderId": null
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 5,
      "totalPages": 1,
      "hasNextPage": false,
      "hasPrevPage": false
    }
  }
}
```

---

#### 3. Validate Voucher

**Endpoint:** `POST /vouchers/validate`

**Description:** Check if voucher is valid and calculate discount

**Request Body:**

```json
{
  "code": "SUMMER2024",
  "eventId": "evt_123456",
  "ticketTypeId": "tt_vip_001",
  "quantity": 2
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "valid": true,
    "voucher": {
      "id": "vch_111222",
      "code": "SUMMER2024",
      "title": "Giảm giá mùa hè",
      "discountType": "fixed_amount",
      "discountValue": 100000
    },
    "discountAmount": 100000,
    "originalPrice": 900000,
    "finalPrice": 800000
  }
}
```

**Error Response (400 Bad Request):**

```json
{
  "success": false,
  "error": {
    "code": "INVALID_VOUCHER",
    "message": "Voucher is not applicable for this event or order amount"
  }
}
```

---

### Notification Endpoints

#### 1. Get Notifications

**Endpoint:** `GET /notifications`

**Authentication Required:** Yes

**Query Parameters:**

- `page` - Page number
- `limit` - Items per page
- `unreadOnly` - Boolean, return only unread (default: false)

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "ntf_555666",
        "type": "event_reminder",
        "title": "Sự kiện sắp diễn ra",
        "message": "Sự kiện 'Van Gogh Exhibition' sẽ bắt đầu vào ngày mai lúc 18:00",
        "isRead": false,
        "data": {
          "eventId": "evt_123456",
          "ticketId": "tkt_789012",
          "eventStartTime": "2024-03-15T18:00:00Z"
        },
        "createdAt": "2024-03-14T10:00:00Z"
      },
      {
        "id": "ntf_555667",
        "type": "ticket_purchased",
        "title": "Mua vé thành công",
        "message": "Bạn đã mua 2 vé cho sự kiện 'Van Gogh Exhibition'",
        "isRead": true,
        "data": {
          "orderId": "ord_345678",
          "eventId": "evt_123456",
          "ticketCount": 2
        },
        "createdAt": "2024-03-10T14:30:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 25,
      "totalPages": 2,
      "hasNextPage": true,
      "hasPrevPage": false
    },
    "unreadCount": 5
  }
}
```

**Notification Types:**

- `ticket_purchased` - Ticket purchase confirmation
- `event_reminder` - Upcoming event reminder
- `event_cancelled` - Event cancellation
- `promotion` - Promotional offers
- `system` - System announcements

---

#### 2. Mark Notification as Read

**Endpoint:** `PUT /notifications/{notificationId}/read`

**Authentication Required:** Yes

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Notification marked as read"
}
```

---

#### 3. Mark All Notifications as Read

**Endpoint:** `PUT /notifications/read-all`

**Authentication Required:** Yes

**Response (200 OK):**

```json
{
  "success": true,
  "message": "All notifications marked as read"
}
```

---

### Category & City Endpoints

#### Get Categories

**Endpoint:** `GET /categories`

**Authentication:** Not required

**Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "id": "cat_sports",
      "name": "Thể thao",
      "slug": "sports",
      "icon": "https://example.com/icons/sports.svg",
      "eventCount": 45
    },
    {
      "id": "cat_concert",
      "name": "Hòa nhạc",
      "slug": "concert",
      "icon": "https://example.com/icons/concert.svg",
      "eventCount": 78
    },
    {
      "id": "cat_theater",
      "name": "Sân khấu kịch",
      "slug": "theater",
      "icon": "https://example.com/icons/theater.svg",
      "eventCount": 32
    },
    {
      "id": "cat_exhibition",
      "name": "Triển lãm",
      "slug": "exhibition",
      "icon": "https://example.com/icons/exhibition.svg",
      "eventCount": 56
    }
  ]
}
```

---

#### Get Cities

**Endpoint:** `GET /cities`

**Authentication:** Not required

**Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "id": "city_hcm",
      "name": "Ho Chi Minh",
      "slug": "ho-chi-minh",
      "eventCount": 120
    },
    {
      "id": "city_hanoi",
      "name": "Hanoi",
      "slug": "hanoi",
      "eventCount": 95
    },
    {
      "id": "city_danang",
      "name": "Da Nang",
      "slug": "da-nang",
      "eventCount": 42
    }
  ]
}
```

---

## Error Handling

### Error Response Format

All errors follow this structure:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": []
  }
}
```

### HTTP Status Codes

| Status Code | Description                                      |
| ----------- | ------------------------------------------------ |
| 200         | OK - Request successful                          |
| 201         | Created - Resource created successfully          |
| 400         | Bad Request - Invalid request parameters         |
| 401         | Unauthorized - Authentication required or failed |
| 403         | Forbidden - Access denied                        |
| 404         | Not Found - Resource not found                   |
| 409         | Conflict - Resource conflict (e.g., duplicate)   |
| 422         | Unprocessable Entity - Validation error          |
| 429         | Too Many Requests - Rate limit exceeded          |
| 500         | Internal Server Error - Server error             |
| 503         | Service Unavailable - Server maintenance         |

### Common Error Codes

| Error Code                 | Description                     |
| -------------------------- | ------------------------------- |
| `VALIDATION_ERROR`         | Request validation failed       |
| `INVALID_CREDENTIALS`      | Login credentials incorrect     |
| `UNAUTHORIZED`             | Authentication required         |
| `FORBIDDEN`                | Access denied                   |
| `NOT_FOUND`                | Resource not found              |
| `DUPLICATE_RESOURCE`       | Resource already exists         |
| `TICKETS_UNAVAILABLE`      | Tickets sold out or unavailable |
| `SEATS_TAKEN`              | Selected seats already taken    |
| `INVALID_VOUCHER`          | Voucher invalid or expired      |
| `CANCELLATION_NOT_ALLOWED` | Ticket cannot be cancelled      |
| `RATE_LIMIT_EXCEEDED`      | Too many requests               |
| `PAYMENT_FAILED`           | Payment processing failed       |
| `SERVER_ERROR`             | Internal server error           |

### Validation Error Example

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "message": "Email format is invalid"
      },
      {
        "field": "password",
        "message": "Password must be at least 8 characters"
      }
    ]
  }
}
```

---

## Rate Limiting

### Rate Limit Rules

- **Authenticated requests:** 1000 requests per hour per user
- **Unauthenticated requests:** 100 requests per hour per IP
- **Purchase endpoint:** 10 requests per minute per user

### Rate Limit Headers

Response headers include rate limit information:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1678901234
```

### Rate Limit Exceeded Response

```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please try again later.",
    "details": {
      "retryAfter": 3600,
      "limit": 1000,
      "resetAt": "2024-03-15T12:00:00Z"
    }
  }
}
```

---

## Webhooks

### Webhook Events

The API can send webhook notifications for the following events:

| Event               | Description                    |
| ------------------- | ------------------------------ |
| `payment.completed` | Payment successfully processed |
| `payment.failed`    | Payment failed                 |
| `ticket.issued`     | Ticket issued to user          |
| `ticket.cancelled`  | Ticket cancelled               |
| `event.cancelled`   | Event cancelled                |
| `refund.processed`  | Refund completed               |

### Webhook Payload Example

```json
{
  "event": "payment.completed",
  "timestamp": "2024-03-15T10:45:00Z",
  "data": {
    "orderId": "ord_345678",
    "userId": "usr_123456",
    "amount": 800000,
    "currency": "VND",
    "tickets": [
      {
        "ticketId": "tkt_789012",
        "eventId": "evt_123456",
        "seatNumber": "A12"
      }
    ]
  }
}
```

### Webhook Security

All webhook requests include an `X-Webhook-Signature` header for verification:

```javascript
const crypto = require("crypto");

function verifyWebhook(payload, signature, secret) {
  const hash = crypto
    .createHmac("sha256", secret)
    .update(JSON.stringify(payload))
    .digest("hex");

  return hash === signature;
}
```

---

## Examples

### Complete Purchase Flow

```javascript
// 1. Get event details
const eventResponse = await fetch(
  "https://ves-booking.io.vn/api/v1/events/evt_123456",
  {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  }
);
const event = await eventResponse.json();

// 2. Get available tickets
const ticketsResponse = await fetch(
  "https://ves-booking.io.vn/api/v1/events/evt_123456/tickets",
  {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  }
);
const ticketTypes = await ticketsResponse.json();

// 3. If seats required, get venue seating
const seatsResponse = await fetch(
  "https://ves-booking.io.vn/api/v1/venues/ven_789/seats?eventId=evt_123456",
  {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  }
);
const seatingMap = await seatsResponse.json();

// 4. Validate voucher (optional)
const voucherResponse = await fetch(
  "https://ves-booking.io.vn/api/v1/vouchers/validate",
  {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      code: "SUMMER2024",
      eventId: "evt_123456",
      ticketTypeId: "tt_vip_001",
      quantity: 2,
    }),
  }
);
const voucherInfo = await voucherResponse.json();

// 5. Purchase tickets
const purchaseResponse = await fetch(
  "https://ves-booking.io.vn/api/v1/tickets/purchase",
  {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      eventId: "evt_123456",
      ticketTypeId: "tt_vip_001",
      quantity: 2,
      seatIds: ["seat_A12", "seat_A13"],
      voucherCode: "SUMMER2024",
      paymentMethod: "e_wallet",
    }),
  }
);
const order = await purchaseResponse.json();

// 6. Redirect to payment
window.location.href = order.data.paymentUrl;

// 7. After payment, get ticket details
const ticketResponse = await fetch(
  "https://ves-booking.io.vn/api/v1/tickets/tkt_789012",
  {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  }
);
const ticket = await ticketResponse.json();
```

---

### Search and Filter Events

```javascript
// Search events by keyword
const searchResponse = await fetch(
  "https://ves-booking.io.vn/api/v1/events/search?q=concert&page=1&limit=20"
);
const searchResults = await searchResponse.json();

// Filter events by category and city
const filterResponse = await fetch(
  "https://ves-booking.io.vn/api/v1/events?category=exhibition&city=Ho+Chi+Minh&trending=true&sortBy=popularity"
);
const filteredEvents = await filterResponse.json();

// Get events within date range
const dateRangeResponse = await fetch(
  "https://ves-booking.io.vn/api/v1/events?startDate=2024-03-15&endDate=2024-03-31&sortBy=date"
);
const upcomingEvents = await dateRangeResponse.json();
```

---

### Manage Favorites

```javascript
// Get user's favorites
const favoritesResponse = await fetch(
  "https://ves-booking.io.vn/api/v1/favorites",
  {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  }
);
const favorites = await favoritesResponse.json();

// Add to favorites
const addResponse = await fetch(
  "https://ves-booking.io.vn/api/v1/favorites/evt_123456",
  {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  }
);

// Remove from favorites
const removeResponse = await fetch(
  "https://ves-booking.io.vn/api/v1/favorites/evt_123456",
  {
    method: "DELETE",
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  }
);
```

---

### Handle Notifications

```javascript
// Get unread notifications
const notificationsResponse = await fetch(
  "https://ves-booking.io.vn/api/v1/notifications?unreadOnly=true",
  {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  }
);
const notifications = await notificationsResponse.json();

// Mark single notification as read
await fetch("https://ves-booking.io.vn/api/v1/notifications/ntf_555666/read", {
  method: "PUT",
  headers: {
    Authorization: `Bearer ${accessToken}`,
  },
});

// Mark all as read
await fetch("https://ves-booking.io.vn/api/v1/notifications/read-all", {
  method: "PUT",
  headers: {
    Authorization: `Bearer ${accessToken}`,
  },
});
```

---

### Error Handling Pattern

```javascript
async function apiRequest(url, options = {}) {
  try {
    const response = await fetch(url, options);
    const data = await response.json();

    if (!data.success) {
      // Handle API error
      switch (data.error.code) {
        case "UNAUTHORIZED":
          // Refresh token or redirect to login
          await refreshAccessToken();
          return apiRequest(url, options); // Retry

        case "TICKETS_UNAVAILABLE":
          showError("Tickets are no longer available");
          break;

        case "RATE_LIMIT_EXCEEDED":
          const retryAfter = data.error.details.retryAfter;
          showError(`Too many requests. Retry after ${retryAfter} seconds`);
          break;

        default:
          showError(data.error.message);
      }

      return null;
    }

    return data.data;
  } catch (error) {
    // Handle network error
    console.error("Network error:", error);
    showError("Network connection failed. Please try again.");
    return null;
  }
}
```

---

**Last Updated:** March 2024
**API Version:** 1.0.0
