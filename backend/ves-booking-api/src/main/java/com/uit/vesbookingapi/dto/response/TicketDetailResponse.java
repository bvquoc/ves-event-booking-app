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
public class TicketDetailResponse {
    String id;
    String eventId;
    String eventName;
    String eventDescription;
    String eventThumbnail;
    LocalDateTime eventStartDate;
    LocalDateTime eventEndDate;
    String venueName;
    String venueAddress;
    String ticketTypeId;
    String ticketTypeName;
    String ticketTypeDescription;
    Integer ticketTypePrice;
    String seatNumber; // Null if no seat selection
    String seatSectionName; // Null if no seat selection
    String seatRowName; // Null if no seat selection
    String qrCode;
    String qrCodeImage;
    TicketStatus status;
    LocalDateTime purchaseDate;
    LocalDateTime checkedInAt;
    String cancellationReason;
    Integer refundAmount;
    RefundStatus refundStatus;
    LocalDateTime cancelledAt;
}
