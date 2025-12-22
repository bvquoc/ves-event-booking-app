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
public class AdminTicketResponse {
    // Ticket basic info
    String id;
    String qrCode;
    String qrCodeImage;
    TicketStatus status;
    LocalDateTime purchaseDate;
    LocalDateTime checkedInAt;
    LocalDateTime cancelledAt;
    String cancellationReason;
    Integer refundAmount;
    RefundStatus refundStatus;

    // User information
    UserInfo user;

    // Order information
    OrderInfo order;

    // Event information
    EventInfo event;

    // Ticket type information
    TicketTypeInfo ticketType;

    // Seat information
    SeatInfo seat;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @FieldDefaults(level = AccessLevel.PRIVATE)
    public static class UserInfo {
        String id;
        String username;
        String email;
        String phone;
        String firstName;
        String lastName;
        String fullName;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @FieldDefaults(level = AccessLevel.PRIVATE)
    public static class OrderInfo {
        String id;
        com.uit.vesbookingapi.enums.OrderStatus status;
        com.uit.vesbookingapi.enums.PaymentMethod paymentMethod;
        Integer total;
        String currency;
        LocalDateTime createdAt;
        LocalDateTime completedAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @FieldDefaults(level = AccessLevel.PRIVATE)
    public static class EventInfo {
        String id;
        String name;
        String slug;
        String description;
        String thumbnail;
        String venueName;
        String venueAddress;
        LocalDateTime startDate;
        LocalDateTime endDate;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @FieldDefaults(level = AccessLevel.PRIVATE)
    public static class TicketTypeInfo {
        String id;
        String name;
        String description;
        Integer price;
        String currency;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @FieldDefaults(level = AccessLevel.PRIVATE)
    public static class SeatInfo {
        String id;
        String seatNumber;
        String section;
        String row;
    }
}

