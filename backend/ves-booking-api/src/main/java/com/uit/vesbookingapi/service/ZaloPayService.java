package com.uit.vesbookingapi.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.uit.vesbookingapi.configuration.ZaloPayConfig;
import com.uit.vesbookingapi.dto.zalopay.ZaloPayCreateResponse;
import com.uit.vesbookingapi.dto.zalopay.ZaloPayQueryResponse;
import com.uit.vesbookingapi.dto.zalopay.ZaloPayRefundResponse;
import com.uit.vesbookingapi.entity.Order;
import com.uit.vesbookingapi.entity.PaymentAuditLog;
import com.uit.vesbookingapi.entity.PaymentTransaction;
import com.uit.vesbookingapi.entity.Refund;
import com.uit.vesbookingapi.enums.PaymentTransactionStatus;
import com.uit.vesbookingapi.enums.PaymentTransactionType;
import com.uit.vesbookingapi.repository.PaymentAuditLogRepository;
import com.uit.vesbookingapi.repository.PaymentTransactionRepository;
import com.uit.vesbookingapi.util.ZaloPaySignatureUtil;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class ZaloPayService {

    ZaloPayConfig config;
    RestTemplate restTemplate;
    PaymentTransactionRepository transactionRepository;
    PaymentAuditLogRepository auditLogRepository;
    ObjectMapper objectMapper;

    /**
     * Generate idempotent app_trans_id: YYMMDD_orderId
     */
    public String generateAppTransId(String orderId) {
        String datePart = LocalDate.now().format(DateTimeFormatter.ofPattern("yyMMdd"));
        return datePart + "_" + orderId;
    }

    /**
     * Create ZaloPay order and return payment URL
     */
    public ZaloPayCreateResponse createOrder(Order order) {
        long startTime = System.currentTimeMillis();
        String appTransId = generateAppTransId(order.getId());
        long appTime = System.currentTimeMillis();

        log.info("=== ZaloPay Create Order Request ===");
        log.info("OrderId={}, AppTransId={}, UserId={}, Username={}, EventId={}, EventName={}",
                order.getId(), appTransId, order.getUser().getId(), order.getUser().getUsername(),
                order.getEvent().getId(), order.getEvent().getName());
        log.info("TicketType={}, Quantity={}, Subtotal={}, Discount={}, Total={}, Currency={}",
                order.getTicketType().getName(), order.getQuantity(),
                order.getSubtotal(), order.getDiscount(), order.getTotal(), order.getCurrency());
        if (order.getVoucher() != null) {
            log.info("Voucher={}, VoucherCode={}", order.getVoucher().getId(), order.getVoucher().getCode());
        }

        // Build item JSON (simplified)
        String item = buildItemJson(order);

        // Build embed_data (for redirect after payment)
        String embedData = buildEmbedData(order);

        // Use username instead of UUID for app_user (ZaloPay requirement)
        String appUser = order.getUser().getUsername();

        // CRITICAL: Build signature data using EXACT values that will be sent in request
        // Format: app_id|app_trans_id|app_user|amount|app_time|embed_data|item
        // Following ZaloPay example code pattern:
        //   String data = app_id +"|"+ app_trans_id +"|"+ app_user +"|"+ amount +"|"+ app_time +"|"+ embed_data +"|"+ item;
        
        // Parse app_id as Integer to ensure it's valid, then convert to string
        Integer appIdInt = config.getAppIdAsInt();
        String appIdStr = String.valueOf(appIdInt);  // Int -> String

        // Convert amount and app_time to Long, then to string (matching example: System.currentTimeMillis() returns long)
        Long amountLong = Long.valueOf(order.getTotal());
        String amountStr = String.valueOf(amountLong);  // Long -> String

        Long appTimeLong = Long.valueOf(appTime);
        String appTimeStr = String.valueOf(appTimeLong);  // Long -> String

        // Build signature data exactly as ZaloPay example: app_id +"|"+ app_trans_id +"|"+ app_user +"|"+ amount +"|"+ app_time +"|"+ embed_data +"|"+ item
        // Using string concatenation to match example behavior (ensures exact toString() behavior)
        String signatureData = appIdStr + "|" + appTransId + "|" + appUser + "|" + amountStr + "|" + appTimeStr + "|" + embedData + "|" + item;

        // Generate MAC using key1
        // CRITICAL: The signature data string must match EXACTLY what ZaloPay receives
        // ZaloPay will URL-decode the form parameters before verifying the signature
        // Verify key1 is not null/empty
        if (config.getKey1() == null || config.getKey1().trim().isEmpty()) {
            log.error("ZaloPay key1 is null or empty! Check your configuration.");
            throw new RuntimeException("ZaloPay key1 is not configured");
        }

        // Get trimmed key1 (already trimmed in setter, but double-check)
        String key1 = config.getKey1().trim();

        // Log key1 info for debugging (without exposing full key)
        log.info("Using Key1: length={}, first10='{}...', last10='...{}'",
                key1.length(),
                key1.length() > 10 ? key1.substring(0, 10) : key1,
                key1.length() > 10 ? key1.substring(key1.length() - 10) : "");

        String mac = ZaloPaySignatureUtil.generateSignature(signatureData, key1);

        // Log signature components for debugging
        log.info("=== Signature Components ===");
        log.info("AppId: '{}' (Int: {}, length: {})", appIdStr, appIdInt, appIdStr.length());
        log.info("AppTransId: '{}' (length: {})", appTransId, appTransId.length());
        log.info("AppUser: '{}' (length: {})", appUser, appUser.length());
        log.info("Amount: '{}' (Long: {}, length: {})", amountStr, amountLong, amountStr.length());
        log.info("AppTime: '{}' (Long: {}, length: {})", appTimeStr, appTimeLong, appTimeStr.length());
        log.info("EmbedData: '{}' (length: {})", embedData, embedData.length());
        log.info("Item: '{}' (length: {})", item, item.length());
        log.info("Full Signature Data: '{}' (length: {})", signatureData, signatureData.length());
        log.info("Key1 (first 10 chars): '{}...' (length: {})",
                config.getKey1() != null && config.getKey1().length() > 10
                        ? config.getKey1().substring(0, 10) : config.getKey1(),
                config.getKey1() != null ? config.getKey1().length() : 0);
        log.info("Generated MAC: '{}' (length: {})", mac, mac.length());

        // Build request - ensure data types match ZaloPay expectations
        // Following example: params.add(new BasicNameValuePair(e.getKey(), e.getValue().toString()));
        // Form data is always sent as strings, but values must represent correct types
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("app_id", appIdStr);  // Int as string
        params.add("app_trans_id", appTransId);
        params.add("app_user", appUser);  // Use username instead of UUID
        params.add("amount", amountStr);  // Long as string
        params.add("app_time", appTimeStr);  // Long as string
        params.add("embed_data", embedData);  // JSON string
        params.add("item", item);  // JSON string
        params.add("description", "VES Booking - Order #" + order.getId());
        params.add("bank_code", "");  // Empty = show all banks
        params.add("callback_url", config.getCallbackUrl());
        params.add("mac", mac);

        log.info("ZaloPay Request Details: URL={}, AppId={}, AppTime={}, CallbackUrl={}",
                config.getCreateOrderUrl(), config.getAppId(), appTime, config.getCallbackUrl());
        log.info("AppUser={}, Amount={}, EmbedData={}, Item={}", appUser, order.getTotal(), embedData, item);
        log.info("SignatureData={}", signatureData);
        log.info("MAC={}", mac);
        log.debug("ZaloPay Request Params: {}", params);

        // Log request
        logAudit(order.getId(), appTransId, "CREATE_ORDER", null, params.toString());

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
            HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(params, headers);

            // Log the actual form data that will be sent (for debugging MAC issues)
            // Note: RestTemplate will URL-encode special characters in the values
            StringBuilder formData = new StringBuilder();
            params.forEach((key, values) -> {
                if (formData.length() > 0) formData.append("&");
                formData.append(key).append("=");
                if (values != null && !values.isEmpty()) {
                    // Show first value (will be URL-encoded by RestTemplate when sent)
                    String value = values.get(0);
                    // For JSON values, show both raw and what it will look like URL-encoded
                    if (key.equals("embed_data") || key.equals("item")) {
                        try {
                            String urlEncoded = java.net.URLEncoder.encode(value, java.nio.charset.StandardCharsets.UTF_8);
                            log.info("Form param {}: raw='{}', urlEncoded='{}'", key, value, urlEncoded);
                        } catch (Exception e) {
                            // Ignore
                        }
                    }
                    formData.append(value);
                }
            });
            log.info("Complete form data (before URL encoding): {}", formData.toString());

            log.info("Sending request to ZaloPay API...");
            ResponseEntity<ZaloPayCreateResponse> response = restTemplate.postForEntity(
                    config.getCreateOrderUrl(),
                    request,
                    ZaloPayCreateResponse.class
            );

            long duration = System.currentTimeMillis() - startTime;
            ZaloPayCreateResponse result = response.getBody();

            log.info("=== ZaloPay Create Order Response ===");
            log.info("OrderId={}, AppTransId={}, Duration={}ms", order.getId(), appTransId, duration);
            log.info("ReturnCode={}, ReturnMessage={}, SubReturnCode={}, SubReturnMessage={}",
                    result.getReturnCode(), result.getReturnMessage(),
                    result.getSubReturnCode(), result.getSubReturnMessage());
            log.info("OrderUrl={}, ZpTransToken={}, OrderToken={}",
                    result.getOrderUrl(), result.getZpTransToken(), result.getOrderToken());
            if (result.getQrCode() != null) {
                log.info("QrCode={}", result.getQrCode());
            }
            log.info("HTTP Status: {}", response.getStatusCode());

            // Save transaction record
            saveTransaction(order, appTransId, PaymentTransactionType.CREATE,
                    result.getReturnCode() == 1 ? PaymentTransactionStatus.SUCCESS : PaymentTransactionStatus.FAILED,
                    result.getReturnCode(), result.getReturnMessage(),
                    params.toString(), toJson(result));

            if (result.getReturnCode() != 1) {
                log.warn("ZaloPay returned non-success code: OrderId={}, AppTransId={}, ReturnCode={}, Message={}",
                        order.getId(), appTransId, result.getReturnCode(), result.getReturnMessage());
            }

            return result;

        } catch (Exception e) {
            long duration = System.currentTimeMillis() - startTime;
            log.error("=== ZaloPay Create Order Failed ===");
            log.error("OrderId={}, AppTransId={}, Duration={}ms", order.getId(), appTransId, duration);
            log.error("ErrorType={}, ErrorMessage={}", e.getClass().getSimpleName(), e.getMessage());
            log.error("Request URL={}, Request Params={}", config.getCreateOrderUrl(), params);
            log.error("Stack trace:", e);
            
            saveTransaction(order, appTransId, PaymentTransactionType.CREATE,
                    PaymentTransactionStatus.FAILED, -1, e.getMessage(),
                    params.toString(), null);
            throw new RuntimeException("Payment gateway error", e);
        }
    }

    /**
     * Query order status
     */
    public ZaloPayQueryResponse queryOrder(String appTransId) {
        long startTime = System.currentTimeMillis();
        String signatureData = config.getAppId() + "|" + appTransId + "|" + config.getKey1();
        String mac = ZaloPaySignatureUtil.generateSignature(signatureData, config.getKey1());

        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("app_id", config.getAppId());
        params.add("app_trans_id", appTransId);
        params.add("mac", mac);

        log.info("=== ZaloPay Query Order Request ===");
        log.info("AppTransId={}, AppId={}, URL={}", appTransId, config.getAppId(), config.getQueryUrl());
        log.debug("SignatureData={}, MAC={}", signatureData, mac);
        log.debug("Request Params: {}", params);

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
            HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(params, headers);

            ResponseEntity<ZaloPayQueryResponse> response = restTemplate.postForEntity(
                    config.getQueryUrl(),
                    request,
                    ZaloPayQueryResponse.class
            );

            long duration = System.currentTimeMillis() - startTime;
            ZaloPayQueryResponse result = response.getBody();

            log.info("=== ZaloPay Query Order Response ===");
            log.info("AppTransId={}, Duration={}ms, HTTP Status={}", appTransId, duration, response.getStatusCode());
            if (result != null) {
                log.info("ReturnCode={}, ReturnMessage={}, IsProcessing={}, Amount={}",
                        result.getReturnCode(), result.getReturnMessage(),
                        result.getIsProcessing(), result.getAmount());
                if (result.getZpTransId() != null) {
                    log.info("ZpTransId={}", result.getZpTransId());
                }
            } else {
                log.warn("ZaloPay query returned null response for AppTransId={}", appTransId);
            }

            return result;

        } catch (Exception e) {
            long duration = System.currentTimeMillis() - startTime;
            log.error("=== ZaloPay Query Order Failed ===");
            log.error("AppTransId={}, Duration={}ms", appTransId, duration);
            log.error("ErrorType={}, ErrorMessage={}", e.getClass().getSimpleName(), e.getMessage());
            log.error("Request URL={}, Request Params={}", config.getQueryUrl(), params);
            log.error("Stack trace:", e);
            throw new RuntimeException("Payment gateway query error", e);
        }
    }

    /**
     * Request refund
     */
    public ZaloPayRefundResponse refund(Refund refund) {
        long startTime = System.currentTimeMillis();
        long timestamp = System.currentTimeMillis();

        log.info("=== ZaloPay Refund Request ===");
        log.info("RefundId={}, MRefundId={}, TicketId={}, OrderId={}",
                refund.getId(), refund.getMRefundId(), refund.getTicket().getId(),
                refund.getTicket().getOrder().getId());
        log.info("ZpTransId={}, Amount={}, RefundStatus={}",
                refund.getZpTransId(), refund.getAmount(), refund.getStatus());

        String signatureData = String.join("|",
                config.getAppId(),
                refund.getZpTransId(),
                String.valueOf(refund.getAmount()),
                "Refund for ticket " + refund.getTicket().getId(),
                String.valueOf(timestamp)
        );
        String mac = ZaloPaySignatureUtil.generateSignature(signatureData, config.getKey1());

        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("app_id", config.getAppId());
        params.add("m_refund_id", refund.getMRefundId());
        params.add("zp_trans_id", refund.getZpTransId());
        params.add("amount", String.valueOf(refund.getAmount()));
        params.add("description", "Refund for ticket " + refund.getTicket().getId());
        params.add("timestamp", String.valueOf(timestamp));
        params.add("mac", mac);

        log.info("ZaloPay Refund Details: URL={}, AppId={}, Timestamp={}",
                config.getRefundUrl(), config.getAppId(), timestamp);
        log.debug("SignatureData={}, MAC={}", signatureData, mac);
        log.debug("Request Params: {}", params);

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
            HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(params, headers);

            ResponseEntity<ZaloPayRefundResponse> response = restTemplate.postForEntity(
                    config.getRefundUrl(),
                    request,
                    ZaloPayRefundResponse.class
            );

            long duration = System.currentTimeMillis() - startTime;
            ZaloPayRefundResponse result = response.getBody();

            log.info("=== ZaloPay Refund Response ===");
            log.info("RefundId={}, MRefundId={}, Duration={}ms, HTTP Status={}",
                    refund.getId(), refund.getMRefundId(), duration, response.getStatusCode());
            if (result != null) {
                log.info("ReturnCode={}, ReturnMessage={}, RefundId={}",
                        result.getReturnCode(), result.getReturnMessage(), result.getRefundId());
            } else {
                log.warn("ZaloPay refund returned null response for MRefundId={}", refund.getMRefundId());
            }

            return result;

        } catch (Exception e) {
            long duration = System.currentTimeMillis() - startTime;
            log.error("=== ZaloPay Refund Failed ===");
            log.error("RefundId={}, MRefundId={}, TicketId={}, Duration={}ms",
                    refund.getId(), refund.getMRefundId(), refund.getTicket().getId(), duration);
            log.error("ErrorType={}, ErrorMessage={}", e.getClass().getSimpleName(), e.getMessage());
            log.error("Request URL={}, Request Params={}", config.getRefundUrl(), params);
            log.error("Stack trace:", e);
            throw new RuntimeException("Payment gateway refund error", e);
        }
    }

    // Helper methods
    private String buildItemJson(Order order) {
        try {
            // Build item array as per ZaloPay format
            // Format: [{"name":"...", "quantity":..., "price":...}]
            // CRITICAL: Field order matters for signature - use LinkedHashMap
            java.util.LinkedHashMap<String, Object> itemObj = new java.util.LinkedHashMap<>();
            itemObj.put("name", order.getTicketType().getName());
            itemObj.put("quantity", order.getQuantity());
            itemObj.put("price", order.getTicketType().getPrice());

            Object[] itemArray = new Object[]{itemObj};
            // Use compact JSON (no pretty printing, no spaces) to match ZaloPay expectations
            // ObjectMapper by default produces compact JSON without spaces
            String json = objectMapper.writer().writeValueAsString(itemArray);
            log.debug("Item JSON: {}", json);
            return json;
        } catch (JsonProcessingException e) {
            log.error("Failed to build item JSON: {}", e.getMessage());
            // Fallback: return empty array
            return "[]";
        }
    }

    private String buildEmbedData(Order order) {
        try {
            // Build embed_data as per ZaloPay format
            // Format: {"orderId":"...", "eventId":"...", "redirecturl":"..."}
            // CRITICAL: Field order matters for signature - use LinkedHashMap
            java.util.LinkedHashMap<String, Object> embedDataObj = new java.util.LinkedHashMap<>();
            embedDataObj.put("orderId", order.getId());
            embedDataObj.put("eventId", order.getEvent().getId());
            embedDataObj.put("redirecturl", "https://ves-booking.io.vn/orders/" + order.getId());

            // Use compact JSON (no pretty printing, no spaces) to match ZaloPay expectations
            String json = objectMapper.writer().writeValueAsString(embedDataObj);
            log.debug("EmbedData JSON: {}", json);
            return json;
        } catch (JsonProcessingException e) {
            log.error("Failed to build embed_data JSON: {}", e.getMessage());
            // Fallback: return empty object
            return "{}";
        }
    }

    private void saveTransaction(Order order, String appTransId,
                                 PaymentTransactionType type, PaymentTransactionStatus status,
                                 Integer returnCode, String returnMessage,
                                 String requestPayload, String responsePayload) {
        PaymentTransaction tx = PaymentTransaction.builder()
                .order(order)
                .appTransId(appTransId)
                .type(type)
                .status(status)
                .amount(order.getTotal())
                .returnCode(returnCode)
                .returnMessage(returnMessage)
                .requestPayload(requestPayload)
                .responsePayload(responsePayload)
                .build();
        transactionRepository.save(tx);
    }

    private void logAudit(String orderId, String appTransId, String action,
                          String ipAddress, String payload) {
        PaymentAuditLog log = PaymentAuditLog.builder()
                .orderId(orderId)
                .appTransId(appTransId)
                .action(action)
                .ipAddress(ipAddress)
                .payload(payload)
                .build();
        auditLogRepository.save(log);
    }

    private String toJson(Object obj) {
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            return "{}";
        }
    }
}
