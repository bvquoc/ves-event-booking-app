package com.uit.vesbookingapi.dto.zalopay;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class ZaloPayQueryResponse {
    @JsonProperty("return_code")
    Integer returnCode;  // 1=paid, 2=pending, 3=failed

    @JsonProperty("return_message")
    String returnMessage;

    @JsonProperty("is_processing")
    Boolean isProcessing;

    @JsonProperty("amount")
    Long amount;

    @JsonProperty("zp_trans_id")
    String zpTransId;
}
