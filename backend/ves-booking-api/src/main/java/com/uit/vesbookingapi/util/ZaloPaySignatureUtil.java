package com.uit.vesbookingapi.util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.HexFormat;

public class ZaloPaySignatureUtil {

    private static final String ALGORITHM = "HmacSHA256";

    /**
     * Generate HMAC-SHA256 signature
     *
     * @param data Data string to sign
     * @param key  Secret key
     * @return Hex-encoded signature
     */
    public static String generateSignature(String data, String key) {
        try {
            Mac mac = Mac.getInstance(ALGORITHM);
            SecretKeySpec secretKey = new SecretKeySpec(
                    key.getBytes(StandardCharsets.UTF_8), ALGORITHM
            );
            mac.init(secretKey);
            byte[] hash = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
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
     */
    public static String buildCreateOrderData(
            String appId, String appTransId, String appUser,
            long amount, long appTime, String embedData, String item
    ) {
        return String.join("|",
                appId, appTransId, appUser,
                String.valueOf(amount), String.valueOf(appTime),
                embedData, item
        );
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
