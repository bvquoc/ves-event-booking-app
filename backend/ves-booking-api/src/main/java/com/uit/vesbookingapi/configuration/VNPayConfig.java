package com.uit.vesbookingapi.configuration;

import lombok.AccessLevel;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldDefaults;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "vnpay")
@Getter
@Setter
@FieldDefaults(level = AccessLevel.PRIVATE)
public class VNPayConfig {
    String tmnCode;  // Merchant code
    String hashSecret;  // Secret key for signature
    String payUrl;  // Payment URL
    String returnUrl;  // Return URL after payment
    String ipnUrl;  // IPN URL for server-to-server callback
    String queryUrl;  // Query transaction URL
    String refundUrl;  // Refund URL
    String version = "2.1.0";  // API version
    String locale = "vn";  // Language: vn or en
    String currency = "VND";  // Currency code
    int paymentTimeoutMinutes = 15;  // Payment timeout in minutes
}

