package com.uit.vesbookingapi.dto.vnpay;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class VNPayPaymentResponse {
    String paymentUrl;  // Full payment URL with query parameters
}

