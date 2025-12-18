package com.uit.vesbookingapi.dto.response;

import com.uit.vesbookingapi.enums.OrderStatus;
import com.uit.vesbookingapi.enums.PaymentMethod;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class OrderResponse {
    String id;
    String userId;
    String eventId;
    String eventName;
    String ticketTypeId;
    String ticketTypeName;
    Integer quantity;
    Integer subtotal;
    Integer discount;
    Integer total;
    String currency;
    String voucherCode;
    OrderStatus status;
    PaymentMethod paymentMethod;
    String paymentUrl;
    LocalDateTime expiresAt;
    LocalDateTime createdAt;
    LocalDateTime completedAt;
}
