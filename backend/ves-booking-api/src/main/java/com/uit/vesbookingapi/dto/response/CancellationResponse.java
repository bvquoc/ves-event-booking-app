package com.uit.vesbookingapi.dto.response;

import com.uit.vesbookingapi.enums.RefundStatus;
import com.uit.vesbookingapi.enums.TicketStatus;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CancellationResponse {
    String ticketId;
    TicketStatus status;
    Integer refundAmount;
    Integer refundPercentage;
    RefundStatus refundStatus;
    LocalDateTime cancelledAt;
    String message;
}
