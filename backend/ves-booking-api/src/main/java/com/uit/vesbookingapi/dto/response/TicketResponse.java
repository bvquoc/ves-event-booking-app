package com.uit.vesbookingapi.dto.response;

import com.uit.vesbookingapi.enums.TicketStatus;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class TicketResponse {
    String id;
    String eventId;
    String eventName;
    String eventThumbnail;
    LocalDateTime eventStartDate;
    String venueName;
    String ticketTypeName;
    String seatNumber; // Null if no seat selection
    TicketStatus status;
    String qrCode;
    LocalDateTime purchaseDate;
}
