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
public class ZaloPayQueryStatusResponse {
    @JsonProperty("return_code")
    private Integer returnCode;

    @JsonProperty("return_message")
    private String returnMessage;

    @JsonProperty("is_processing")
    private Boolean isProcessing;

    @JsonProperty("amount")
    private Long amount;

    @JsonProperty("zp_trans_id")
    private Long zpTransId;

    @JsonProperty("server_time")
    private Long serverTime;
}

