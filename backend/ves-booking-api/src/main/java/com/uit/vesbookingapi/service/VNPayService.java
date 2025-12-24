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
        log.info("Creating VNPay payment URL: orderId={}, amount={}, user={}, clientIp={}",
                order.getId(), order.getTotal(), order.getUser().getUsername(), clientIp);

        // Generate transaction reference (must be unique per day)
        String vnpTxnRef = generateTxnRef(order.getId());
        log.debug("Generated vnpTxnRef: {}", vnpTxnRef);

        // Amount: multiply by 100 to remove decimals (VNPay requirement)
        long vnpAmount = order.getTotal() * 100L;
        log.debug("Amount calculation: {} * 100 = {}", order.getTotal(), vnpAmount);

        // Create date and expire date (GMT+7)
        Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        String vnpCreateDate = formatter.format(cal.getTime());
        cal.add(Calendar.MINUTE, config.getPaymentTimeoutMinutes());
        String vnpExpireDate = formatter.format(cal.getTime());
        log.debug("Date calculation: createDate={}, expireDate={}, timeoutMinutes={}",
                vnpCreateDate, vnpExpireDate, config.getPaymentTimeoutMinutes());

        // Build order info (no Vietnamese accents, no special chars)
        // Use transaction reference in orderInfo (matching VNPay example pattern)
        String vnpOrderInfo = "Thanh toan don hang:" + vnpTxnRef;
        log.debug("OrderInfo: {}", vnpOrderInfo);

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
        // Normalize return URL to prevent signature mismatch (remove trailing slash if present)
        String returnUrl = config.getReturnUrl();
        if (returnUrl != null && returnUrl.endsWith("/") && returnUrl.length() > 1) {
            returnUrl = returnUrl.substring(0, returnUrl.length() - 1);
            log.debug("Normalized return URL (removed trailing slash): {}", returnUrl);
        }
        vnpParams.put("vnp_ReturnUrl", returnUrl);
        vnpParams.put("vnp_IpAddr", clientIp);
        vnpParams.put("vnp_CreateDate", vnpCreateDate);
        vnpParams.put("vnp_ExpireDate", vnpExpireDate);
        // vnp_BankCode is optional - omit to let user choose

        log.info("VNPay parameters: version={}, command=pay, tmnCode={}, amount={}, currCode={}, txnRef={}, orderInfo={}, orderType=other, locale={}, returnUrl={}, ipAddr={}, createDate={}, expireDate={}",
                config.getVersion(), config.getTmnCode(), vnpAmount, config.getCurrency(),
                vnpTxnRef, vnpOrderInfo, config.getLocale(), config.getReturnUrl(),
                clientIp, vnpCreateDate, vnpExpireDate);

        // Build hash data (sorted alphabetically, RAW values - NO URL encoding) for signature
        // Hash data must use RAW values (fieldName=rawValue), NOT URL-encoded
        String hashData = VNPaySignatureUtil.buildHashData(vnpParams);
        log.info("VNPay hash data (for signature): {}", hashData);
        log.debug("Hash data length: {}", hashData.length());

        // Validate secret key (check for spaces/newlines that might cause issues)
        String hashSecret = config.getHashSecret();
        if (hashSecret == null || hashSecret.trim().isEmpty()) {
            throw new RuntimeException("VNPay hash secret is null or empty");
        }
        // Log key info (first/last chars only for security)
        log.debug("VNPay hash secret length: {}, starts with: {}, ends with: {}",
                hashSecret.length(),
                hashSecret.length() > 0 ? hashSecret.substring(0, Math.min(4, hashSecret.length())) : "N/A",
                hashSecret.length() > 0 ? hashSecret.substring(Math.max(0, hashSecret.length() - 4)) : "N/A");
        
        // Generate secure hash (key first, data second - matching VNPay example)
        String vnpSecureHash = VNPaySignatureUtil.hmacSHA512(hashSecret.trim(), hashData);
        log.info("VNPay secure hash: {}", vnpSecureHash);
        log.debug("Secure hash length: {}", vnpSecureHash.length());

        // Build final payment URL with URL encoding
        // IMPORTANT: Encode each value separately (NOT the full query string)
        // IMPORTANT: Do NOT encode vnp_SecureHash
        StringBuilder paymentUrl = new StringBuilder(config.getPayUrl());
        StringBuilder queryUrl = new StringBuilder();

        // Add all parameters with URL encoding (encode each key and value separately)
        TreeMap<String, String> sortedParams = new TreeMap<>(vnpParams);
        log.debug("Building query URL with {} parameters", sortedParams.size());
        
        for (Map.Entry<String, String> entry : sortedParams.entrySet()) {
            if (entry.getValue() != null && !entry.getValue().isEmpty()) {
                if (queryUrl.length() > 0) {
                    queryUrl.append("&");
                }
                // Encode key and value separately (matching VNPay example)
                String encodedKey = URLEncoder.encode(entry.getKey(), StandardCharsets.US_ASCII);
                String encodedValue = URLEncoder.encode(entry.getValue(), StandardCharsets.US_ASCII);
                queryUrl.append(encodedKey).append("=").append(encodedValue);
                log.debug("Query param: {}={} (encoded: {}={})",
                        entry.getKey(), entry.getValue(), encodedKey, encodedValue);
            }
        }
        // Append vnp_SecureHash WITHOUT encoding (critical - must not encode the hash)
        queryUrl.append("&vnp_SecureHash=").append(vnpSecureHash);

        paymentUrl.append("?").append(queryUrl);

        String finalUrl = paymentUrl.toString();
        log.info("VNPay payment URL generated: orderId={}, txnRef={}, amount={}, urlLength={}",
                order.getId(), vnpTxnRef, vnpAmount, finalUrl.length());
        log.debug("Full payment URL: {}", finalUrl);

        // Verify data consistency: ensure values in URL match values used for hash
        // This is critical - any difference (trailing slash, encoding, etc.) will cause signature mismatch
        log.info("Data consistency check - Hash data used: {}", hashData);
        log.debug("Return URL in params (used for hash): {}", vnpParams.get("vnp_ReturnUrl"));

        // Validate that return URL matches exactly (no trailing slash differences)
        String returnUrlInParams = vnpParams.get("vnp_ReturnUrl");
        String returnUrlInConfig = config.getReturnUrl();
        if (returnUrlInParams != null && returnUrlInConfig != null) {
            // Normalize both for comparison (remove trailing slash)
            String normalizedParams = returnUrlInParams.endsWith("/") && returnUrlInParams.length() > 1
                    ? returnUrlInParams.substring(0, returnUrlInParams.length() - 1) : returnUrlInParams;
            String normalizedConfig = returnUrlInConfig.endsWith("/") && returnUrlInConfig.length() > 1
                    ? returnUrlInConfig.substring(0, returnUrlInConfig.length() - 1) : returnUrlInConfig;

            if (!normalizedParams.equals(normalizedConfig)) {
                log.warn("WARNING: Return URL mismatch detected! Params: {}, Config: {}",
                        returnUrlInParams, returnUrlInConfig);
            }
        }

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
     * Verify VNPay callback signature
     */
    public boolean verifySignature(Map<String, String> params, String secureHash) {
        return VNPaySignatureUtil.verifySignature(params, secureHash, config.getHashSecret());
    }
}

