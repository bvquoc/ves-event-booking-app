package com.uit.vesbookingapi.entity;

import com.uit.vesbookingapi.enums.RefundStatus;
import com.uit.vesbookingapi.enums.TicketStatus;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@Entity
@Table(indexes = {
        @Index(name = "idx_ticket_user", columnList = "user_id"),
        @Index(name = "idx_ticket_status", columnList = "status"),
        @Index(name = "idx_ticket_purchase_date", columnList = "purchase_date")
})
public class Ticket {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    String id;

    @ManyToOne
    @JoinColumn(name = "order_id", nullable = false)
    Order order;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    User user;

    @ManyToOne
    @JoinColumn(name = "event_id", nullable = false)
    Event event;

    @ManyToOne
    @JoinColumn(name = "ticket_type_id", nullable = false)
    TicketType ticketType;

    @ManyToOne
    @JoinColumn(name = "seat_id")
    Seat seat;

    @Column(name = "qr_code", nullable = false, unique = true)
    String qrCode; // Unique QR code

    @Column(name = "qr_code_image")
    String qrCodeImage; // URL to QR code image

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    TicketStatus status;

    @Column(name = "purchase_date")
    LocalDateTime purchaseDate;

    @Column(name = "checked_in_at")
    LocalDateTime checkedInAt;

    @Column(name = "cancellation_reason")
    String cancellationReason;

    @Column(name = "refund_amount")
    Integer refundAmount;

    @Enumerated(EnumType.STRING)
    @Column(name = "refund_status")
    RefundStatus refundStatus;

    @Column(name = "cancelled_at")
    LocalDateTime cancelledAt;
}
