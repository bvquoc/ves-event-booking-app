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
import java.util.HashMap;

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

        // Build signature data - MUST match exactly what's sent in request
        // Format: app_id|app_trans_id|app_user|amount|app_time|embed_data|item
        String signatureData = ZaloPaySignatureUtil.buildCreateOrderData(
                config.getAppId(),
                appTransId,
                appUser,
                order.getTotal(),
                appTime,
                embedData,
                item
        );

        // Generate MAC using key1
        String mac = ZaloPaySignatureUtil.generateSignature(signatureData, config.getKey1());

        // Verify signature data format matches request params exactly
        log.debug("Signature verification - AppId: {} (from config), AppTransId: {}, AppUser: {}, Amount: {}, AppTime: {}",
                config.getAppId(), appTransId, appUser, order.getTotal(), appTime);

        // Build request
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("app_id", config.getAppId());
        params.add("app_trans_id", appTransId);
        params.add("app_user", appUser);  // Use username instead of UUID
        params.add("amount", String.valueOf(order.getTotal()));
        params.add("app_time", String.valueOf(appTime));
        params.add("embed_data", embedData);
        params.add("item", item);
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
            HashMap<String, Object> itemObj = new HashMap<>();
            itemObj.put("name", order.getTicketType().getName());
            itemObj.put("quantity", order.getQuantity());
            itemObj.put("price", order.getTicketType().getPrice());

            Object[] itemArray = new Object[]{itemObj};
            String json = objectMapper.writeValueAsString(itemArray);
            log.debug("Item JSON: {}", json);
            return json;
        } catch (JsonProcessingException e) {
            log.error("Failed to build item JSON: {}", e.getMessage());
            return "[]";
        }
    }

    private String buildEmbedData(Order order) {
        try {
            // Build embed_data as per ZaloPay format
            // Format: {"orderId":"...", "eventId":"...", "redirecturl":"..."}
            HashMap<String, Object> embedDataObj = new HashMap<>();
            embedDataObj.put("orderId", order.getId());
            embedDataObj.put("eventId", order.getEvent().getId());
            embedDataObj.put("redirecturl", "https://ves-booking.io.vn/orders/" + order.getId());

            String json = objectMapper.writeValueAsString(embedDataObj);
            log.debug("EmbedData JSON: {}", json);
            return json;
        } catch (JsonProcessingException e) {
            log.error("Failed to build embed_data JSON: {}", e.getMessage());
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
