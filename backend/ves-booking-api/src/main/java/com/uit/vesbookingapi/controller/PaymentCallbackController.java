package com.uit.vesbookingapi.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.uit.vesbookingapi.configuration.ZaloPayConfig;
import com.uit.vesbookingapi.dto.zalopay.ZaloPayCallbackData;
import com.uit.vesbookingapi.service.PaymentCallbackService;
import com.uit.vesbookingapi.util.zalopay.crypto.HMACUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/payments/zalopay")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class PaymentCallbackController {

    PaymentCallbackService callbackService;
    ZaloPayConfig zaloPayConfig;
    ObjectMapper objectMapper;

    // List of allowed ZaloPay IPs (update from ZaloPay docs)
    private static final String[] ALLOWED_IPS = {
            "113.20.108.14",  // ZaloPay production
            "113.20.108.15",
            "118.69.77.70",   // ZaloPay sandbox
            "127.0.0.1"       // Local testing
    };

    /**
     * ZaloPay callback endpoint
     * POST /api/payments/zalopay/callback
     */
    @PostMapping("/callback")
    public ResponseEntity<Map<String, Object>> handleCallback(
            @RequestBody Map<String, Object> payload,
            HttpServletRequest request
    ) {
        String clientIp = getClientIp(request);
        log.info("ZaloPay callback received from IP: {}", clientIp);

        Map<String, Object> result = new HashMap<>();

        try {
            // 1. Validate IP whitelist (optional in sandbox)
            if (!isIpAllowed(clientIp)) {
                log.warn("Callback from unauthorized IP: {}", clientIp);
                // Don't reject in sandbox, just log warning
            }

            // 2. Extract and verify signature
            String data = (String) payload.get("data");
            String mac = (String) payload.get("mac");
            Integer type = (Integer) payload.get("type");

            log.debug("Callback data: {}, type: {}", data, type);

            // Verify MAC using key2 (callback uses key2, not key1)
            String computedMac = HMACUtil.HMacHexStringEncode(HMACUtil.HMACSHA256, zaloPayConfig.getKey2(), data);
            if (!computedMac.equalsIgnoreCase(mac)) {
                log.error("Invalid callback MAC. Expected: {}, Got: {}", computedMac, mac);
                result.put("return_code", -1);
                result.put("return_message", "Invalid MAC");
                return ResponseEntity.ok(result);
            }

            // 3. Parse callback data
            ZaloPayCallbackData callbackData = objectMapper.readValue(data, ZaloPayCallbackData.class);

            // 4. Process callback
            callbackService.processPaymentCallback(callbackData, clientIp);

            // 5. Return success to ZaloPay
            result.put("return_code", 1);
            result.put("return_message", "success");

            log.info("Callback processed successfully: appTransId={}", callbackData.getAppTransId());

        } catch (Exception e) {
            log.error("Callback processing error: {}", e.getMessage(), e);
            result.put("return_code", 0);
            result.put("return_message", "Processing error: " + e.getMessage());
        }

        return ResponseEntity.ok(result);
    }

    /**
     * Refund callback endpoint
     * POST /api/payments/zalopay/refund-callback
     */
    @PostMapping("/refund-callback")
    public ResponseEntity<Map<String, Object>> handleRefundCallback(
            @RequestBody Map<String, Object> payload,
            HttpServletRequest request
    ) {
        String clientIp = getClientIp(request);
        log.info("ZaloPay refund callback received from IP: {}", clientIp);

        Map<String, Object> result = new HashMap<>();

        try {
            String data = (String) payload.get("data");
            String mac = (String) payload.get("mac");

            // Verify MAC using key2 (refund callback uses key2)
            String computedMac = HMACUtil.HMacHexStringEncode(HMACUtil.HMACSHA256, zaloPayConfig.getKey2(), data);
            if (!computedMac.equalsIgnoreCase(mac)) {
                log.error("Invalid refund callback MAC");
                result.put("return_code", -1);
                result.put("return_message", "Invalid MAC");
                return ResponseEntity.ok(result);
            }

            // Process refund callback
            callbackService.processRefundCallback(data, clientIp);

            result.put("return_code", 1);
            result.put("return_message", "success");

        } catch (Exception e) {
            log.error("Refund callback error: {}", e.getMessage(), e);
            result.put("return_code", 0);
            result.put("return_message", "Error");
        }

        return ResponseEntity.ok(result);
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty()) {
            ip = request.getRemoteAddr();
        } else {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }

    private boolean isIpAllowed(String ip) {
        for (String allowed : ALLOWED_IPS) {
            if (allowed.equals(ip)) return true;
        }
        return false;
    }
}
