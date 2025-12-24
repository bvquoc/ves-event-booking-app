package com.uit.vesbookingapi.util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.HexFormat;

/**
 * ZaloPay signature utility for HMAC-SHA256 signature generation.
 * <p>
 * This implementation uses standard Java crypto APIs and is equivalent to
 * the official ZaloPay HMACUtil library. If you prefer to use the official
 * library, download it from https://developers.zalopay.vn/downloads/
 * and add it to your classpath, then use HMACUtil.HMacHexStringEncode().
 *
 * @see <a href="https://developers.zalopay.vn/downloads/">ZaloPay Downloads</a>
 */
public class ZaloPaySignatureUtil {

    private static final String ALGORITHM = "HmacSHA256";

    // Flag to check if official ZaloPay library is available
    private static final boolean OFFICIAL_LIBRARY_AVAILABLE = checkOfficialLibraryAvailable();

    /**
     * Check if official ZaloPay HMACUtil library is available in classpath
     */
    private static boolean checkOfficialLibraryAvailable() {
        try {
            Class.forName("vn.zalopay.crypto.HMACUtil");
            return true;
        } catch (ClassNotFoundException e) {
            return false;
        }
    }

    /**
     * Get the implementation being used
     */
    public static String getImplementationInfo() {
        if (OFFICIAL_LIBRARY_AVAILABLE) {
            return "Official ZaloPay HMACUtil library";
        }
        return "Custom implementation (standard Java crypto)";
    }

    /**
     * Generate HMAC-SHA256 signature
     *
     * Uses official ZaloPay library if available, otherwise falls back to
     * standard Java crypto implementation (which is equivalent).
     *
     * @param data Data string to sign
     * @param key  Secret key
     * @return Hex-encoded signature (lowercase)
     */
    public static String generateSignature(String data, String key) {
        // Try to use official library if available
        if (OFFICIAL_LIBRARY_AVAILABLE) {
            try {
                return generateSignatureWithOfficialLibrary(data, key);
            } catch (Exception e) {
                // Fallback to our implementation if official library fails
                // Log warning but continue with our implementation
                System.err.println("Warning: Official ZaloPay library failed, using fallback: " + e.getMessage());
            }
        }

        // Use our standard Java crypto implementation
        return generateSignatureWithJavaCrypto(data, key);
    }

    /**
     * Generate signature using official ZaloPay HMACUtil library
     * (only called if library is available in classpath)
     */
    private static String generateSignatureWithOfficialLibrary(String data, String key) {
        try {
            // Use reflection to call official library without hard dependency
            Class<?> hmacUtilClass = Class.forName("vn.zalopay.crypto.HMACUtil");
            java.lang.reflect.Field hmacSha256Field = hmacUtilClass.getField("HMACSHA256");
            Object hmacSha256Obj = hmacSha256Field.get(null);
            String hmacSha256 = hmacSha256Obj != null ? hmacSha256Obj.toString() : "HmacSHA256";

            java.lang.reflect.Method method = hmacUtilClass.getMethod(
                    "HMacHexStringEncode", String.class, String.class, String.class
            );
            Object result = method.invoke(null, hmacSha256, key, data);
            return result != null ? result.toString() : "";
        } catch (Exception e) {
            throw new RuntimeException("Failed to use official ZaloPay library", e);
        }
    }

    /**
     * Generate signature using standard Java crypto APIs
     * This is equivalent to the official ZaloPay library implementation
     */
    private static String generateSignatureWithJavaCrypto(String data, String key) {
        try {
            Mac mac = Mac.getInstance(ALGORITHM);
            SecretKeySpec secretKey = new SecretKeySpec(
                    key.getBytes(StandardCharsets.UTF_8), ALGORITHM
            );
            mac.init(secretKey);
            byte[] hash = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            // Use HexFormat for lowercase hex output (matches official library)
            return HexFormat.of().formatHex(hash);
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate HMAC signature", e);
        }
    }

    /**
     * Verify callback signature
     *
     * @param data      Data from callback
     * @param signature Signature from ZaloPay
     * @param key       Secret key (key2)
     * @return true if valid
     */
    public static boolean verifySignature(String data, String signature, String key) {
        String computed = generateSignature(data, key);
        return computed.equalsIgnoreCase(signature);
    }

    /**
     * Build create order signature data
     * Format: app_id|app_trans_id|app_user|amount|app_time|embed_data|item
     *
     * IMPORTANT: All values must match EXACTLY what's sent in the request.
     * For form-urlencoded data, RestTemplate will URL-encode special characters,
     * but ZaloPay decodes them before verifying the signature, so use raw values here.
     */
    public static String buildCreateOrderData(
            String appId, String appTransId, String appUser,
            long amount, long appTime, String embedData, String item
    ) {
        // Build signature data - all values as strings, matching request format
        // app_id: string (even if numeric)
        // amount: string representation of number (no decimals)
        // app_time: string representation of timestamp
        // embed_data and item: JSON strings as-is (raw, not URL-encoded)
        String signatureData = String.join("|",
                appId,                    // app_id as string
                appTransId,               // app_trans_id
                appUser,                  // app_user
                String.valueOf(amount),   // amount as string (no decimals)
                String.valueOf(appTime),  // app_time as string
                embedData,                // embed_data JSON string (raw)
                item                      // item JSON string (raw)
        );
        return signatureData;
    }

    /**
     * Build callback verification data
     * Format: app_id|app_trans_id|app_user|amount|zp_trans_id|status
     */
    public static String buildCallbackData(
            String appId, String appTransId, String appUser,
            long amount, String zpTransId, int status
    ) {
        return String.join("|",
                appId, appTransId, appUser,
                String.valueOf(amount), zpTransId, String.valueOf(status)
        );
    }
}
