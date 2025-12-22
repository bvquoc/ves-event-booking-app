package com.uit.vesbookingapi.payment.zalopay.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ZaloPayCreateOrderRequest {
    @JsonProperty("app_id")
    private String appId;

    @JsonProperty("app_user")
    private String appUser;

    @JsonProperty("app_time")
    private Long appTime;

    @JsonProperty("amount")
    private Long amount;

    @JsonProperty("app_trans_id")
    private String appTransId;

    @JsonProperty("description")
    private String description;

    @JsonProperty("bank_code")
    private String bankCode;

    @JsonProperty("item")
    private String item;

    @JsonProperty("embed_data")
    private String embedData;

    @JsonProperty("mac")
    private String mac;
}

