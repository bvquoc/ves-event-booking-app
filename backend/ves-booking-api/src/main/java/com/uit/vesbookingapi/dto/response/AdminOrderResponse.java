package com.uit.vesbookingapi.dto.response;

import com.uit.vesbookingapi.enums.OrderStatus;
import com.uit.vesbookingapi.enums.PaymentMethod;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class AdminOrderResponse {
    // Order basic info
    String id;
    OrderStatus status;
    PaymentMethod paymentMethod;
    String paymentUrl;
    String paymentTransactionId; // Payment gateway transaction ID if applicable
    LocalDateTime expiresAt;
    LocalDateTime createdAt;
    LocalDateTime completedAt;

    // User information
    UserInfo user;

    // Event information
    EventInfo event;

    // Ticket type information
    TicketTypeInfo ticketType;

    // Order details
    Integer quantity;
    Integer subtotal;
    Integer discount;
    Integer total;
    String currency;
    String voucherCode;

    // Related tickets
    List<TicketSummary> tickets;

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
        String fullName; // firstName + lastName
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
    public static class TicketSummary {
        String id;
        String qrCode;
        String seatNumber;
        com.uit.vesbookingapi.enums.TicketStatus status;
        LocalDateTime purchaseDate;
        LocalDateTime checkedInAt;
        LocalDateTime cancelledAt;
    }
}

