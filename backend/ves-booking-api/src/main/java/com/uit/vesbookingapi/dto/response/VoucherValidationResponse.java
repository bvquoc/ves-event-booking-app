package com.uit.vesbookingapi.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class VoucherValidationResponse {
    Boolean isValid;
    String message;
    Integer orderAmount;
    Integer discountAmount;
    Integer finalAmount;
    VoucherResponse voucher;
}
