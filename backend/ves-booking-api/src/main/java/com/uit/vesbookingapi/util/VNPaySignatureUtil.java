package com.uit.vesbookingapi.util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

/**
 * VNPay signature utility for HMAC-SHA512 signature generation
 * Following VNPay official example pattern
 */
public class VNPaySignatureUtil {

    private static final String ALGORITHM = "HmacSHA512";

    /**
     * Generate HMAC-SHA512 signature for VNPay
     * Following VNPay example: hmacSHA512(key, data)
     *
     * @param secretKey Secret key (vnp_HashSecret) - comes first as per VNPay example
     * @param data      Data string to sign (sorted query string with URL-encoded values)
     * @return Hex-encoded signature (lowercase)
     */
    public static String hmacSHA512(String secretKey, String data) {
        try {
            if (secretKey == null || data == null) {
                throw new NullPointerException("Secret key and data cannot be null");
            }
            
            Mac mac = Mac.getInstance(ALGORITHM);
            // Use default encoding for key (matching VNPay example: key.getBytes())
            byte[] hmacKeyBytes = secretKey.getBytes();
            SecretKeySpec secretKeySpec = new SecretKeySpec(hmacKeyBytes, ALGORITHM);
            mac.init(secretKeySpec);
            // Use UTF-8 for data (matching VNPay example: data.getBytes(StandardCharsets.UTF_8))
            byte[] dataBytes = data.getBytes(StandardCharsets.UTF_8);
            byte[] result = mac.doFinal(dataBytes);

            // Convert to lowercase hex string (matching VNPay example format)
            StringBuilder sb = new StringBuilder(2 * result.length);
            for (byte b : result) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
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
        // Sort parameters alphabetically (matching VNPay example)
        List<String> fieldNames = new ArrayList<>(params.keySet());
        Collections.sort(fieldNames);

        StringBuilder hashData = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = params.get(fieldName);
            if (fieldValue != null && !fieldValue.isEmpty()) {
                // Build hash data: fieldName=URLEncoded(fieldValue)
                hashData.append(fieldName);
                hashData.append('=');
                hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII));
                // Add & only if there are more fields (matching VNPay example pattern)
                if (itr.hasNext()) {
                    hashData.append('&');
                }
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

        // Build hash data for verification (same as signature generation)
        String hashData = buildHashData(paramsForHash);
        String computedHash = hmacSHA512(secretKey, hashData);
        return computedHash.equals(secureHash);
    }
}

