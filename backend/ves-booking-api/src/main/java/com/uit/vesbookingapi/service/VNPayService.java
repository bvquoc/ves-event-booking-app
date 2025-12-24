package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.configuration.VNPayConfig;
import com.uit.vesbookingapi.dto.vnpay.VNPayPaymentResponse;
import com.uit.vesbookingapi.entity.Order;
import com.uit.vesbookingapi.util.VNPaySignatureUtil;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * VNPay payment service
 * Following VNPay example implementation pattern from VNPAY-Payment-Integrate-on-Spring-Boot-3
 */
@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class VNPayService {

    VNPayConfig config;

    /**
     * Generate payment URL for VNPay
     * Following the example implementation pattern exactly
     */
    public VNPayPaymentResponse createPaymentUrl(Order order, String clientIp) {
        try {
            log.info("Creating VNPay payment URL: orderId={}, amount={}, user={}, clientIp={}",
                    order.getId(), order.getTotal(), order.getUser().getUsername(), clientIp);

            // Generate transaction reference (must be unique per day)
            String vnpTxnRef = generateTxnRef(order.getId());
            log.debug("Generated vnpTxnRef: {}", vnpTxnRef);

            // Amount: multiply by 100 to remove decimals (VNPay requirement)
            long vnpAmount = order.getTotal() * 100L;
            log.debug("Amount calculation: {} * 100 = {}", order.getTotal(), vnpAmount);

            // Build order info
            String vnpOrderInfo = "Thanh toan don hang:" + vnpTxnRef;

            // Build parameters map (matching example pattern)
            Map<String, Object> payload = new HashMap<>();
            payload.put("vnp_Version", config.getVersion());
            payload.put("vnp_Command", "pay");
            payload.put("vnp_TmnCode", config.getTmnCode());
            payload.put("vnp_Amount", String.valueOf(vnpAmount));
            payload.put("vnp_CurrCode", config.getCurrency());
            payload.put("vnp_TxnRef", vnpTxnRef);
            payload.put("vnp_OrderInfo", vnpOrderInfo);
            payload.put("vnp_OrderType", "other");
            payload.put("vnp_Locale", config.getLocale());
            payload.put("vnp_ReturnUrl", config.getReturnUrl());
            payload.put("vnp_IpAddr", clientIp);
            payload.put("vnp_CreateDate", generateDate(false));
            payload.put("vnp_ExpireDate", generateDate(true));

            // Build query URL and hash data (matching example pattern exactly)
            Map<String, String> queryResult = getQueryUrl(payload);
            String queryUrl = queryResult.get("queryUrl");
            String hashData = queryResult.get("hashData");

            log.debug("Hash data for signature: {}", hashData);

            // Generate secure hash using hash data (with URL-encoded values)
            String vnpSecureHash = VNPaySignatureUtil.hmacSHA512(config.getHashSecret(), hashData);
            log.debug("Generated secure hash: {}", vnpSecureHash);

            // Build final payment URL
            String finalQueryUrl = queryUrl + "&vnp_SecureHash=" + vnpSecureHash;
            String paymentUrl = config.getPayUrl() + "?" + finalQueryUrl;

            log.info("VNPay payment URL generated: orderId={}, txnRef={}, amount={}",
                    order.getId(), vnpTxnRef, vnpAmount);

            return VNPayPaymentResponse.builder()
                    .paymentUrl(paymentUrl)
                    .build();

        } catch (UnsupportedEncodingException e) {
            log.error("Failed to create VNPay payment URL: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to create VNPay payment URL", e);
        }
    }

    /**
     * Build query URL and hash data (matching example implementation exactly)
     * Hash data uses URL-encoded values, query URL also uses URL-encoded values
     */
    private Map<String, String> getQueryUrl(Map<String, Object> payload) throws UnsupportedEncodingException {
        List<String> fieldNames = new ArrayList<>(payload.keySet());
        Collections.sort(fieldNames);

        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();

        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = (String) payload.get(fieldName);
            if (fieldValue != null && fieldValue.length() > 0) {
                // Build hash data with URL-encoded values (matching example)
                hashData.append(fieldName);
                hashData.append('=');
                hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));

                // Build query with URL-encoded values
                query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString()));
                query.append('=');
                query.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));

                if (itr.hasNext()) {
                    query.append('&');
                    hashData.append('&');
                }
            }
        }

        return new HashMap<>() {{
            put("queryUrl", query.toString());
            put("hashData", hashData.toString());
        }};
    }

    /**
     * Generate date string (matching example implementation)
     */
    private String generateDate(boolean forExpire) {
        Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");

        if (!forExpire) {
            return formatter.format(cld.getTime());
        }

        cld.add(Calendar.MINUTE, config.getPaymentTimeoutMinutes());
        return formatter.format(cld.getTime());
    }

    /**
     * Generate transaction reference (must be unique per day)
     * Format: random 8-digit number (matching example pattern)
     */
    private String generateTxnRef(String orderId) {
        // Use random number like example, but ensure uniqueness by including orderId
        // VNPay requires max 100 chars, unique per day
        // For simplicity, use orderId (UUID is unique)
        // Alternative: return VNPaySignatureUtil.getRandomNumber(8) if needed
        return orderId;
    }

    /**
     * Verify VNPay callback signature
     */
    public boolean verifySignature(Map<String, String> params, String secureHash) {
        return VNPaySignatureUtil.verifySignature(params, secureHash, config.getHashSecret());
    }
}

