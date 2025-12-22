package com.uit.vesbookingapi.payment.zalopay;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.uit.vesbookingapi.entity.Order;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import com.uit.vesbookingapi.payment.zalopay.dto.*;
import com.uit.vesbookingapi.payment.zalopay.util.ZaloPaySignatureUtil;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class ZaloPayService {
    ZaloPayConfig zaloPayConfig;
    ZaloPaySignatureUtil signatureUtil;
    WebClient webClient;
    ObjectMapper objectMapper;

    public ZaloPayService(ZaloPayConfig zaloPayConfig, ZaloPaySignatureUtil signatureUtil, ObjectMapper objectMapper) {
        this.zaloPayConfig = zaloPayConfig;
        this.signatureUtil = signatureUtil;
        this.objectMapper = objectMapper;
        this.webClient = WebClient.builder().build();
    }

    /**
     * Create payment order with ZaloPay
     * @param order Internal order entity
     * @return ZaloPayCreateOrderResponse containing orderUrl and transaction info
     */
    public ZaloPayCreateOrderResponse createPaymentOrder(Order order) {
        try {
            String appId = zaloPayConfig.getAppId();
            String key1 = zaloPayConfig.getKey1();
            long appTime = System.currentTimeMillis();
            
            // Format: YYMMDD + orderId (max 20 chars)
            String appTransId = generateAppTransIdFromOrderId(order.getId());
            String appUser = order.getUser().getUsername();
            long amount = order.getTotal().longValue();
            String description = String.format("Thanh toan don hang %s", order.getId());
            String item = String.format("[{\"itemid\":\"%s\",\"itemname\":\"Ve su kien\",\"itemprice\":%d,\"itemquantity\":%d}]",
                    order.getEvent().getId(), order.getTicketType().getPrice(), order.getQuantity());
            String embedData = "{}";

            // Create signature
            String data = String.format("%s|%s|%s|%d|%d|%s|%s",
                    appId, appTransId, appUser, amount, appTime, embedData, item);
            String mac = signatureUtil.createSignature(data, key1);

            // Build request
            ZaloPayCreateOrderRequest request = ZaloPayCreateOrderRequest.builder()
                    .appId(appId)
                    .appUser(appUser)
                    .appTime(appTime)
                    .amount(amount)
                    .appTransId(appTransId)
                    .description(description)
                    .item(item)
                    .embedData(embedData)
                    .mac(mac)
                    .build();

            log.info("Creating ZaloPay order: appTransId={}, amount={}", appTransId, amount);

            // Call ZaloPay API
            ZaloPayCreateOrderResponse response = webClient.post()
                    .uri(zaloPayConfig.getCreateOrderEndpoint())
                    .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                    .body(BodyInserters.fromFormData(buildFormData(request)))
                    .retrieve()
                    .bodyToMono(ZaloPayCreateOrderResponse.class)
                    .block();

            if (response == null || response.getReturnCode() == null || response.getReturnCode() != 1) {
                log.error("ZaloPay create order failed: returnCode={}, message={}",
                        response != null ? response.getReturnCode() : null,
                        response != null ? response.getReturnMessage() : "No response");
                throw new AppException(ErrorCode.UNCATEGORIZED_EXCEPTION);
            }

            log.info("ZaloPay order created successfully: orderUrl={}, zpTransId={}, appTransId={}",
                    response.getOrderUrl(), response.getZpTransId(), appTransId);

            return response;

        } catch (AppException e) {
            throw e;
        } catch (Exception e) {
            log.error("Error creating ZaloPay order", e);
            throw new AppException(ErrorCode.UNCATEGORIZED_EXCEPTION);
        }
    }

    /**
     * Verify and process ZaloPay callback
     * @param callbackRequest Callback data from ZaloPay
     * @return true if valid, false otherwise
     */
    public boolean verifyCallback(ZaloPayCallbackRequest callbackRequest) {
        try {
            String key2 = zaloPayConfig.getKey2();
            
            // Create signature for verification
            String data = String.format("%s|%s|%s|%s|%d|%d|%d",
                    callbackRequest.getAppId(),
                    callbackRequest.getAppTransId(),
                    callbackRequest.getPmcid() != null ? callbackRequest.getPmcid().toString() : "",
                    callbackRequest.getBankCode() != null ? callbackRequest.getBankCode() : "",
                    callbackRequest.getAmount(),
                    callbackRequest.getDiscountAmount() != null ? callbackRequest.getDiscountAmount() : 0,
                    callbackRequest.getStatus());

            boolean isValid = signatureUtil.verifySignature(data, key2, callbackRequest.getMac());
            
            if (isValid) {
                log.info("ZaloPay callback verified: appTransId={}, status={}, amount={}",
                        callbackRequest.getAppTransId(), callbackRequest.getStatus(), callbackRequest.getAmount());
            } else {
                log.warn("ZaloPay callback signature invalid: appTransId={}", callbackRequest.getAppTransId());
            }
            
            return isValid;
        } catch (Exception e) {
            log.error("Error verifying ZaloPay callback", e);
            return false;
        }
    }

    /**
     * Query payment status from ZaloPay
     * @param appTransId ZaloPay transaction ID (from order)
     * @return Payment status response
     */
    public ZaloPayQueryStatusResponse queryPaymentStatus(String appTransId) {
        try {
            String appId = zaloPayConfig.getAppId();
            String key1 = zaloPayConfig.getKey1();

            // Create signature
            String data = String.format("%s|%s", appId, appTransId);
            String mac = signatureUtil.createSignature(data, key1);

            ZaloPayQueryStatusRequest request = ZaloPayQueryStatusRequest.builder()
                    .appId(appId)
                    .appTransId(appTransId)
                    .mac(mac)
                    .build();

            ZaloPayQueryStatusResponse response = webClient.post()
                    .uri(zaloPayConfig.getQueryStatusUrl())
                    .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                    .body(BodyInserters.fromFormData(buildQueryStatusFormData(request)))
                    .retrieve()
                    .bodyToMono(ZaloPayQueryStatusResponse.class)
                    .block();

            return response;

        } catch (Exception e) {
            log.error("Error querying ZaloPay payment status", e);
            throw new AppException(ErrorCode.UNCATEGORIZED_EXCEPTION);
        }
    }


    /**
     * Generate app_trans_id from order ID
     * Format: YYMMDD + orderId (without dashes, max 20 chars total)
     * This is stored in order.zalopayTransactionId for callback lookup
     */
    public String generateAppTransIdFromOrderId(String orderId) {
        String datePrefix = DateTimeFormatter.ofPattern("yyMMdd")
                .format(Instant.now().atZone(ZoneId.of("Asia/Ho_Chi_Minh")));
        String suffix = orderId.replace("-", "");
        // ZaloPay requires max 20 chars, datePrefix is 6, so suffix max 14
        if (suffix.length() > 14) {
            suffix = suffix.substring(0, 14);
        }
        return datePrefix + suffix;
    }

    private Map<String, String> buildFormData(ZaloPayCreateOrderRequest request) {
        Map<String, String> formData = new HashMap<>();
        formData.put("app_id", request.getAppId());
        formData.put("app_user", request.getAppUser());
        formData.put("app_time", String.valueOf(request.getAppTime()));
        formData.put("amount", String.valueOf(request.getAmount()));
        formData.put("app_trans_id", request.getAppTransId());
        formData.put("description", request.getDescription());
        formData.put("item", request.getItem());
        formData.put("embed_data", request.getEmbedData());
        formData.put("mac", request.getMac());
        if (request.getBankCode() != null) {
            formData.put("bank_code", request.getBankCode());
        }
        return formData;
    }

    private Map<String, String> buildQueryStatusFormData(ZaloPayQueryStatusRequest request) {
        Map<String, String> formData = new HashMap<>();
        formData.put("app_id", request.getAppId());
        formData.put("app_trans_id", request.getAppTransId());
        formData.put("mac", request.getMac());
        return formData;
    }
}

