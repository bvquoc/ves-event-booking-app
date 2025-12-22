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
public class ZaloPayCallbackRequest {
    @JsonProperty("app_id")
    private String appId;

    @JsonProperty("app_trans_id")
    private String appTransId;

    @JsonProperty("pmcid")
    private Long pmcid;

    @JsonProperty("bank_code")
    private String bankCode;

    @JsonProperty("amount")
    private Long amount;

    @JsonProperty("discount_amount")
    private Long discountAmount;

    @JsonProperty("status")
    private Integer status;

    @JsonProperty("mac")
    private String mac;
}

