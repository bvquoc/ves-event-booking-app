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
        vnpParams.put("vnp_ReturnUrl", config.getReturnUrl());
        vnpParams.put("vnp_IpAddr", clientIp);
        vnpParams.put("vnp_CreateDate", vnpCreateDate);
        vnpParams.put("vnp_ExpireDate", vnpExpireDate);
        // vnp_BankCode is optional - omit to let user choose

        log.info("VNPay parameters: version={}, command=pay, tmnCode={}, amount={}, currCode={}, txnRef={}, orderInfo={}, orderType=other, locale={}, returnUrl={}, ipAddr={}, createDate={}, expireDate={}",
                config.getVersion(), config.getTmnCode(), vnpAmount, config.getCurrency(),
                vnpTxnRef, vnpOrderInfo, config.getLocale(), config.getReturnUrl(),
                clientIp, vnpCreateDate, vnpExpireDate);

        // Build hash data (sorted alphabetically, URL-encoded values) for signature
        // IMPORTANT: Hash data must use URL-encoded values (as per VNPay example)
        String hashData = VNPaySignatureUtil.buildHashData(vnpParams);
        log.info("VNPay hash data (for signature): {}", hashData);
        log.debug("Hash data length: {}", hashData.length());

        // Generate secure hash (key first, data second - matching VNPay example)
        String vnpSecureHash = VNPaySignatureUtil.hmacSHA512(config.getHashSecret(), hashData);
        log.info("VNPay secure hash: {}", vnpSecureHash);
        log.debug("Secure hash length: {}", vnpSecureHash.length());

        // Build final payment URL with URL encoding
        StringBuilder paymentUrl = new StringBuilder(config.getPayUrl());
        StringBuilder queryUrl = new StringBuilder();

        // Add all parameters with URL encoding
        TreeMap<String, String> sortedParams = new TreeMap<>(vnpParams);
        log.debug("Building query URL with {} parameters", sortedParams.size());
        
        for (Map.Entry<String, String> entry : sortedParams.entrySet()) {
            if (entry.getValue() != null && !entry.getValue().isEmpty()) {
                if (queryUrl.length() > 0) {
                    queryUrl.append("&");
                }
                String encodedKey = URLEncoder.encode(entry.getKey(), StandardCharsets.US_ASCII);
                String encodedValue = URLEncoder.encode(entry.getValue(), StandardCharsets.US_ASCII);
                queryUrl.append(encodedKey).append("=").append(encodedValue);
                log.debug("Query param: {}={} (encoded: {}={})",
                        entry.getKey(), entry.getValue(), encodedKey, encodedValue);
            }
        }
        queryUrl.append("&vnp_SecureHash=").append(vnpSecureHash);

        paymentUrl.append("?").append(queryUrl);

        String finalUrl = paymentUrl.toString();
        log.info("VNPay payment URL generated: orderId={}, txnRef={}, amount={}, urlLength={}",
                order.getId(), vnpTxnRef, vnpAmount, finalUrl.length());
        log.debug("Full payment URL: {}", finalUrl);

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

