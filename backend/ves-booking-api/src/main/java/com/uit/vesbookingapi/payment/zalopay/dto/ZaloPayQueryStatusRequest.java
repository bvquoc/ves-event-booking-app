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
public class ZaloPayQueryStatusRequest {
    @JsonProperty("app_id")
    private String appId;

    @JsonProperty("app_trans_id")
    private String appTransId;

    @JsonProperty("mac")
    private String mac;
}

