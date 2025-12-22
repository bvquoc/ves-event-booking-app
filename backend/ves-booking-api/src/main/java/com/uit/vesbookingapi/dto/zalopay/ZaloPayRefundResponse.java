package com.uit.vesbookingapi.dto.zalopay;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class ZaloPayRefundResponse {
    @JsonProperty("return_code")
    Integer returnCode;  // 1=success, 2=processing, 3=failed

    @JsonProperty("return_message")
    String returnMessage;

    @JsonProperty("refund_id")
    Long refundId;
}
