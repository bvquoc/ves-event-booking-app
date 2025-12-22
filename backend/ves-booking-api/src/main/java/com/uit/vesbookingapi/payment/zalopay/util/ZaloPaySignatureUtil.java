package com.uit.vesbookingapi.payment.zalopay.util;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;

@Component
@Slf4j
public class ZaloPaySignatureUtil {

    public String createSignature(String data, String key) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKeySpec = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            mac.init(secretKeySpec);
            byte[] hash = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return bytesToHex(hash);
        } catch (Exception e) {
            log.error("Failed to create ZaloPay signature", e);
            throw new RuntimeException("Failed to create signature", e);
        }
    }

    public boolean verifySignature(String data, String key, String signature) {
        String calculatedMac = createSignature(data, key);
        boolean isValid = calculatedMac.equals(signature);
        if (!isValid) {
            log.warn("ZaloPay signature verification failed. Expected: {}, Got: {}", calculatedMac, signature);
        }
        return isValid;
    }

    private String bytesToHex(byte[] bytes) {
        StringBuilder result = new StringBuilder();
        for (byte b : bytes) {
            result.append(String.format("%02x", b));
        }
        return result.toString();
    }
}

