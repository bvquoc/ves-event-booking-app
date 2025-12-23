package com.uit.vesbookingapi.entity;

import com.uit.vesbookingapi.enums.OrderStatus;
import com.uit.vesbookingapi.enums.PaymentMethod;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@Entity
@Table(name = "orders", indexes = {
        @Index(name = "idx_order_user", columnList = "user_id"),
        @Index(name = "idx_order_status", columnList = "status"),
        @Index(name = "idx_order_app_trans_id", columnList = "app_trans_id"),
        @Index(name = "idx_order_status_expires", columnList = "status, expires_at")
})
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    String id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    User user;

    @ManyToOne
    @JoinColumn(name = "event_id", nullable = false)
    Event event;

    @ManyToOne
    @JoinColumn(name = "ticket_type_id", nullable = false)
    TicketType ticketType;

    @Column(nullable = false)
    Integer quantity;

    @Column(nullable = false)
    Integer subtotal;

    Integer discount;

    @Column(nullable = false)
    Integer total;

    @Column(name = "currency")
    String currency;

    @ManyToOne
    @JoinColumn(name = "voucher_id")
    Voucher voucher;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    OrderStatus status;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_method")
    PaymentMethod paymentMethod;

    @Column(name = "payment_url")
    String paymentUrl;

    @Column(name = "expires_at")
    LocalDateTime expiresAt; // Payment timeout

    // ZaloPay-specific fields
    @Column(name = "app_trans_id", unique = true)
    String appTransId;  // Unique transaction ID: YYMMDD_orderId

    @Column(name = "zp_trans_id")
    String zpTransId;   // ZaloPay transaction ID (from callback)

    @Column(name = "payment_confirmed_at")
    LocalDateTime paymentConfirmedAt;  // When payment was confirmed

    @Column(name = "payment_gateway")
    String paymentGateway;  // "ZALOPAY" | "MOCK" (for backward compatibility)

    @Column(name = "created_at", nullable = false)
    LocalDateTime createdAt;

    @Column(name = "completed_at")
    LocalDateTime completedAt;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    List<Ticket> tickets;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
