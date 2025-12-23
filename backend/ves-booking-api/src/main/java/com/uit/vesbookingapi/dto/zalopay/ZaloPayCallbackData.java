package com.uit.vesbookingapi.dto.zalopay;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class ZaloPayCallbackData {
    @JsonProperty("app_id")
    Integer appId;

    @JsonProperty("app_trans_id")
    String appTransId;

    @JsonProperty("app_user")
    String appUser;

    @JsonProperty("amount")
    Long amount;

    @JsonProperty("app_time")
    Long appTime;

    @JsonProperty("embed_data")
    String embedData;

    @JsonProperty("item")
    String item;

    @JsonProperty("zp_trans_id")
    String zpTransId;

    @JsonProperty("server_time")
    Long serverTime;

    @JsonProperty("channel")
    Integer channel;

    @JsonProperty("merchant_user_id")
    String merchantUserId;

    @JsonProperty("user_fee_amount")
    Long userFeeAmount;

    @JsonProperty("discount_amount")
    Long discountAmount;
}
