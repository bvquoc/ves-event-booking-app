package com.uit.vesbookingapi.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class UserVoucherResponse {
    String id;
    VoucherResponse voucher;
    Boolean isUsed;
    LocalDateTime usedAt;
    String orderId;
    LocalDateTime addedAt;
}
