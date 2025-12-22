# 💳 ZaloPay Integration Guide

Hướng dẫn tích hợp ZaloPay payment gateway vào hệ thống VES Booking API.

## 📋 Tổng quan

ZaloPay là một cổng thanh toán phổ biến tại Việt Nam, hỗ trợ nhiều phương thức thanh toán:
- Thanh toán qua Cổng ZaloPay (Website)
- Thanh toán bằng mã QR (POS)
- App To App
- QuickPay
- Web in App
- QRCode tĩnh tại quầy
- Mobile Web To App

## 🔧 Setup Sandbox/Development Mode

### 1. Đăng ký tài khoản Sandbox

1. Liên hệ nhóm hỗ trợ ZaloPay để tạo tài khoản sandbox
   - Cung cấp: Số điện thoại và Email
   - Link: [https://docs.zalopay.vn](https://docs.zalopay.vn)

2. Đăng nhập Merchant Portal
   - Sandbox: [https://sbmc.zalopay.vn/](https://sbmc.zalopay.vn/)
   - Production: [https://mc.zalopay.vn/](https://mc.zalopay.vn/)

3. Lấy thông tin credentials:
   - `AppId`: Application ID
   - `Key1`: Key 1 (dùng để tạo MAC)
   - `Key2`: Key 2 (dùng để verify callback)
   - `Callback URL`: URL nhận callback từ ZaloPay
   - `Redirect URL`: URL redirect sau khi thanh toán

### 2. Cài đặt ZaloPay Sandbox App

- Tải ứng dụng ZaloPay Sandbox trên mobile
- Nạp tiền vào tài khoản sandbox để test

### 3. Thông tin thẻ test

**Thẻ Visa/Master/JCB:**
- Số thẻ: `4111111111111111`
- Tên: `NGUYEN VAN A`
- Ngày hết hạn: `01/25`
- CVV: `123`

**Thẻ ATM (SBI Bank):**
- Số thẻ: `9704540000000062`
- Tên: `NGUYEN VAN A`
- Ngày hết hạn: `10/18`

## 📦 Dependencies

Thêm dependencies vào `pom.xml`:

```xml
<!-- HTTP Client for ZaloPay API -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>

<!-- JSON processing -->
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
</dependency>

<!-- HMAC for signature -->
<dependency>
    <groupId>commons-codec</groupId>
    <artifactId>commons-codec</artifactId>
    <version>1.15</version>
</dependency>
```

## ⚙️ Configuration

### application.yaml

```yaml
zalopay:
  # Sandbox mode
  sandbox:
    enabled: true
    app-id: ${ZALOPAY_SANDBOX_APP_ID:your_sandbox_app_id}
    key1: ${ZALOPAY_SANDBOX_KEY1:your_sandbox_key1}
    key2: ${ZALOPAY_SANDBOX_KEY2:your_sandbox_key2}
    endpoint: https://sb-openapi.zalopay.vn/v2/create
    
  # Production mode
  production:
    enabled: false
    app-id: ${ZALOPAY_APP_ID:}
    key1: ${ZALOPAY_KEY1:}
    key2: ${ZALOPAY_KEY2:}
    endpoint: https://openapi.zalopay.vn/v2/create
    
  # Common settings
  callback-url: ${ZALOPAY_CALLBACK_URL:http://localhost:8080/api/payments/zalopay/callback}
  redirect-url: ${ZALOPAY_REDIRECT_URL:http://localhost:3000/payment/success}
  query-status-url: https://sb-openapi.zalopay.vn/v2/query
```

### Environment Variables

```bash
# Sandbox
ZALOPAY_SANDBOX_APP_ID=your_sandbox_app_id
ZALOPAY_SANDBOX_KEY1=your_sandbox_key1
ZALOPAY_SANDBOX_KEY2=your_sandbox_key2

# Production (when ready)
ZALOPAY_APP_ID=your_production_app_id
ZALOPAY_KEY1=your_production_key1
ZALOPAY_KEY2=your_production_key2

# URLs
ZALOPAY_CALLBACK_URL=https://your-domain.com/api/payments/zalopay/callback
ZALOPAY_REDIRECT_URL=https://your-domain.com/payment/success
```

## 🏗️ Architecture

### File Structure

```
src/main/java/com/uit/vesbookingapi/
├── payment/
│   ├── zalopay/
│   │   ├── ZaloPayConfig.java          # Configuration
│   │   ├── ZaloPayService.java         # Main service
│   │   ├── ZaloPayController.java      # REST endpoints
│   │   ├── dto/
│   │   │   ├── ZaloPayCreateOrderRequest.java
│   │   │   ├── ZaloPayCreateOrderResponse.java
│   │   │   ├── ZaloPayCallbackRequest.java
│   │   │   └── ZaloPayQueryStatusResponse.java
│   │   └── util/
│   │       └── ZaloPaySignatureUtil.java  # HMAC signature
│   └── PaymentService.java             # Payment abstraction
```

## 🔐 Security - HMAC Signature

ZaloPay sử dụng HMAC SHA256 để tạo và verify signature.

### Signature Format

```
HMAC_SHA256(data, key)
```

### Create Order Signature

```java
String data = appid + "|" + apptransid + "|" + appuser + "|" + amount 
           + "|" + apptime + "|" + embeddata + "|" + item;
String mac = HMAC_SHA256(data, key1);
```

### Callback Verification

```java
String data = appid + "|" + apptransid + "|" + pmcid + "|" + bankcode 
           + "|" + amount + "|" + discountamount + "|" + status;
String mac = HMAC_SHA256(data, key2);
// Verify mac == callback.mac
```

## 📡 API Endpoints

### 1. Create Payment Order

**Endpoint:** `POST /api/payments/zalopay/create`

**Request:**
```json
{
  "orderId": "order-uuid",
  "amount": 100000,
  "description": "Thanh toan ve su kien",
  "userId": "user-uuid"
}
```

**Response:**
```json
{
  "result": {
    "orderUrl": "https://sbgateway.zalopay.vn/pay?order=...",
    "orderToken": "token_string",
    "returnCode": 1,
    "returnMessage": "success",
    "subReturnCode": 1,
    "subReturnMessage": "success"
  }
}
```

### 2. Callback Handler

**Endpoint:** `POST /api/payments/zalopay/callback`

ZaloPay sẽ gọi endpoint này sau khi thanh toán thành công/thất bại.

**Request (from ZaloPay):**
```
POST /api/payments/zalopay/callback
Content-Type: application/x-www-form-urlencoded

data={...}&mac={signature}
```

**Response:**
```json
{
  "return_code": 1,
  "return_message": "success"
}
```

### 3. Query Payment Status

**Endpoint:** `GET /api/payments/zalopay/status/{orderId}`

**Response:**
```json
{
  "result": {
    "returnCode": 1,
    "returnMessage": "success",
    "isProcessing": false,
    "amount": 100000,
    "zpTransId": 123456789,
    "serverTime": 1234567890
  }
}
```

## 🔄 Payment Flow

```
1. User clicks "Pay with ZaloPay"
   ↓
2. Frontend calls: POST /api/payments/zalopay/create
   ↓
3. Backend creates order in DB (status: PENDING)
   ↓
4. Backend calls ZaloPay API to create payment
   ↓
5. Backend returns orderUrl to Frontend
   ↓
6. Frontend redirects user to orderUrl
   ↓
7. User completes payment on ZaloPay
   ↓
8. ZaloPay calls: POST /api/payments/zalopay/callback
   ↓
9. Backend verifies signature and updates order status
   ↓
10. ZaloPay redirects user to redirectUrl
    ↓
11. Frontend shows success/failure page
```

## 🛠️ Implementation Steps

### Step 1: Add ZALOPAY to PaymentMethod enum

```java
public enum PaymentMethod {
    CREDIT_CARD,
    DEBIT_CARD,
    E_WALLET,
    BANK_TRANSFER,
    ZALOPAY  // Add this
}
```

### Step 2: Create ZaloPay Configuration

```java
@Configuration
@ConfigurationProperties(prefix = "zalopay")
@Data
public class ZaloPayConfig {
    private Sandbox sandbox;
    private Production production;
    private String callbackUrl;
    private String redirectUrl;
    private String queryStatusUrl;
    
    public boolean isSandboxMode() {
        return sandbox != null && sandbox.isEnabled();
    }
    
    public String getAppId() {
        return isSandboxMode() ? sandbox.getAppId() : production.getAppId();
    }
    
    public String getKey1() {
        return isSandboxMode() ? sandbox.getKey1() : production.getKey1();
    }
    
    public String getKey2() {
        return isSandboxMode() ? sandbox.getKey2() : production.getKey2();
    }
    
    public String getCreateOrderEndpoint() {
        return isSandboxMode() ? sandbox.getEndpoint() : production.getEndpoint();
    }
}
```

### Step 3: Create Signature Utility

```java
@Component
public class ZaloPaySignatureUtil {
    
    public String createSignature(String data, String key) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKeySpec = new SecretKeySpec(key.getBytes(), "HmacSHA256");
            mac.init(secretKeySpec);
            byte[] hash = mac.doFinal(data.getBytes());
            return Hex.encodeHexString(hash);
        } catch (Exception e) {
            throw new RuntimeException("Failed to create signature", e);
        }
    }
    
    public boolean verifySignature(String data, String key, String signature) {
        String calculatedMac = createSignature(data, key);
        return calculatedMac.equals(signature);
    }
}
```

### Step 4: Create ZaloPay Service

Main service sẽ handle:
- Create payment order
- Verify callback
- Query payment status
- Update order in database

### Step 5: Create Controller

REST endpoints cho:
- Create payment
- Callback handler
- Query status

## 🧪 Testing

### Test Cases

1. **Create Order Success**
   - Valid order data
   - Returns orderUrl

2. **Create Order Failure**
   - Invalid amount
   - Missing required fields

3. **Callback Success**
   - Valid signature
   - Update order status to COMPLETED

4. **Callback Failure**
   - Invalid signature
   - Reject callback

5. **Query Status**
   - Order found
   - Order not found

### Test với Sandbox

1. Tạo order với amount nhỏ (ví dụ: 1000 VND)
2. Dùng thẻ test để thanh toán
3. Verify callback được gọi
4. Check order status được update

## 📝 Notes

### Sandbox vs Production

**Sandbox:**
- Endpoint: `https://sb-openapi.zalopay.vn`
- Callback URL: Port 80 OK
- Test cards available
- No real money

**Production:**
- Endpoint: `https://openapi.zalopay.vn`
- Callback URL: Port 443 required, TLS 1.2+
- Real money transactions
- Need production credentials

### Security Best Practices

1. **Never expose Key1/Key2** in frontend
2. **Always verify callback signature** before processing
3. **Use HTTPS** in production
4. **Validate amount** in callback (prevent tampering)
5. **Idempotent callbacks** (handle duplicate callbacks)

### Error Handling

- Network errors: Retry with exponential backoff
- Invalid signature: Log and reject
- Order not found: Return appropriate error
- Timeout: Implement timeout handling

## 📚 References

- [ZaloPay Developer Portal](https://developer.zalopay.vn/)
- [ZaloPay Documentation](https://docs.zalopay.vn/)
- [Integration Guide](https://docs.zalopay.vn/vi/docs/developer-tools/integration-guide/)
- [API Reference](https://developer.zalopay.vn/en/v1/reference/)

## 🚀 Next Steps

1. ✅ Research ZaloPay integration
2. ⏳ Add ZALOPAY to PaymentMethod enum
3. ⏳ Create ZaloPay configuration
4. ⏳ Implement signature utility
5. ⏳ Create ZaloPay service
6. ⏳ Create ZaloPay controller
7. ⏳ Add callback handler
8. ⏳ Test with sandbox
9. ⏳ Update Order entity to support ZaloPay
10. ⏳ Add payment status tracking

