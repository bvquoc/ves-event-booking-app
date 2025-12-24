package com.uit.vesbookingapi.util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.TreeMap;

/**
 * VNPay signature utility for HMAC-SHA512 signature generation
 * Following VNPay official example pattern
 */
public class VNPaySignatureUtil {

    private static final String ALGORITHM = "HmacSHA512";

    /**
     * Generate HMAC-SHA512 signature for VNPay
     *
     * @param data      Data string to sign (sorted query string with URL-encoded values)
     * @param secretKey Secret key (vnp_HashSecret)
     * @return Hex-encoded signature
     */
    public static String hmacSHA512(String data, String secretKey) {
        try {
            Mac mac = Mac.getInstance(ALGORITHM);
            SecretKeySpec secretKeySpec = new SecretKeySpec(
                    secretKey.getBytes(StandardCharsets.UTF_8), ALGORITHM
            );
            mac.init(secretKeySpec);
            byte[] hash = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return bytesToHex(hash);
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate VNPay signature", e);
        }
    }

    /**
     * Build hash data string from parameters (sorted alphabetically, URL-encoded values)
     * Used for signature generation - matches VNPay example pattern
     *
     * @param params Map of parameters
     * @return Sorted hash data string (fieldName=URLEncoded(fieldValue)&fieldName2=URLEncoded(fieldValue2)...)
     */
    public static String buildHashData(Map<String, String> params) {
        // Sort parameters alphabetically
        TreeMap<String, String> sortedParams = new TreeMap<>(params);

        StringBuilder hashData = new StringBuilder();
        for (Map.Entry<String, String> entry : sortedParams.entrySet()) {
            if (entry.getValue() != null && !entry.getValue().isEmpty()) {
                if (hashData.length() > 0) {
                    hashData.append("&");
                }
                hashData.append(entry.getKey())
                        .append("=")
                        .append(URLEncoder.encode(entry.getValue(), StandardCharsets.US_ASCII));
            }
        }
        return hashData.toString();
    }

    /**
     * Build query string from parameters (sorted alphabetically)
     * Used for URL construction
     *
     * @param params Map of parameters
     * @return Sorted query string (fieldName=fieldValue&fieldName2=fieldValue2...)
     */
    public static String buildQueryString(Map<String, String> params) {
        // Sort parameters alphabetically
        TreeMap<String, String> sortedParams = new TreeMap<>(params);

        StringBuilder query = new StringBuilder();
        for (Map.Entry<String, String> entry : sortedParams.entrySet()) {
            if (entry.getValue() != null && !entry.getValue().isEmpty()) {
                if (query.length() > 0) {
                    query.append("&");
                }
                query.append(entry.getKey()).append("=").append(entry.getValue());
            }
        }
        return query.toString();
    }

    /**
     * Convert byte array to hex string (lowercase)
     */
    private static String bytesToHex(byte[] bytes) {
        StringBuilder hexString = new StringBuilder();
        for (byte b : bytes) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) {
                hexString.append('0');
            }
            hexString.append(hex);
        }
        return hexString.toString();
    }

    /**
     * Verify VNPay signature
     *
     * @param params     Map of parameters (excluding vnp_SecureHash)
     * @param secureHash Signature from VNPay
     * @param secretKey  Secret key
     * @return true if signature is valid
     */
    public static boolean verifySignature(Map<String, String> params, String secureHash, String secretKey) {
        // Remove vnp_SecureHash and vnp_SecureHashType if present
        Map<String, String> paramsForHash = new TreeMap<>(params);
        paramsForHash.remove("vnp_SecureHash");
        paramsForHash.remove("vnp_SecureHashType");

        String queryString = buildQueryString(paramsForHash);
        String computedHash = hmacSHA512(queryString, secretKey);
        return computedHash.equals(secureHash);
    }
}

