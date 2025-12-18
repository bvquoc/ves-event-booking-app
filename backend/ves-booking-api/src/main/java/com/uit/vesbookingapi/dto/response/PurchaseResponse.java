package com.uit.vesbookingapi.dto.response;

import com.uit.vesbookingapi.enums.OrderStatus;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class PurchaseResponse {
    String orderId;
    OrderStatus status;
    String paymentUrl;
    Integer total;
    LocalDateTime expiresAt;
}
