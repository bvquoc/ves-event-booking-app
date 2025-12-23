package com.uit.vesbookingapi.dto.zalopay;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class ZaloPayCreateResponse {
    @JsonProperty("return_code")
    Integer returnCode;  // 1=success, -2=invalid MAC, -5=duplicate

    @JsonProperty("return_message")
    String returnMessage;

    @JsonProperty("sub_return_code")
    Integer subReturnCode;

    @JsonProperty("sub_return_message")
    String subReturnMessage;

    @JsonProperty("order_url")
    String orderUrl;  // Redirect URL for payment

    @JsonProperty("zp_trans_token")
    String zpTransToken;

    @JsonProperty("order_token")
    String orderToken;

    @JsonProperty("qr_code")
    String qrCode;  // QR code for scan-to-pay
}
