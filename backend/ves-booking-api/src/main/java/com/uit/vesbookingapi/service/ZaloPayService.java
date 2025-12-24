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
import com.uit.vesbookingapi.util.zalopay.crypto.HMACUtil;
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
     * Following ZaloPay official example pattern
     */
    public ZaloPayCreateResponse createOrder(Order order) {
        long startTime = System.currentTimeMillis();
        String appTransId = generateAppTransId(order.getId());
        long appTime = System.currentTimeMillis();

        log.info("Creating ZaloPay order: orderId={}, appTransId={}, amount={}, user={}",
                order.getId(), appTransId, order.getTotal(), order.getUser().getUsername());

        // Build JSON data
        String item = buildItemJson(order);
        String embedData = buildEmbedData(order);
        String appUser = order.getUser().getUsername();

        // Build order map following ZaloPay example pattern
        String appIdStr = String.valueOf(config.getAppIdAsInt());
        String amountStr = String.valueOf(order.getTotal());
        String appTimeStr = String.valueOf(appTime);

        // Build signature data exactly as ZaloPay example: app_id|app_trans_id|app_user|amount|app_time|embed_data|item
        String signatureData = appIdStr + "|" + appTransId + "|" + appUser + "|" +
                amountStr + "|" + appTimeStr + "|" + embedData + "|" + item;

        // Generate MAC using official ZaloPay HMACUtil (exactly as example)
        String key1 = validateAndGetKey1();
        String mac = HMACUtil.HMacHexStringEncode(HMACUtil.HMACSHA256, key1, signatureData);
        log.debug("Signature data: {}, MAC: {}", signatureData, mac);

        // Build request params
        MultiValueMap<String, String> params = buildCreateOrderParams(
                appIdStr, appTransId, appUser, amountStr, appTimeStr, embedData, item, mac, order);

        logAudit(order.getId(), appTransId, "CREATE_ORDER", null, params.toString());

        try {
            ResponseEntity<ZaloPayCreateResponse> response = sendRequest(
                    config.getCreateOrderUrl(), params, ZaloPayCreateResponse.class);

            long duration = System.currentTimeMillis() - startTime;
            ZaloPayCreateResponse result = response.getBody();

            log.info("ZaloPay create order response: orderId={}, appTransId={}, returnCode={}, duration={}ms",
                    order.getId(), appTransId,
                    result != null ? result.getReturnCode() : null, duration);

            if (result != null) {
                saveTransaction(order, appTransId, PaymentTransactionType.CREATE,
                        result.getReturnCode() == 1 ? PaymentTransactionStatus.SUCCESS : PaymentTransactionStatus.FAILED,
                        result.getReturnCode(), result.getReturnMessage(),
                        params.toString(), toJson(result));

                if (result.getReturnCode() != 1) {
                    log.warn("ZaloPay create order failed: orderId={}, returnCode={}, message={}",
                            order.getId(), result.getReturnCode(), result.getReturnMessage());
                }
            }

            return result;

        } catch (Exception e) {
            long duration = System.currentTimeMillis() - startTime;
            log.error("ZaloPay create order error: orderId={}, appTransId={}, duration={}ms, error={}",
                    order.getId(), appTransId, duration, e.getMessage(), e);
            
            saveTransaction(order, appTransId, PaymentTransactionType.CREATE,
                    PaymentTransactionStatus.FAILED, -1, e.getMessage(), params.toString(), null);
            throw new RuntimeException("Payment gateway error", e);
        }
    }

    /**
     * Query order status
     */
    public ZaloPayQueryResponse queryOrder(String appTransId) {
        long startTime = System.currentTimeMillis();
        String key1 = validateAndGetKey1();
        // Query signature format: app_id|app_trans_id|key1
        String signatureData = config.getAppId() + "|" + appTransId + "|" + key1;
        String mac = HMACUtil.HMacHexStringEncode(HMACUtil.HMACSHA256, key1, signatureData);

        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("app_id", config.getAppId());
        params.add("app_trans_id", appTransId);
        params.add("mac", mac);

        log.info("Querying ZaloPay order: appTransId={}", appTransId);

        try {
            ResponseEntity<ZaloPayQueryResponse> response = sendRequest(
                    config.getQueryUrl(), params, ZaloPayQueryResponse.class);

            long duration = System.currentTimeMillis() - startTime;
            ZaloPayQueryResponse result = response.getBody();

            log.info("ZaloPay query response: appTransId={}, returnCode={}, duration={}ms",
                    appTransId, result != null ? result.getReturnCode() : null, duration);

            return result;

        } catch (Exception e) {
            long duration = System.currentTimeMillis() - startTime;
            log.error("ZaloPay query error: appTransId={}, duration={}ms, error={}",
                    appTransId, duration, e.getMessage(), e);
            throw new RuntimeException("Payment gateway query error", e);
        }
    }

    /**
     * Request refund
     */
    public ZaloPayRefundResponse refund(Refund refund) {
        long startTime = System.currentTimeMillis();
        long timestamp = System.currentTimeMillis();

        log.info("Processing ZaloPay refund: refundId={}, mRefundId={}, amount={}, ticketId={}",
                refund.getId(), refund.getMRefundId(), refund.getAmount(), refund.getTicket().getId());

        String description = "Refund for ticket " + refund.getTicket().getId();
        // Refund signature format: app_id|zp_trans_id|amount|description|timestamp
        String signatureData = String.join("|",
                config.getAppId(),
                refund.getZpTransId(),
                String.valueOf(refund.getAmount()),
                description,
                String.valueOf(timestamp)
        );
        String key1 = validateAndGetKey1();
        String mac = HMACUtil.HMacHexStringEncode(HMACUtil.HMACSHA256, key1, signatureData);

        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("app_id", config.getAppId());
        params.add("m_refund_id", refund.getMRefundId());
        params.add("zp_trans_id", refund.getZpTransId());
        params.add("amount", String.valueOf(refund.getAmount()));
        params.add("description", description);
        params.add("timestamp", String.valueOf(timestamp));
        params.add("mac", mac);

        try {
            ResponseEntity<ZaloPayRefundResponse> response = sendRequest(
                    config.getRefundUrl(), params, ZaloPayRefundResponse.class);

            long duration = System.currentTimeMillis() - startTime;
            ZaloPayRefundResponse result = response.getBody();

            log.info("ZaloPay refund response: refundId={}, returnCode={}, duration={}ms",
                    refund.getId(), result != null ? result.getReturnCode() : null, duration);

            return result;

        } catch (Exception e) {
            long duration = System.currentTimeMillis() - startTime;
            log.error("ZaloPay refund error: refundId={}, duration={}ms, error={}",
                    refund.getId(), duration, e.getMessage(), e);
            throw new RuntimeException("Payment gateway refund error", e);
        }
    }

    // Helper methods
    private String validateAndGetKey1() {
        if (config.getKey1() == null || config.getKey1().trim().isEmpty()) {
            throw new RuntimeException("ZaloPay key1 is not configured");
        }
        return config.getKey1().trim();
    }

    private <T> ResponseEntity<T> sendRequest(String url, MultiValueMap<String, String> params, Class<T> responseType) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(params, headers);
        return restTemplate.postForEntity(url, request, responseType);
    }

    private MultiValueMap<String, String> buildCreateOrderParams(
            String appId, String appTransId, String appUser, String amount, String appTime,
            String embedData, String item, String mac, Order order) {
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("app_id", appId);
        params.add("app_trans_id", appTransId);
        params.add("app_user", appUser);
        params.add("amount", amount);
        params.add("app_time", appTime);
        params.add("embed_data", embedData);
        params.add("item", item);
        params.add("description", "VES Booking - Order #" + order.getId());
        params.add("bank_code", "");
        params.add("callback_url", config.getCallbackUrl());

        // Optional parameters (as per ZaloPay API documentation)
        if (order.getCurrency() != null) {
            params.add("currency", order.getCurrency());
        }
        if (order.getUser().getPhone() != null && !order.getUser().getPhone().isEmpty()) {
            params.add("phone", order.getUser().getPhone());
        }

        params.add("mac", mac);
        return params;
    }

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
