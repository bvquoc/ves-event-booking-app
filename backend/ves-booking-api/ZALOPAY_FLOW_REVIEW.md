# 🔄 ZaloPay Payment Flow Review

## 📋 Complete Flow: Mua vé -> Thanh toán -> Xác nhận đơn hàng

### Flow Diagram

```
┌─────────┐
│  User   │
└────┬────┘
     │
     │ 1. POST /api/tickets/purchase
     │    {
     │      "eventId": "...",
     │      "ticketTypeId": "...",
     │      "quantity": 2,
     │      "paymentMethod": "ZALOPAY"
     │    }
     ▼
┌─────────────────────┐
│ BookingService      │
│ purchaseTickets()   │
└────┬────────────────┘
     │
     │ 2. Validate & Create Order
     │    - Check event, ticket type, availability
     │    - Validate seats (if required)
     │    - Apply voucher (if provided)
     │    - Calculate total
     │    - Create Order (status: PENDING)
     │    - Create Tickets (status: ACTIVE)
     │    - Decrement available count
     │
     │ 3. If paymentMethod == ZALOPAY:
     │    - Call ZaloPayService.createPaymentOrder()
     │    - Generate app_trans_id (YYMMDD + orderId)
     │    - Store app_trans_id in order.zalopayTransactionId
     │    - Store orderUrl in order.paymentUrl
     │
     ▼
┌─────────────────────┐
│ ZaloPayService      │
│ createPaymentOrder()│
└────┬────────────────┘
     │
     │ 4. Create ZaloPay Order
     │    - Build request with signature (HMAC SHA256)
     │    - POST to ZaloPay API
     │    - Get orderUrl from response
     │
     ▼
┌─────────────────────┐
│ Response            │
│ {                   │
│   "orderId": "...", │
│   "paymentUrl":     │
│     "https://sb...",│
│   "status": "PENDING"│
│ }                   │
└────┬────────────────┘
     │
     │ 5. Frontend redirects user to paymentUrl
     │
     ▼
┌─────────────────────┐
│ ZaloPay Gateway     │
│ (Sandbox/Production)│
└────┬────────────────┘
     │
     │ 6. User completes payment
     │    - Enter card info (test cards in sandbox)
     │    - Confirm payment
     │
     │ 7. ZaloPay processes payment
     │
     │ 8. ZaloPay calls callback
     │    POST /api/payments/zalopay/callback
     │    {
     │      "data": "{...}",
     │      "mac": "signature"
     │    }
     │
     ▼
┌─────────────────────┐
│ ZaloPayController   │
│ handleCallback()    │
└────┬────────────────┘
     │
     │ 9. Verify callback
     │    - Parse callback data
     │    - Verify signature (HMAC SHA256 with Key2)
     │    - Find order by zalopayTransactionId
     │    - Verify amount matches
     │
     │ 10. If status == 1 (success):
     │     - Update order.zalopayTransactionId
     │     - Call OrderService.completeOrder()
     │     - Update order.status = COMPLETED
     │     - Set order.completedAt
     │
     │ 11. Return success to ZaloPay
     │     {
     │       "return_code": 1,
     │       "return_message": "success"
     │     }
     │
     ▼
┌─────────────────────┐
│ ZaloPay redirects   │
│ to redirectUrl      │
└────┬────────────────┘
     │
     │ 12. Frontend shows success page
     │     - User can view tickets
     │     - Order is confirmed
     │
     ▼
┌─────────┐
│  User   │
│ (Done) │
└────────┘
```

## 🔍 Step-by-Step Review

### Step 1: User Initiates Purchase

**Endpoint:** `POST /api/tickets/purchase`

**Request:**
```json
{
  "eventId": "event-uuid",
  "ticketTypeId": "ticket-type-uuid",
  "quantity": 2,
  "seatIds": ["seat1", "seat2"],  // Optional, if requiresSeatSelection
  "voucherCode": "GIAM20",         // Optional
  "paymentMethod": "ZALOPAY"
}
```

**Authentication:** Required (Bearer token)

**What happens:**
1. `BookingService.purchaseTickets()` validates request
2. Checks event, ticket type, availability
3. Validates seats (if required)
4. Applies voucher discount
5. Creates `Order` with status `PENDING`
6. Creates `Ticket` entities
7. **If ZALOPAY:** Calls `ZaloPayService.createPaymentOrder()`

### Step 2: Create ZaloPay Payment Order

**Service:** `ZaloPayService.createPaymentOrder(Order order)`

**What happens:**
1. Generate `app_trans_id`: `YYMMDD + orderId` (max 20 chars)
   - Example: `251222a1b2c3d4e5` (6 chars date + 14 chars orderId)
2. Build request with:
   - `app_id`: From config
   - `app_user`: Username
   - `app_time`: Current timestamp
   - `amount`: Order total
   - `app_trans_id`: Generated ID
   - `description`: "Thanh toan don hang {orderId}"
   - `item`: JSON array of items
   - `mac`: HMAC SHA256 signature
3. POST to ZaloPay API: `https://sb-openapi.zalopay.vn/v2/create`
4. Get response with `orderUrl`
5. Store `app_trans_id` in `order.zalopayTransactionId`
6. Store `orderUrl` in `order.paymentUrl`

**Response to User:**
```json
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

### Step 3: User Redirects to ZaloPay

**Frontend Action:**
```javascript
// Redirect user to payment URL
window.location.href = response.result.paymentUrl;
```

**User sees:**
- ZaloPay payment page
- Order details
- Payment form (card, bank, etc.)

### Step 4: User Completes Payment

**In Sandbox:**
- Use test card: `4111111111111111`
- CVV: `123`
- Expiry: `01/25`

**ZaloPay processes:**
- Validates payment
- Processes transaction
- Calls callback endpoint

### Step 5: ZaloPay Callback

**Endpoint:** `POST /api/payments/zalopay/callback` (Public, no auth)

**Request from ZaloPay:**
```
POST /api/payments/zalopay/callback
Content-Type: application/x-www-form-urlencoded

data={"app_id":"...","app_trans_id":"251222a1b2c3d4e5","status":1,...}&mac=abc123...
```

**What happens in `ZaloPayController.handleCallback()`:**
1. Parse `data` and `mac` from form params
2. Parse JSON data into `ZaloPayCallbackRequest`
3. **Verify signature:**
   ```java
   String data = app_id|app_trans_id|pmcid|bank_code|amount|discount_amount|status;
   boolean isValid = verifySignature(data, key2, mac);
   ```
4. **Find order:**
   ```java
   Order order = orderRepository.findByZalopayTransactionId(appTransId);
   ```
5. **Verify amount:**
   ```java
   if (order.getTotal() != callback.getAmount()) {
       return error;
   }
   ```
6. **If status == 1 (success):**
   ```java
   order.setZalopayTransactionId(appTransId); // Update if needed
   orderService.completeOrder(orderId);
   // Sets status = COMPLETED, completedAt = now
   ```
7. **Return success to ZaloPay:**
   ```json
   {
     "return_code": 1,
     "return_message": "success"
   }
   ```

### Step 6: Order Confirmation

**After callback:**
- `Order.status` = `COMPLETED`
- `Order.completedAt` = current timestamp
- `Order.zalopayTransactionId` = app_trans_id
- Tickets remain `ACTIVE` (ready to use)

**Frontend:**
- ZaloPay redirects to `redirectUrl`
- Frontend shows success page
- User can view tickets in "My Tickets"

## 🔐 Security Checklist

- ✅ **Signature Verification:** All callbacks verified with HMAC SHA256
- ✅ **Amount Verification:** Callback amount must match order total
- ✅ **Idempotent Callbacks:** Check order status before completing
- ✅ **Public Callback:** No auth required (ZaloPay calls it)
- ✅ **Transaction ID Storage:** Store app_trans_id for lookup

## 📊 Database Changes

### Order Entity
```java
String paymentUrl;              // ZaloPay order URL
String zalopayTransactionId;    // app_trans_id for callback lookup
```

### OrderRepository
```java
Order findByZalopayTransactionId(String zalopayTransactionId);
```

## 🧪 Testing Flow

### 1. Test Purchase with ZaloPay

```bash
# 1. Login
POST /api/auth/login
{
  "username": "user1",
  "password": "123456"
}

# 2. Purchase tickets with ZaloPay
POST /api/tickets/purchase
Authorization: Bearer {token}
{
  "eventId": "event-id",
  "ticketTypeId": "ticket-type-id",
  "quantity": 2,
  "paymentMethod": "ZALOPAY"
}

# Response:
{
  "result": {
    "orderId": "...",
    "paymentUrl": "https://sbgateway.zalopay.vn/pay?order=...",
    "status": "PENDING"
  }
}
```

### 2. Test Callback (Manual)

```bash
# Simulate ZaloPay callback
POST /api/payments/zalopay/callback
Content-Type: application/x-www-form-urlencoded

data={"app_id":"...","app_trans_id":"251222...","status":1,"amount":100000,...}&mac=...
```

### 3. Query Payment Status

```bash
GET /api/payments/zalopay/status/{orderId}
Authorization: Bearer {token}
```

## ⚠️ Important Notes

1. **app_trans_id Format:**
   - Format: `YYMMDD + orderId` (without dashes)
   - Max 20 characters
   - Stored in `order.zalopayTransactionId` for callback lookup

2. **Callback Security:**
   - Always verify signature before processing
   - Always verify amount matches
   - Handle duplicate callbacks (idempotent)

3. **Order Expiry:**
   - Orders expire after 15 minutes
   - Expired orders should be cleaned up
   - ZaloPay won't process expired orders

4. **Error Handling:**
   - If ZaloPay API fails, order remains PENDING
   - User can retry payment
   - Or cancel order

## 🎯 Success Criteria

✅ User can purchase tickets with ZaloPay  
✅ Order created with PENDING status  
✅ ZaloPay order created successfully  
✅ User redirected to ZaloPay payment page  
✅ Payment callback received and verified  
✅ Order status updated to COMPLETED  
✅ Tickets available for user  

## 📝 Next Steps

1. ✅ Implement ZaloPay integration
2. ⏳ Test with sandbox credentials
3. ⏳ Handle edge cases (expired orders, failed payments)
4. ⏳ Add payment status query endpoint
5. ⏳ Add order cancellation for failed payments
6. ⏳ Production deployment with real credentials

