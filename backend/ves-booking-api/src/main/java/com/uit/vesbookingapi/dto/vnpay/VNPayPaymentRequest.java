package com.uit.vesbookingapi.dto.vnpay;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class VNPayPaymentRequest {
    String vnpVersion;
    String vnpCommand;
    String vnpTmnCode;
    String vnpAmount;  // Amount * 100 (remove decimals)
    String vnpCurrCode;
    String vnpTxnRef;  // Order reference
    String vnpOrderInfo;  // Order description (no special chars, no Vietnamese accents)
    String vnpOrderType;
    String vnpLocale;
    String vnpReturnUrl;
    String vnpIpAddr;
    String vnpCreateDate;  // yyyyMMddHHmmss (GMT+7)
    String vnpExpireDate;  // yyyyMMddHHmmss (GMT+7)
    String vnpBankCode;  // Optional
    String vnpSecureHash;
}

