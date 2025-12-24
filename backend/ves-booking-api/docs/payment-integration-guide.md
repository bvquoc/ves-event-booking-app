# ZaloPay Payment Integration Guide

**Last Updated:** December 23, 2025
**Version:** 1.0.0
**Status:** Production Ready (3 Security Fixes Required)

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Setup & Configuration](#setup--configuration)
4. [API Integration](#api-integration)
5. [Payment Flow](#payment-flow)
6. [Webhook Handling](#webhook-handling)
7. [Refund Processing](#refund-processing)
8. [Reconciliation](#reconciliation)
9. [Security Considerations](#security-considerations)
10. [Troubleshooting](#troubleshooting)
11. [Testing](#testing)

## Overview

ZaloPay integration enables secure payment processing for event bookings. The system handles:

- Payment initiation and verification
- Webhook callback processing
- Automatic payment reconciliation
- Refund processing with retry logic
- Comprehensive audit logging

### Key Features

- **HMAC-SHA256 Signature Verification:** All requests/responses verified
- **Idempotent Operations:** Transaction IDs prevent duplicate charges
- **Automated Reconciliation:** 5-minute reconciliation cycle
- **Audit Trail:** Complete transaction history logging
- **IP Whitelisting:** Callback endpoint security
- **Refund Management:** Automated retry with exponential backoff

## Architecture

### Component Diagram

```
┌──────────────┐
│   Frontend   │
└──────┬───────┘
       │
       ├─→ POST /orders
       │   (Create order request)
       │
┌──────▼─────────────────────────────────┐
│   Order Service                         │
│   ├─ Create Order entity                │
│   └─ Invoke ZaloPayService              │
└──────┬─────────────────────────────────┘
       │
       ├─→ POST /create (ZaloPay API)
       │   ├─ Generate HMAC-SHA256 signature
       │   └─ Return payment URL
       │
┌──────▼──────────────────────────────────┐
│   ZaloPay Payment Gateway                │
│   (Sandbox/Production)                   │
└──────┬──────────────────────────────────┘
       │
       ├─→ Customer completes payment
       │
       └─→ POST /payments/zalopay/callback
           (Webhook with payment confirmation)
           │
           ├─ Verify MAC using key2
           ├─ Update Order status to COMPLETED
           ├─ Activate Tickets
           └─ Log Payment Transaction
```

### Components

1. **ZaloPayService** - Core payment gateway operations
    - Order creation
    - Order status queries
    - Refund requests

2. **PaymentCallbackService** - Webhook processing
    - Callback verification
    - Order/ticket status updates
    - Transaction logging

3. **PaymentReconciliationScheduler** - Automated verification
    - Reconciles pending orders (5-min interval)
    - Expires old pending orders (15-min interval)

4. **RefundRetryScheduler** - Refund processing
    - Retries failed refunds (30-min interval)

5. **PaymentCallbackController** - HTTP endpoints
    - POST /payments/zalopay/callback
    - POST /payments/zalopay/refund-callback

## Setup & Configuration

### 1. ZaloPay Sandbox Registration

Sign up for ZaloPay sandbox at: https://sandbox.zalopay.vn

**Required Information:**

- Business account details
- Verification documents
- Callback URL for webhook handling

### 2. Environment Variables

```bash
# ZaloPay Configuration
export ZALOPAY_APP_ID="your_sandbox_app_id"
export ZALOPAY_KEY1="your_sandbox_key1"
export ZALOPAY_KEY2="your_sandbox_key2"
export ZALOPAY_ENDPOINT="https://sb-openapi.zalopay.vn/v2"
export ZALOPAY_CALLBACK_URL="https://your-domain.com/api/payments/zalopay/callback"
```

### 3. application.yaml Configuration

```yaml
zalopay:
  app-id: ${ZALOPAY_APP_ID:sandbox_app_id}
  key1: ${ZALOPAY_KEY1:sandbox_key1}
  key2: ${ZALOPAY_KEY2:sandbox_key2}
  endpoint: ${ZALOPAY_ENDPOINT:https://sb-openapi.zalopay.vn/v2}
  callback-url: ${ZALOPAY_CALLBACK_URL:https://your-domain.com/api/payments/zalopay/callback}
  payment-timeout-minutes: 15
```

### 4. Database Setup

The following tables are automatically created:

```sql
-- Payment transaction tracking
CREATE TABLE payment_transactions
(
    id               VARCHAR(36) PRIMARY KEY,
    order_id         VARCHAR(36)  NOT NULL,
    app_trans_id     VARCHAR(255) NOT NULL UNIQUE,
    zp_trans_id      VARCHAR(255),
    type             ENUM('CREATE', 'CALLBACK', 'QUERY', 'REFUND'),
    status           ENUM('PENDING', 'SUCCESS', 'FAILED'),
    amount           INT,
    return_code      INT,
    return_message   VARCHAR(500),
    request_payload  LONGTEXT,
    response_payload LONGTEXT,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX            idx_pt_order (order_id),
    INDEX            idx_pt_app_trans_id (app_trans_id),
    INDEX            idx_pt_created (created_at)
);

-- Audit trail for all payment actions
CREATE TABLE payment_audit_logs
(
    id           VARCHAR(36) PRIMARY KEY,
    order_id     VARCHAR(36),
    app_trans_id VARCHAR(255),
    action       VARCHAR(100),
    ip_address   VARCHAR(45),
    payload      LONGTEXT,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX        idx_pal_app_trans_id (app_trans_id),
    INDEX        idx_pal_created (created_at)
);

-- Refund tracking
CREATE TABLE refunds
(
    id                VARCHAR(36) PRIMARY KEY,
    ticket_id         VARCHAR(36)  NOT NULL,
    m_refund_id       VARCHAR(255) NOT NULL UNIQUE,
    zp_trans_id       VARCHAR(255),
    amount            INT,
    status            ENUM('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED'),
    return_code       INT,
    return_message    VARCHAR(500),
    attempt_count     INT      DEFAULT 0,
    last_attempted_at DATETIME,
    completed_at      DATETIME,
    created_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES tickets (id),
    INDEX             idx_refund_m_refund_id (m_refund_id),
    INDEX             idx_refund_status (status)
);
```

## API Integration

### 1. Create Order with Payment

**Endpoint:** POST /orders
**Authentication:** Required (Bearer token)

**Request:**

```json
{
  "eventId": "event_123",
  "ticketTypeId": "ticket_type_456",
  "quantity": 2
}
```

**Response (200 OK):**

```json
{
  "id": "order_789",
  "status": "PENDING",
  "appTransId": "251223_order_789",
  "paymentUrl": "https://sb-static.zalopay.vn/checkout?appid=123&token=...",
  "amount": 5000,
  "currency": "VND",
  "expiresAt": "2025-12-23T15:15:00"
}
```

**Service Code:**

```java
public ZaloPayCreateResponse createOrder(Order order) {
    String appTransId = generateAppTransId(order.getId()); // YYMMDD_orderId
    long appTime = System.currentTimeMillis();

    // Build request with HMAC-SHA256 signature
    String signatureData = buildCreateOrderData(...);
    String mac = ZaloPaySignatureUtil.generateSignature(signatureData, key1);

    // Send to ZaloPay
    ResponseEntity<ZaloPayCreateResponse> response = restTemplate.postForEntity(
            config.getCreateOrderUrl(), request, ZaloPayCreateResponse.class
    );

    // Save transaction record and return payment URL
    saveTransaction(order, appTransId, PaymentTransactionType.CREATE, ...);
    return response.getBody();
}
```

### 2. Query Order Status

**Endpoint:** POST /orders/{orderId}/query-status
**Authentication:** Optional

**Response:**

```json
{
  "orderId": "order_789",
  "appTransId": "251223_order_789",
  "status": "COMPLETED",
  "zpTransId": "220000099877",
  "amount": 5000,
  "paidAt": "2025-12-23T15:05:30"
}
```

### 3. Refund Request

**Endpoint:** POST /tickets/{ticketId}/refund
**Authentication:** Required

**Request:**

```json
{
  "reason": "Event cancelled"
}
```

**Response:**

```json
{
  "refundId": "refund_123",
  "status": "PROCESSING",
  "amount": 2500,
  "estimatedProcessingTime": "1-3 business days"
}
```

## Payment Flow

### Standard Payment Flow

1. **Order Creation**
    - User submits booking request
    - Order entity created with PENDING status
    - AppTransId generated: YYMMDD_orderId

2. **Payment Initiation**
    - POST to ZaloPay /create endpoint
    - Include HMAC-SHA256 signature using key1
    - Receive payment URL (embedded data, item list)
    - Save transaction record (CREATE type)

3. **Customer Payment**
    - Customer redirected to ZaloPay payment page
    - Completes payment using bank/card
    - ZaloPay processes transaction

4. **Webhook Callback**
    - ZaloPay sends POST to /payments/zalopay/callback
    - Payload includes data (base64 encoded) and mac
    - Verify MAC using key2
    - Update Order status to COMPLETED
    - Activate Tickets
    - Save transaction record (CALLBACK type)

5. **Reconciliation (Automatic)**
    - Every 5 minutes: check pending orders
    - Query ZaloPay for order status
    - Confirm payment or mark as expired
    - Expire orders after 15 minutes

### State Transitions

```
Order Created (PENDING)
    ↓
Payment Initiated (PENDING_PAYMENT)
    ↓
[ZaloPay Callback] → Payment Confirmed (COMPLETED)
    ├─→ Tickets Activated
    └─→ Transaction Saved
    ↓
[5-min Reconciliation] → Payment Verified
    ↓
[15-min Expiration] → Order Expired
    └─→ Tickets Cancelled
    └─→ Inventory Released
```

## Webhook Handling

### Callback Endpoint Details

**URL:** POST /api/payments/zalopay/callback

**Authentication:** IP Whitelist + MAC Verification

**Payload Format:**

```json
{
  "type": 1,
  // 1 = payment success, 2 = cancel
  "data": "base64_encoded_json_data",
  "mac": "hmac_sha256_signature"
}
```

**Encoded Data Structure:**

```json
{
  "appTransId": "251223_order_789",
  "zpTransId": "220000099877",
  "amount": 5000,
  "appUserId": "user_123",
  "discountAmount": 0,
  "bankCode": "MB",
  "insertTime": 1703354400000,
  "transId": "220000099877"
}
```

### Processing Steps

```java

@PostMapping("/callback")
public ResponseEntity<Map<String, Object>> handleCallback(
        @RequestBody Map<String, Object> payload,
        HttpServletRequest request) {

    // 1. Validate IP whitelist
    String clientIp = getClientIp(request);
    if (!isIpAllowed(clientIp)) {
        log.warn("Unauthorized callback from IP: {}", clientIp);
        // Log but allow in sandbox
    }

    // 2. Verify MAC signature (CRITICAL)
    String data = (String) payload.get("data");
    String mac = (String) payload.get("mac");
    String computedMac = ZaloPaySignatureUtil.generateSignature(data, key2);
    if (!computedMac.equalsIgnoreCase(mac)) {
        return ResponseEntity.ok(Map.of("return_code", -1));
    }

    // 3. Parse callback data
    ZaloPayCallbackData callbackData = objectMapper.readValue(
            decodeBase64(data), ZaloPayCallbackData.class);

    // 4. Process payment
    callbackService.processPaymentCallback(callbackData, clientIp);

    // 5. Return success
    return ResponseEntity.ok(Map.of(
            "return_code", 1,
            "return_message", "success"
    ));
}
```

### Idempotency Handling

The callback service implements idempotency checks:

```java

@Transactional
public void processPaymentCallback(ZaloPayCallbackData data, String clientIp) {
    Order order = orderRepository.findByAppTransId(data.getAppTransId())
            .orElseThrow(() -> new RuntimeException("Order not found"));

    // Idempotency: skip if already completed
    if (order.getStatus() == OrderStatus.COMPLETED) {
        log.info("Order already completed, skipping: orderId={}", order.getId());
        return;
    }

    // Verify amount matches
    if (data.getAmount() != order.getTotal().longValue()) {
        throw new RuntimeException("Amount mismatch");
    }

    // Update order and tickets
    order.setStatus(OrderStatus.COMPLETED);
    order.setZpTransId(data.getZpTransId());
    orderRepository.save(order);

    // Activate tickets
    ticketRepository.findByOrderId(order.getId()).forEach(ticket -> {
        ticket.setStatus(TicketStatus.ACTIVE);
        ticket.setPurchaseDate(LocalDateTime.now());
    });
}
```

## Refund Processing

### Refund Flow

1. **User Requests Refund**
    - POST /tickets/{ticketId}/refund
    - Create Refund entity with mRefundId
    - mRefundId format: YYMMDD_ticketId_refundCount

2. **Refund Initiation**
    - Call ZaloPay /refund endpoint
    - Include HMAC-SHA256 signature
    - Refund status: PENDING → PROCESSING

3. **Scheduled Retry**
    - Every 30 minutes: check failed refunds
    - Retry processing
    - Update status based on return code

4. **Webhook Callback**
    - ZaloPay sends refund status update
    - Process refund completion/failure

### Refund Status Codes

| Code | Meaning    | Action            |
|------|------------|-------------------|
| 1    | Success    | Mark as COMPLETED |
| 2    | Processing | Retry later       |
| 3    | Failed     | Mark as FAILED    |

### Refund Request Example

```java
public ZaloPayRefundResponse refund(Refund refund) {
    long timestamp = System.currentTimeMillis();

    String signatureData = String.join("|",
            config.getAppId(),
            refund.getZpTransId(),
            String.valueOf(refund.getAmount()),
            "Refund for ticket " + refund.getTicket().getId(),
            String.valueOf(timestamp)
    );
    String mac = ZaloPaySignatureUtil.generateSignature(signatureData, key1);

    MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
    params.add("app_id", config.getAppId());
    params.add("m_refund_id", refund.getMRefundId());
    params.add("zp_trans_id", refund.getZpTransId());
    params.add("amount", String.valueOf(refund.getAmount()));
    params.add("mac", mac);

    return restTemplate.postForEntity(
            config.getRefundUrl(), request, ZaloPayRefundResponse.class
    ).getBody();
}
```

## Reconciliation

### Reconciliation Scheduler

**Schedule:** Every 5 minutes
**Purpose:** Verify pending orders and confirm payments

```java

@Scheduled(fixedRate = 300000)  // 5 minutes
@Transactional
public void reconcilePendingOrders() {
    LocalDateTime threshold = LocalDateTime.now().minusMinutes(5);
    List<Order> pendingOrders = orderRepository.findPendingOrdersOlderThan(threshold);

    for (Order order : pendingOrders) {
        try {
            ZaloPayQueryResponse response = zaloPayService.queryOrder(
                    order.getAppTransId());

            switch (response.getReturnCode()) {
                case 1:  // Paid
                    order.setStatus(OrderStatus.COMPLETED);
                    order.setZpTransId(response.getZpTransId());
                    orderRepository.save(order);
                    activateTickets(order);
                    break;
                case 2:  // Pending
                    if (isExpired(order)) expireOrder(order);
                    break;
                case 3:  // Failed
                    expireOrder(order);
                    break;
            }
        } catch (Exception e) {
            log.error("Reconciliation error: orderId={}", order.getId());
        }
    }
}
```

### Expiration Scheduler

**Schedule:** Every 15 minutes
**Purpose:** Expire old pending orders

```java

@Scheduled(fixedRate = 900000)  // 15 minutes
@Transactional
public void expirePendingOrders() {
    List<Order> expiredOrders = orderRepository.findExpiredPendingOrders(
            LocalDateTime.now());

    for (Order order : expiredOrders) {
        expireOrder(order);  // Release tickets, update inventory
    }
}
```

## Security Considerations

### Critical Security Issues (Production Fixes Required)

#### 1. IP Whitelist Management

**Current:** Hardcoded in controller
**Fix Required:** Load from configuration/database

```java
// BEFORE (insecure)
private static final String[] ALLOWED_IPS = {...};

// AFTER (secure)
private List<String> getAllowedIps() {
    return zaloPayConfigRepository.getAllowedIps();
}
```

#### 2. Credential Management

**Current:** Environment variables
**Fix Required:** Use secure vault (HashiCorp Vault, AWS Secrets Manager)

```bash
# Use secrets vault instead
vault kv get secret/zalopay
aws secretsmanager get-secret-value --secret-id zalopay-keys
```

#### 3. Callback Signature Verification

**Current:** Basic MAC verification
**Fix Required:** Enhance with:

- Timestamp validation
- Request/response replay detection
- Cryptographic binding

### HMAC-SHA256 Signature Verification

```java
public class ZaloPaySignatureUtil {

    public static String generateSignature(String data, String key) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKey = new SecretKeySpec(
                    key.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            mac.init(secretKey);
            byte[] hashBytes = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));

            // Convert to hex string
            StringBuilder result = new StringBuilder();
            for (byte b : hashBytes) {
                result.append(String.format("%02x", b));
            }
            return result.toString();
        } catch (Exception e) {
            throw new RuntimeException("Signature generation failed", e);
        }
    }
}
```

### IP Whitelisting

**Current Allowed IPs:**

- 113.20.108.14 (ZaloPay production)
- 113.20.108.15 (ZaloPay production)
- 118.69.77.70 (ZaloPay sandbox)
- 127.0.0.1 (Local testing)

**Note:** Update from ZaloPay documentation periodically

### Best Practices

1. **Always verify MAC** before processing callbacks
2. **Validate amounts** match expected totals
3. **Use HTTPS** for all API communications
4. **Log all transactions** for audit trail
5. **Implement rate limiting** on callback endpoint
6. **Monitor for duplicate callbacks** using appTransId
7. **Use idempotent operations** for safety
8. **Rotate keys periodically** (quarterly minimum)
9. **Monitor ZaloPay status page** for incidents

## Troubleshooting

### Common Issues

#### 1. Callback Not Received

**Symptoms:** Orders remain PENDING after payment
**Causes:**

- Callback URL misconfigured in ZaloPay dashboard
- Network/firewall blocking webhook
- Invalid MAC signature

**Solutions:**

```bash
# Check callback URL configuration
grep ZALOPAY_CALLBACK_URL .env

# Verify webhook logs
tail -f logs/application.log | grep "callback"

# Test callback endpoint manually
curl -X POST http://localhost:8080/api/payments/zalopay/callback \
  -H "Content-Type: application/json" \
  -d '{"type":1,"data":"...","mac":"..."}'
```

#### 2. MAC Verification Failed

**Symptoms:** "Invalid callback MAC" error
**Causes:**

- Wrong key2 value
- Data encoding issue
- Base64 decoding error

**Solutions:**

```java
// Debug MAC verification
String computedMac = ZaloPaySignatureUtil.generateSignature(data, key2);
log.

debug("Expected: {}, Received: {}",computedMac, receivedMac);

// Verify data encoding
String decodedData = new String(Base64.getDecoder().decode(encodedData));
log.

debug("Decoded data: {}",decodedData);
```

#### 3. Payment Reconciliation Timeout

**Symptoms:** Reconciliation scheduler slow/hanging
**Causes:**

- ZaloPay API latency
- Database locks
- Connection pool exhaustion

**Solutions:**

```yaml
# Increase timeouts in RestTemplate
restTemplate:
  readTimeout: 10000
  connectTimeout: 5000

# Increase connection pool
spring.datasource.hikari:
  maximum-pool-size: 30
```

#### 4. Duplicate Refunds

**Symptoms:** Refund processed twice
**Causes:**

- Webhook retry without idempotency check
- Manual refund trigger duplicated

**Solutions:**

- Use mRefundId for idempotency
- Implement idempotent refund endpoint

```java
public Refund processRefund(String mRefundId) {
    return refundRepository.findByMRefundId(mRefundId)
            .orElseGet(() -> createAndProcessRefund(mRefundId));
}
```

## Testing

### Unit Tests

```java

@SpringBootTest
class ZaloPayServiceTest {

    @MockBean
    private RestTemplate restTemplate;

    @MockBean
    private PaymentTransactionRepository transactionRepository;

    @Autowired
    private ZaloPayService zaloPayService;

    @Test
    void testCreateOrder_Success() {
        // Given
        Order order = createTestOrder();
        ZaloPayCreateResponse mockResponse = new ZaloPayCreateResponse();
        mockResponse.setReturnCode(1);
        mockResponse.setOrderUrl("https://payment.zalopay.vn/...");

        when(restTemplate.postForEntity(any(), any(), any()))
                .thenReturn(new ResponseEntity<>(mockResponse, OK));

        // When
        ZaloPayCreateResponse result = zaloPayService.createOrder(order);

        // Then
        assertEquals(1, result.getReturnCode());
        verify(transactionRepository).save(any());
    }

    @Test
    void testCallback_InvalidMac_Rejected() {
        // Given
        ZaloPayCallbackData callbackData = createTestCallback();
        String invalidMac = "invalid_mac";

        // When
        boolean isValid = ZaloPaySignatureUtil.verifySignature(
                callbackData, invalidMac, key2);

        // Then
        assertFalse(isValid);
    }
}
```

### Integration Tests

```java

@SpringBootTest
@ActiveProfiles("test")
class PaymentCallbackIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private OrderRepository orderRepository;

    @Test
    void testCallbackFlow_Success() throws Exception {
        // Setup
        Order order = createAndSaveTestOrder();
        ZaloPayCallbackData callbackData = createValidCallback(order);

        // Execute
        mockMvc.perform(post("/api/payments/zalopay/callback")
                        .contentType(APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                Map.of("type", 1, "data", encodeData(callbackData),
                                        "mac", computeMac(callbackData)))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.return_code").value(1));

        // Verify
        Order updatedOrder = orderRepository.findById(order.getId())
                .orElseThrow();
        assertEquals(OrderStatus.COMPLETED, updatedOrder.getStatus());
    }
}
```

### Manual Testing

```bash
# 1. Create test order
curl -X POST http://localhost:8080/api/orders \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "eventId": "event_123",
    "ticketTypeId": "tt_456",
    "quantity": 1
  }'

# Response includes paymentUrl - go to that URL in browser

# 2. Test callback manually
ENCODED_DATA=$(echo '{"appTransId":"251223_order_123","zpTransId":"220000099877","amount":5000}' | base64)
MAC=$(echo "$ENCODED_DATA" | openssl dgst -sha256 -hmac "$ZALOPAY_KEY2" -hex | cut -d' ' -f2)

curl -X POST http://localhost:8080/api/payments/zalopay/callback \
  -H "Content-Type: application/json" \
  -d "{\"type\":1,\"data\":\"$ENCODED_DATA\",\"mac\":\"$MAC\"}"

# 3. Check reconciliation logs
tail -f logs/application.log | grep "reconciliation\|Payment reconciliation"
```

### Sandbox Testing Checklist

- [ ] Create test order with valid event/ticket
- [ ] Receive payment URL from ZaloPay
- [ ] Complete payment in ZaloPay sandbox
- [ ] Verify callback received within 5 seconds
- [ ] Confirm order status changed to COMPLETED
- [ ] Verify tickets activated
- [ ] Test refund initiation
- [ ] Verify reconciliation scheduler runs
- [ ] Test IP whitelist validation
- [ ] Test MAC verification with invalid signature

## Migration from Old System

If migrating from another payment system:

1. Create historical payment transactions
2. Reconcile existing orders with ZaloPay
3. Update callback URLs in ZaloPay dashboard
4. Run parallel testing (old + new system)
5. Switch to ZaloPay as primary
6. Monitor callbacks for 24 hours

## Performance Considerations

### Database Indexes

```sql
CREATE INDEX idx_pt_order ON payment_transactions (order_id);
CREATE INDEX idx_pt_app_trans_id ON payment_transactions (app_trans_id);
CREATE INDEX idx_pt_created ON payment_transactions (created_at);
CREATE INDEX idx_pal_app_trans_id ON payment_audit_logs (app_trans_id);
```

### API Response Times

- Order creation: <500ms (includes ZaloPay call)
- Callback processing: <200ms
- Refund initiation: <300ms
- Query status: <400ms

### Load Testing

```bash
# Test with Apache Bench
ab -n 1000 -c 10 -H "Authorization: Bearer $TOKEN" \
  http://localhost:8080/api/orders/callback

# Recommended limits
# - Callbacks: 1000+ per minute
# - Reconciliation: 10000+ concurrent orders
# - Refunds: 100+ per minute
```

## References

- [ZaloPay Documentation](https://docs.zalopay.vn)
- [ZaloPay Sandbox](https://sandbox.zalopay.vn)
- [Spring Boot RestTemplate Docs](https://docs.spring.io/spring-framework/docs/current/reference/html/integration.html#rest-client-access)
- [HMAC-SHA256 Java Implementation](https://docs.oracle.com/javase/8/docs/api/javax/crypto/Mac.html)

## Support

For issues related to:

- **ZaloPay API:** Contact ZaloPay Support
- **Integration:** See troubleshooting section above
- **Security:** Follow security considerations section
