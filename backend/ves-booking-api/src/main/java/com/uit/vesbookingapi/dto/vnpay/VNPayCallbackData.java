package com.uit.vesbookingapi.dto.vnpay;

import lombok.*;
import lombok.experimental.FieldDefaults;

/**
 * VNPay callback data (IPN and Return URL)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class VNPayCallbackData {
    String vnpTmnCode;
    String vnpAmount;  // Amount * 100
    String vnpBankCode;
    String vnpBankTranNo;
    String vnpCardType;
    String vnpPayDate;  // yyyyMMddHHmmss
    String vnpOrderInfo;
    String vnpTransactionNo;  // VNPay transaction ID
    String vnpResponseCode;  // 00 = success
    String vnpTransactionStatus;  // 00 = success
    String vnpTxnRef;  // Order reference
    String vnpSecureHash;
    String vnpSecureHashType;  // Optional
}

