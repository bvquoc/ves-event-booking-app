package com.uit.vesbookingapi.configuration;

import lombok.AccessLevel;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldDefaults;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "zalopay")
@Getter
@Setter
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ZaloPayConfig {
    String appId;
    String key1;
    String key2;
    String endpoint;
    String callbackUrl;
    int paymentTimeoutMinutes = 15;

    /**
     * Get app_id as Integer (ZaloPay expects Int type)
     */
    public Integer getAppIdAsInt() {
        try {
            return Integer.parseInt(appId);
        } catch (NumberFormatException e) {
            throw new RuntimeException("ZaloPay app_id must be a valid integer: " + appId, e);
        }
    }

    // Ensure key1 and key2 are trimmed (no whitespace)
    public void setKey1(String key1) {
        this.key1 = key1 != null ? key1.trim() : null;
    }

    public void setKey2(String key2) {
        this.key2 = key2 != null ? key2.trim() : null;
    }

    // Derived endpoints
    public String getCreateOrderUrl() {
        return endpoint + "/create";
    }

    public String getQueryUrl() {
        return endpoint + "/query";
    }

    public String getRefundUrl() {
        return endpoint + "/refund";
    }
}
