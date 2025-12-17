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
    @Index(name = "idx_order_status", columnList = "status")
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

    String currency;

    @ManyToOne
    @JoinColumn(name = "voucher_id")
    Voucher voucher;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    OrderStatus status;

    @Enumerated(EnumType.STRING)
    PaymentMethod paymentMethod;

    String paymentUrl; // Mock payment gateway URL

    LocalDateTime expiresAt; // Payment timeout

    @Column(nullable = false)
    LocalDateTime createdAt;

    LocalDateTime completedAt;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    List<Ticket> tickets;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
