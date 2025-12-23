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
