# 📚 API Integration Guide

Hướng dẫn tích hợp API với dữ liệu mặc định được seed tự động khi khởi động ứng dụng.

## 🚀 Quick Start

### Base URL

```
http://localhost:8080/api
```

### Authentication

API sử dụng JWT Bearer token. Lấy token bằng cách login:

```bash
POST /api/auth/login
{
  "username": "user1",
  "password": "123456"
}
```

Response:

```json
{
  "result": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

Sử dụng token trong header:

```
Authorization: Bearer {accessToken}
```

---

## 👥 Default Users

Sau khi khởi động ứng dụng, các user sau được tạo tự động:

| Username      | Password | Role  | Mô tả                                |
| ------------- | -------- | ----- | ------------------------------------ |
| `admin`       | `admin`  | ADMIN | Quản trị viên - có quyền CRUD tất cả |
| `user1`       | `123456` | USER  | Người dùng thường                    |
| `newuser`     | `123456` | USER  | User mới - chưa có đơn hàng          |
| `regularuser` | `123456` | USER  | User thường - có vài đơn hàng        |
| `vipuser`     | `123456` | USER  | User VIP - có nhiều đơn hàng         |

**⚠️ Lưu ý:** Đổi mật khẩu trong production!

---

## 📂 Default Categories

4 danh mục sự kiện:

| Name          | Slug            | Icon             |
| ------------- | --------------- | ---------------- |
| Thể thao      | `the-thao`      | `sports_soccer`  |
| Hòa nhạc      | `hoa-nhac`      | `music_note`     |
| Sân khấu kịch | `san-khau-kich` | `theater_comedy` |
| Triển lãm     | `trien-lam`     | `palette`        |

**API:** `GET /api/categories`

---

## 🏙️ Default Cities

3 thành phố:

| Name        | Slug          |
| ----------- | ------------- |
| Ho Chi Minh | `ho-chi-minh` |
| Hanoi       | `hanoi`       |
| Da Nang     | `da-nang`     |

**API:** `GET /api/cities`

---

## 🏟️ Default Venues

3 địa điểm:

| Name                          | City        | Capacity |
| ----------------------------- | ----------- | -------- |
| Nhà hát Thành phố Hồ Chí Minh | Ho Chi Minh | 2000     |
| Sân vận động Quốc gia Mỹ Đình | Hanoi       | 40000    |
| Trung tâm Hội nghị Quốc gia   | Hanoi       | 3500     |

**API:**

- `GET /api/venues` - List all
- `GET /api/venues/{venueId}` - Get by ID
- `GET /api/venues/{venueId}/seats?eventId={eventId}` - Get seat map

---

## 🎫 Default Events

### Basic Events (3 events)

1. **Trận đấu bóng đá: Việt Nam vs Thái Lan**

   - Slug: `tran-dau-bong-da-viet-nam-vs-thai-lan`
   - Category: Thể thao
   - City: Hanoi
   - Date: +30 days from now
   - Ticket Types: VIP (500,000đ), Thường (200,000đ)
   - Status: Upcoming, Trending

2. **Đêm nhạc Sơn Tùng M-TP**

   - Slug: `dem-nhac-son-tung-mtp`
   - Category: Hòa nhạc
   - City: Ho Chi Minh
   - Date: +45 days from now
   - Ticket Types: VIP (3,000,000đ), Thường (800,000đ)
   - Status: Upcoming, Trending

3. **Vở kịch: Chuyện tình Romeo và Juliet**
   - Slug: `vo-kich-chuyen-tinh-romeo-va-juliet`
   - Category: Sân khấu kịch
   - City: Hanoi
   - Date: +20 days from now
   - Ticket Types: VIP (600,000đ), Thường (300,000đ)
   - Status: Upcoming

### Sample Events (8 events - nếu database trống)

#### Past Events (đã kết thúc):

- `[PAST] Liveshow Blackpink World Tour` - 2 tuần trước
- `[PAST] AFF Cup 2024 Final` - 1 tuần trước

#### Ongoing Events (đang diễn ra):

- `[ONGOING] Festival Kịch Nói 2024` - đang diễn ra

#### Soon Events (sắp diễn ra):

- `[SOON] Triển Lãm Nghệ Thuật Đương Đại` - 3 ngày nữa
- `[SOON] Monsoon Music Festival` - 5 ngày nữa

#### Sold Out:

- `[SOLD OUT] Taylor Swift Eras Tour Vietnam` - 60 ngày nữa, hết vé

#### Future Events:

- `[FUTURE] SEA Games 2025 Opening` - 28 ngày nữa

**API:**

- `GET /api/events` - List events (có pagination, filter, sort)
- `GET /api/events/{eventId}` - Get event details
- `GET /api/events/{eventId}/tickets` - Get ticket types

**Query Parameters cho GET /api/events:**

- `page` - Số trang (default: 0)
- `size` - Số items/trang (default: 20)
- `category` - Lọc theo category slug
- `city` - Lọc theo city slug
- `trending` - Lọc trending (true/false)
- `search` - Tìm kiếm theo tên
- `startDate` - Từ ngày (ISO format)
- `endDate` - Đến ngày (ISO format)
- `sort` - Sắp xếp (startDate,asc | startDate,desc)

---

## 🎟️ Default Ticket Types

Mỗi event có 2-3 loại vé:

| Event          | Ticket Type | Price      | Available | Requires Seat |
| -------------- | ----------- | ---------- | --------- | ------------- |
| Football Match | VIP         | 500,000đ   | 100       | ✅ Yes        |
| Football Match | Thường      | 200,000đ   | 500       | ✅ Yes        |
| Concert        | VIP         | 3,000,000đ | 50        | ✅ Yes        |
| Concert        | Thường      | 800,000đ   | 300       | ✅ Yes        |
| Theater        | VIP         | 600,000đ   | 80        | ✅ Yes        |
| Theater        | Thường      | 300,000đ   | 200       | ✅ Yes        |

**API:** `GET /api/events/{eventId}/tickets`

---

## 🎫 Default Vouchers

6 vouchers mẫu:

| Code          | Title                         | Discount | Min Order | Status                        |
| ------------- | ----------------------------- | -------- | --------- | ----------------------------- |
| `GIAM20`      | Giảm 20% toàn bộ              | 20%      | 200,000đ  | ✅ Active                     |
| `GIAM100K`    | Giảm 100.000đ                 | 100,000đ | 500,000đ  | ✅ Active                     |
| `MONSOON50`   | Monsoon Festival - Giảm 50%   | 50%      | 0đ        | ✅ Active (event-specific)    |
| `MUSIC30`     | Âm nhạc - Giảm 30%            | 30%      | 300,000đ  | ✅ Active (category-specific) |
| `EXPIRED2024` | Voucher hết hạn               | 15%      | 100,000đ  | ❌ Expired                    |
| `LIMITED10`   | Voucher giới hạn - Còn 2 lượt | 200,000đ | 400,000đ  | ⚠️ Limited (8/10 used)        |

**API:** `GET /api/vouchers` (cần authentication)

---

## 📦 Sample Orders & Tickets

### Regular User Orders:

- 2 vé VIP cho Blackpink concert (đã dùng)
- 2 vé cho Triển lãm (đang active, dùng voucher GIAM20)

### VIP User Orders:

- 4 vé cho AFF Cup (đã dùng, dùng voucher GIAM100K)
- 4 vé VIP cho SEA Games (đang active)
- 2 vé VIP cho Monsoon Festival (đang active)

### Pending Orders:

- 2 vé Standard cho SEA Games (pending payment)
- 1 vé cho Triển lãm (expired payment)

**API:**

- `GET /api/orders` - List user orders (cần authentication)
- `GET /api/orders/{orderId}` - Get order details
- `GET /api/tickets` - List user tickets (cần authentication)

---

## ⭐ Sample Favorites

Các user đã favorite một số events:

- `newuser`: Triển lãm, Monsoon Festival, Taylor Swift
- `regularuser`: SEA Games, Monsoon Festival
- `vipuser`: Taylor Swift, SEA Games
- `user1`: Triển lãm, Taylor Swift

**API:**

- `GET /api/favorites` - List favorites (cần authentication)
- `POST /api/favorites` - Add favorite
- `DELETE /api/favorites/{eventId}` - Remove favorite

---

## 🔔 Sample Notifications

5 notifications mẫu cho các users:

- Ticket purchased notifications
- Event reminders
- Promotions
- Welcome messages

**API:**

- `GET /api/notifications` - List notifications (cần authentication)
- `PUT /api/notifications/{id}/read` - Mark as read

---

## 🧪 Testing Scenarios

### Scenario 1: Browse Events (Public)

```bash
# Get all events
GET /api/events

# Get trending events
GET /api/events?trending=true

# Search events
GET /api/events?search=nhạc

# Filter by category
GET /api/events?category=hoa-nhac

# Filter by city
GET /api/events?city=ho-chi-minh
```

### Scenario 2: View Event Details (Public)

```bash
# Get event details
GET /api/events/{eventId}

# Get ticket types
GET /api/events/{eventId}/tickets

# Get venue seating map
GET /api/venues/{venueId}/seats?eventId={eventId}
```

### Scenario 3: User Login & Profile

```bash
# Login
POST /api/auth/login
{
  "username": "user1",
  "password": "123456"
}

# Get user profile (use token from login)
GET /api/users/me
Authorization: Bearer {token}
```

### Scenario 4: Create Order (Authenticated)

```bash
# Create order
POST /api/orders
Authorization: Bearer {token}
{
  "eventId": "{eventId}",
  "ticketTypeId": "{ticketTypeId}",
  "quantity": 2,
  "voucherCode": "GIAM20"  // optional
}
```

### Scenario 5: Admin Create Event (Admin Only)

```bash
# Create event
POST /api/events
Authorization: Bearer {adminToken}
{
  "name": "Sự kiện mới",
  "slug": "su-kien-moi",
  "description": "Mô tả sự kiện",
  "categoryId": "{categoryId}",
  "cityId": "{cityId}",
  "venueId": "{venueId}",
  "startDate": "2025-01-15T19:00:00",
  "endDate": "2025-01-15T22:00:00",
  "ticketTypes": [
    {
      "name": "VIP",
      "price": 1000000,
      "available": 100,
      "requiresSeatSelection": true
    }
  ]
}
```

---

## 📊 Response Format

Tất cả API responses đều có format:

```json
{
  "result": { ... },  // Data
  "code": 1000,       // Success code
  "message": "Success"
}
```

Error response:

```json
{
  "code": 1001, // Error code
  "message": "Error message"
}
```

---

## 🔑 Error Codes

### Get All Error Codes

Frontend có thể lấy tất cả error codes và messages từ API:

```bash
GET /api/error-codes
```

**Response:**

```json
{
  "result": [
    {
      "name": "EVENT_NOT_FOUND",
      "code": 2001,
      "message": "Event not found",
      "httpStatus": 404,
      "category": "Event errors"
    },
    {
      "name": "TICKETS_UNAVAILABLE",
      "code": 3002,
      "message": "Requested tickets are not available",
      "httpStatus": 400,
      "category": "Ticket errors"
    },
    ...
  ]
}
```

**Categories:**

- `System errors` (9999)
- `User errors` (1000-1999)
- `Event errors` (2000-2999)
- `Ticket errors` (3000-3999)
- `Seat errors` (4000-4999)
- `Order errors` (5000-5999)
- `Voucher errors` (6000-6999)
- `Venue errors` (7000-7999)
- `Category/City errors` (8000-8999)
- `Notification errors` (9000-9999)

### Common Error Codes

| Code | Message          | Mô tả                |
| ---- | ---------------- | -------------------- |
| 1000 | Success          | Thành công           |
| 1001 | General Error    | Lỗi chung            |
| 1002 | Unauthorized     | Chưa đăng nhập       |
| 1003 | Forbidden        | Không có quyền       |
| 1004 | Not Found        | Không tìm thấy       |
| 1005 | Validation Error | Dữ liệu không hợp lệ |

**💡 Tip:** Frontend có thể cache error codes từ `/api/error-codes` để map error codes thành user-friendly messages.

---

## 🎯 Recommended Testing Flow

1. **Public Access:**

   - Browse categories: `GET /api/categories`
   - Browse cities: `GET /api/cities`
   - Browse events: `GET /api/events`
   - View event details: `GET /api/events/{eventId}`

2. **User Flow:**

   - Login: `POST /api/auth/login` (user: `user1`, pass: `123456`)
   - View profile: `GET /api/users/me`
   - Browse events: `GET /api/events`
   - Add favorite: `POST /api/favorites`
   - View favorites: `GET /api/favorites`
   - Create order: `POST /api/orders`
   - View orders: `GET /api/orders`
   - View tickets: `GET /api/tickets`

3. **Admin Flow:**
   - Login: `POST /api/auth/login` (user: `admin`, pass: `admin`)
   - Create event: `POST /api/events`
   - Update event: `PUT /api/events/{eventId}`
   - Create city: `POST /api/cities`
   - Create venue: `POST /api/venues`

---

## 📝 Notes

- Tất cả dates sử dụng ISO 8601 format: `2025-01-15T19:00:00`
- Currency mặc định: `VND`
- Timezone: `Asia/Ho_Chi_Minh`
- Pagination: Default page size = 20
- Vietnamese text: Tất cả dữ liệu mặc định đều có dấu đầy đủ

---

## 🔗 Useful Endpoints

### Public Endpoints (không cần auth):

- `GET /api/categories`
- `GET /api/cities`
- `GET /api/venues`
- `GET /api/venues/{venueId}`
- `GET /api/venues/{venueId}/seats?eventId={eventId}`
- `GET /api/events`
- `GET /api/events/{eventId}`
- `GET /api/events/{eventId}/tickets`
- `GET /api/error-codes` - Get all error codes and messages
- `POST /api/auth/login`
- `POST /api/auth/register`

### Authenticated Endpoints (cần USER role):

- `GET /api/users/me`
- `GET /api/orders`
- `GET /api/tickets`
- `GET /api/favorites`
- `POST /api/favorites`
- `DELETE /api/favorites/{eventId}`
- `GET /api/vouchers`
- `GET /api/notifications`
- `POST /api/orders` (create order)

### Admin Endpoints (cần ADMIN role):

- `POST /api/events`
- `PUT /api/events/{eventId}`
- `DELETE /api/events/{eventId}`
- `POST /api/cities`
- `PUT /api/cities/{cityId}`
- `DELETE /api/cities/{cityId}`
- `POST /api/venues`
- `PUT /api/venues/{venueId}`
- `DELETE /api/venues/{venueId}`

---

## 📖 Swagger Documentation

Truy cập Swagger UI để xem chi tiết tất cả APIs:

```
http://localhost:8080/api/swagger-ui.html
```

Hoặc OpenAPI JSON:

```
http://localhost:8080/api/v3/api-docs
```
