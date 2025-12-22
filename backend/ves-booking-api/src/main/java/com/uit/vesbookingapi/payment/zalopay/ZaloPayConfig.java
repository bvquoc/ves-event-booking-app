package com.uit.vesbookingapi.payment.zalopay;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "zalopay")
@Data
public class ZaloPayConfig {
    private Sandbox sandbox;
    private Production production;
    private String callbackUrl;
    private String redirectUrl;
    private String queryStatusUrl;

    public boolean isSandboxMode() {
        return sandbox != null && sandbox.isEnabled();
    }

    public String getAppId() {
        return isSandboxMode() ? sandbox.getAppId() : production.getAppId();
    }

    public String getKey1() {
        return isSandboxMode() ? sandbox.getKey1() : production.getKey1();
    }

    public String getKey2() {
        return isSandboxMode() ? sandbox.getKey2() : production.getKey2();
    }

    public String getCreateOrderEndpoint() {
        return isSandboxMode() ? sandbox.getEndpoint() : production.getEndpoint();
    }

    @Data
    public static class Sandbox {
        private boolean enabled;
        private String appId;
        private String key1;
        private String key2;
        private String endpoint;
    }

    @Data
    public static class Production {
        private boolean enabled;
        private String appId;
        private String key1;
        private String key2;
        private String endpoint;
    }
}

