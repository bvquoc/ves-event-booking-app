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

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * VNPay payment service
 * Following VNPay official documentation pattern
 */
@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class VNPayService {

    VNPayConfig config;

    /**
     * Generate payment URL for VNPay
     * Following VNPay documentation: https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
     */
    public VNPayPaymentResponse createPaymentUrl(Order order, String clientIp) {
        log.info("Creating VNPay payment URL: orderId={}, amount={}, user={}",
                order.getId(), order.getTotal(), order.getUser().getUsername());

        // Generate transaction reference (must be unique per day)
        String vnpTxnRef = generateTxnRef(order.getId());

        // Amount: multiply by 100 to remove decimals (VNPay requirement)
        long vnpAmount = order.getTotal() * 100L;

        // Create date and expire date (GMT+7)
        Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        String vnpCreateDate = formatter.format(cal.getTime());
        cal.add(Calendar.MINUTE, config.getPaymentTimeoutMinutes());
        String vnpExpireDate = formatter.format(cal.getTime());

        // Build order info (no Vietnamese accents, no special chars)
        String vnpOrderInfo = buildOrderInfo(order);

        // Build parameters map
        Map<String, String> vnpParams = new HashMap<>();
        vnpParams.put("vnp_Version", config.getVersion());
        vnpParams.put("vnp_Command", "pay");
        vnpParams.put("vnp_TmnCode", config.getTmnCode());
        vnpParams.put("vnp_Amount", String.valueOf(vnpAmount));
        vnpParams.put("vnp_CurrCode", config.getCurrency());
        vnpParams.put("vnp_TxnRef", vnpTxnRef);
        vnpParams.put("vnp_OrderInfo", vnpOrderInfo);
        vnpParams.put("vnp_OrderType", "other");  // Default order type
        vnpParams.put("vnp_Locale", config.getLocale());
        vnpParams.put("vnp_ReturnUrl", config.getReturnUrl());
        vnpParams.put("vnp_IpAddr", clientIp);
        vnpParams.put("vnp_CreateDate", vnpCreateDate);
        vnpParams.put("vnp_ExpireDate", vnpExpireDate);
        // vnp_BankCode is optional - omit to let user choose

        // Build hash data (sorted alphabetically, URL-encoded values) for signature
        // IMPORTANT: Hash data must use URL-encoded values (as per VNPay example)
        String hashData = VNPaySignatureUtil.buildHashData(vnpParams);

        // Generate secure hash
        String vnpSecureHash = VNPaySignatureUtil.hmacSHA512(hashData, config.getHashSecret());

        // Build final payment URL with URL encoding
        StringBuilder paymentUrl = new StringBuilder(config.getPayUrl());
        StringBuilder queryUrl = new StringBuilder();

        // Add all parameters with URL encoding
        TreeMap<String, String> sortedParams = new TreeMap<>(vnpParams);
        for (Map.Entry<String, String> entry : sortedParams.entrySet()) {
            if (entry.getValue() != null && !entry.getValue().isEmpty()) {
                if (queryUrl.length() > 0) {
                    queryUrl.append("&");
                }
                queryUrl.append(URLEncoder.encode(entry.getKey(), StandardCharsets.US_ASCII))
                        .append("=")
                        .append(URLEncoder.encode(entry.getValue(), StandardCharsets.US_ASCII));
            }
        }
        queryUrl.append("&vnp_SecureHash=").append(vnpSecureHash);

        paymentUrl.append("?").append(queryUrl);

        log.info("VNPay payment URL generated: orderId={}, txnRef={}, amount={}",
                order.getId(), vnpTxnRef, vnpAmount);

        return VNPayPaymentResponse.builder()
                .paymentUrl(paymentUrl.toString())
                .build();
    }

    /**
     * Generate transaction reference (must be unique per day)
     * Format: YYYYMMDD_orderId (or just orderId if short enough)
     */
    private String generateTxnRef(String orderId) {
        // VNPay requires max 100 chars, unique per day
        // Use orderId directly (UUID is unique)
        // If needed, can add date prefix: YYYYMMDD_orderId
        return orderId;
    }

    /**
     * Build order info (no Vietnamese accents, no special chars)
     */
    private String buildOrderInfo(Order order) {
        // Remove Vietnamese accents and special characters
        String orderInfo = String.format("Thanh toan don hang %s - So tien %d VND",
                order.getId().substring(0, Math.min(8, order.getId().length())),
                order.getTotal());
        // Remove special chars and ensure no accents
        return orderInfo.replaceAll("[^a-zA-Z0-9\\s]", "").trim();
    }

    /**
     * Verify VNPay callback signature
     */
    public boolean verifySignature(Map<String, String> params, String secureHash) {
        return VNPaySignatureUtil.verifySignature(params, secureHash, config.getHashSecret());
    }
}

