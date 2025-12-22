# 🚀 ZaloPay Integration - Quick Guide

## 📋 Flow Summary

### Complete Payment Flow

```
┌─────────────────────────────────────────────────────────────┐
│                   1. USER PURCHASE                          │
│  POST /api/tickets/purchase                                  │
│  {                                                           │
│    "eventId": "...",                                         │
│    "ticketTypeId": "...",                                    │
│    "quantity": 2,                                            │
│    "paymentMethod": "ZALOPAY"  ← Chọn ZaloPay              │
│  }                                                           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│             2. BACKEND CREATES ORDER                        │
│  - BookingService validates & creates Order (PENDING)       │
│  - ZaloPayService creates payment order                     │
│  - Generate app_trans_id: YYMMDD + orderId                  │
│  - Store in order.zalopayTransactionId                     │
│  - Get orderUrl from ZaloPay API                            │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│             3. RESPONSE TO USER                             │
│  {                                                           │
│    "orderId": "uuid",                                        │
│    "paymentUrl": "https://sbgateway.zalopay.vn/pay?...",   │
│    "status": "PENDING",                                      │
│    "total": 100000                                           │
│  }                                                           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│             4. FRONTEND REDIRECTS                           │
│  window.location.href = paymentUrl                          │
│  → User sees ZaloPay payment page                           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│             5. USER PAYS ON ZALOPAY                         │
│  - Enter card info (test card in sandbox)                   │
│  - Confirm payment                                           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│             6. ZALOPAY CALLBACK                              │
│  POST /api/payments/zalopay/callback                        │
│  - ZaloPayController verifies signature                     │
│  - Finds order by zalopayTransactionId                      │
│  - Verifies amount matches                                   │
│  - Completes order (status = COMPLETED)                      │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│             7. ORDER CONFIRMED ✅                           │
│  - Order.status = COMPLETED                                  │
│  - Tickets available for user                                │
│  - User redirected to success page                           │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Setup Guide

### 1. Get Sandbox Credentials

1. Đăng ký tại: [https://sbmc.zalopay.vn/](https://sbmc.zalopay.vn/)
2. Lấy thông tin:
   - `AppId`
   - `Key1` (dùng để tạo signature)
   - `Key2` (dùng để verify callback)

### 2. Configure Environment Variables

```bash
# Sandbox Mode
export ZALOPAY_SANDBOX_ENABLED=true
export ZALOPAY_SANDBOX_APP_ID=your_sandbox_app_id
export ZALOPAY_SANDBOX_KEY1=your_sandbox_key1
export ZALOPAY_SANDBOX_KEY2=your_sandbox_key2

# URLs (optional, có default)
export ZALOPAY_CALLBACK_URL=http://localhost:8080/api/payments/zalopay/callback
export ZALOPAY_REDIRECT_URL=http://localhost:3000/payment/success
```

Hoặc thêm vào `application.yaml`:
```yaml
zalopay:
  sandbox:
    enabled: true
    app-id: your_sandbox_app_id
    key1: your_sandbox_key1
    key2: your_sandbox_key2
```

### 3. Install ZaloPay Sandbox App

- Tải app ZaloPay Sandbox trên mobile
- Nạp tiền vào tài khoản sandbox để test

## 🧪 Testing Guide

### Step 1: Purchase Tickets with ZaloPay

```bash
# 1. Login
POST /api/auth/login
{
  "username": "user1",
  "password": "123456"
}

# Response:
{
  "result": {
    "token": "eyJ...",
    "authenticated": true
  }
}
```

```bash
# 2. Purchase with ZaloPay
POST /api/tickets/purchase
Authorization: Bearer {token}
{
  "eventId": "event-uuid",
  "ticketTypeId": "ticket-type-uuid",
  "quantity": 2,
  "paymentMethod": "ZALOPAY"
}

# Response:
{
  "result": {
    "orderId": "order-uuid",
    "status": "PENDING",
    "paymentUrl": "https://sbgateway.zalopay.vn/pay?order=...",
    "total": 100000,
    "expiresAt": "2025-12-22T10:30:00"
  }
}
```

### Step 2: Redirect to Payment

**Frontend:**
```javascript
// Redirect user to ZaloPay
window.location.href = response.result.paymentUrl;
```

### Step 3: Pay with Test Card

**Test Cards (Sandbox):**
- **Visa/Master/JCB:**
  - Số thẻ: `4111111111111111`
  - Tên: `NGUYEN VAN A`
  - Ngày hết hạn: `01/25`
  - CVV: `123`

- **ATM (SBI Bank):**
  - Số thẻ: `9704540000000062`
  - Tên: `NGUYEN VAN A`
  - Ngày hết hạn: `10/18`

### Step 4: Verify Callback

ZaloPay sẽ tự động gọi callback endpoint sau khi thanh toán.

**Check logs:**
```bash
# Backend logs should show:
ZaloPay callback verified: appTransId=..., status=1, amount=100000
Order completed via ZaloPay callback: orderId=..., appTransId=...
```

### Step 5: Query Payment Status (Optional)

```bash
GET /api/payments/zalopay/status/{orderId}
Authorization: Bearer {token}

# Response:
{
  "result": {
    "returnCode": 1,
    "returnMessage": "success",
    "isProcessing": false,
    "amount": 100000,
    "zpTransId": 123456789
  }
}
```

## 📡 API Endpoints

### Public Endpoints (No Auth)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/payments/zalopay/callback` | ZaloPay callback (called by ZaloPay) |

### Authenticated Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/tickets/purchase` | Purchase tickets (set `paymentMethod: "ZALOPAY"`) |
| `GET` | `/api/payments/zalopay/status/{orderId}` | Query payment status |

## 🔑 Key Concepts

### app_trans_id Format

- **Format:** `YYMMDD + orderId` (without dashes)
- **Max length:** 20 characters
- **Example:** `251222a1b2c3d4e5f6` (6 chars date + 14 chars orderId)
- **Stored in:** `order.zalopayTransactionId`
- **Used for:** Finding order from callback

### Payment Status

- **Status 1:** Payment successful → Order completed
- **Status 2:** Payment failed → Order remains PENDING
- **Status 3:** Processing → Order remains PENDING

### Order States

```
PENDING → (Payment success) → COMPLETED
   ↓
   └→ (Expired after 15min) → (Cleanup job)
```

## 🔐 Security

1. **Signature Verification:**
   - All callbacks verified with HMAC SHA256
   - Uses Key2 for callback verification

2. **Amount Verification:**
   - Callback amount must match order total
   - Prevents tampering

3. **Idempotent Callbacks:**
   - Check order status before completing
   - Handle duplicate callbacks safely

## 📝 Configuration Checklist

- [ ] Get ZaloPay sandbox credentials
- [ ] Set environment variables or update `application.yaml`
- [ ] Install ZaloPay Sandbox app (for testing)
- [ ] Configure callback URL in ZaloPay merchant portal
- [ ] Test purchase flow
- [ ] Verify callback works
- [ ] Check order completion

## 🐛 Troubleshooting

### Issue: ZaloPay order creation fails

**Check:**
- Credentials are correct (AppId, Key1, Key2)
- Sandbox mode is enabled
- Network connectivity to ZaloPay API

### Issue: Callback not received

**Check:**
- Callback URL is accessible from internet
- URL configured correctly in ZaloPay portal
- Check backend logs for errors

### Issue: Signature verification fails

**Check:**
- Key2 is correct
- Signature data format matches ZaloPay spec
- Check logs for signature mismatch details

### Issue: Order not found in callback

**Check:**
- `app_trans_id` matches stored `zalopayTransactionId`
- Order was created successfully
- Check database for order record

## 📚 Related Documents

- `ZALOPAY_INTEGRATION.md` - Detailed integration guide (setup, architecture, security)
- `ZALOPAY_FLOW_REVIEW.md` - Complete flow review with diagrams
- `API_INTEGRATION_GUIDE.md` - General API guide

## 📊 Summary

### What Was Implemented

✅ **ZaloPay Payment Integration**
- Create payment orders
- Handle callbacks
- Verify signatures
- Query payment status

✅ **Full Flow Support**
- Purchase → Pay → Confirm
- Automatic order completion
- Transaction ID tracking

✅ **Sandbox/Production Ready**
- Environment-based configuration
- Easy switch between sandbox/production

### Files Created

```
payment/zalopay/
├── ZaloPayConfig.java              # Configuration
├── ZaloPayService.java             # Main service
├── ZaloPayController.java          # REST endpoints
├── dto/                            # Request/Response DTOs
└── util/
    └── ZaloPaySignatureUtil.java   # HMAC signature

service/
└── OrderService.java                # Order completion

Updated:
├── PaymentMethod.java               # Added ZALOPAY
├── Order.java                       # Added zalopayTransactionId
├── OrderRepository.java             # Added findByZalopayTransactionId
├── BookingService.java              # Integrated ZaloPay
└── application.yaml                 # ZaloPay config
```

### Next Steps

1. **Get Credentials:** Register at https://sbmc.zalopay.vn/
2. **Configure:** Set environment variables
3. **Test:** Use test cards in sandbox
4. **Deploy:** Switch to production when ready

## 🎯 Quick Test Script

```bash
# 1. Login
TOKEN=$(curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user1","password":"123456"}' \
  | jq -r '.result.token')

# 2. Purchase with ZaloPay
curl -X POST http://localhost:8080/api/tickets/purchase \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "eventId": "event-id",
    "ticketTypeId": "ticket-type-id",
    "quantity": 1,
    "paymentMethod": "ZALOPAY"
  }' | jq

# 3. Get paymentUrl from response and open in browser
# 4. Pay with test card
# 5. Check order status
curl -X GET "http://localhost:8080/api/payments/zalopay/status/{orderId}" \
  -H "Authorization: Bearer $TOKEN" | jq
```

---

**Ready to test!** 🚀

