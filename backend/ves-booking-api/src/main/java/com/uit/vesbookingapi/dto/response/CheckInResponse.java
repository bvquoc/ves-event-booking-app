package com.uit.vesbookingapi.dto.response;

import com.uit.vesbookingapi.enums.TicketStatus;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class CheckInResponse {
    String ticketId;
    String qrCode;
    TicketStatus status;
    LocalDateTime checkedInAt;
    String message;
    // Include ticket details for admin reference
    AdminTicketResponse ticketDetails;
}

