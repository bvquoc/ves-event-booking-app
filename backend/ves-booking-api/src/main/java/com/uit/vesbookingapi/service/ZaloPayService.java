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
        String appTransId = generateAppTransId(order.getId());
        long appTime = System.currentTimeMillis();

        // Build item JSON (simplified)
        String item = buildItemJson(order);

        // Build embed_data (for redirect after payment)
        String embedData = buildEmbedData(order);

        // Build signature data
        String signatureData = ZaloPaySignatureUtil.buildCreateOrderData(
                config.getAppId(),
                appTransId,
                order.getUser().getId(),
                order.getTotal(),
                appTime,
                embedData,
                item
        );

        String mac = ZaloPaySignatureUtil.generateSignature(signatureData, config.getKey1());

        // Build request
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("app_id", config.getAppId());
        params.add("app_trans_id", appTransId);
        params.add("app_user", order.getUser().getId());
        params.add("amount", String.valueOf(order.getTotal()));
        params.add("app_time", String.valueOf(appTime));
        params.add("embed_data", embedData);
        params.add("item", item);
        params.add("description", "VES Booking - Order #" + order.getId());
        params.add("bank_code", "");  // Empty = show all banks
        params.add("callback_url", config.getCallbackUrl());
        params.add("mac", mac);

        log.info("Creating ZaloPay order: appTransId={}, amount={}", appTransId, order.getTotal());

        // Log request
        logAudit(order.getId(), appTransId, "CREATE_ORDER", null, params.toString());

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
            HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(params, headers);

            ResponseEntity<ZaloPayCreateResponse> response = restTemplate.postForEntity(
                    config.getCreateOrderUrl(),
                    request,
                    ZaloPayCreateResponse.class
            );

            ZaloPayCreateResponse result = response.getBody();
            log.info("ZaloPay response: returnCode={}, orderUrl={}",
                    result.getReturnCode(), result.getOrderUrl());

            // Save transaction record
            saveTransaction(order, appTransId, PaymentTransactionType.CREATE,
                    result.getReturnCode() == 1 ? PaymentTransactionStatus.SUCCESS : PaymentTransactionStatus.FAILED,
                    result.getReturnCode(), result.getReturnMessage(),
                    params.toString(), toJson(result));

            return result;

        } catch (Exception e) {
            log.error("ZaloPay create order failed: {}", e.getMessage(), e);
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
        String signatureData = config.getAppId() + "|" + appTransId + "|" + config.getKey1();
        String mac = ZaloPaySignatureUtil.generateSignature(signatureData, config.getKey1());

        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("app_id", config.getAppId());
        params.add("app_trans_id", appTransId);
        params.add("mac", mac);

        log.info("Querying ZaloPay order: appTransId={}", appTransId);

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
            HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(params, headers);

            ResponseEntity<ZaloPayQueryResponse> response = restTemplate.postForEntity(
                    config.getQueryUrl(),
                    request,
                    ZaloPayQueryResponse.class
            );

            return response.getBody();

        } catch (Exception e) {
            log.error("ZaloPay query failed: appTransId={}, error={}", appTransId, e.getMessage());
            throw new RuntimeException("Payment gateway query error", e);
        }
    }

    /**
     * Request refund
     */
    public ZaloPayRefundResponse refund(Refund refund) {
        long timestamp = System.currentTimeMillis();

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

        log.info("Requesting ZaloPay refund: mRefundId={}, amount={}",
                refund.getMRefundId(), refund.getAmount());

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
            HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(params, headers);

            ResponseEntity<ZaloPayRefundResponse> response = restTemplate.postForEntity(
                    config.getRefundUrl(),
                    request,
                    ZaloPayRefundResponse.class
            );

            return response.getBody();

        } catch (Exception e) {
            log.error("ZaloPay refund failed: mRefundId={}, error={}",
                    refund.getMRefundId(), e.getMessage());
            throw new RuntimeException("Payment gateway refund error", e);
        }
    }

    // Helper methods
    private String buildItemJson(Order order) {
        try {
            return objectMapper.writeValueAsString(new Object[]{
                    new HashMap<String, Object>() {{
                        put("name", order.getTicketType().getName());
                        put("quantity", order.getQuantity());
                        put("price", order.getTicketType().getPrice());
                    }}
            });
        } catch (JsonProcessingException e) {
            return "[]";
        }
    }

    private String buildEmbedData(Order order) {
        try {
            return objectMapper.writeValueAsString(new HashMap<String, Object>() {{
                put("orderId", order.getId());
                put("eventId", order.getEvent().getId());
                put("redirecturl", "https://ves-booking.io.vn/orders/" + order.getId());
            }});
        } catch (JsonProcessingException e) {
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
