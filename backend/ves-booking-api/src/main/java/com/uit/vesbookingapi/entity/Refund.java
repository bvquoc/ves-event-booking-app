package com.uit.vesbookingapi.entity;

import com.uit.vesbookingapi.enums.RefundStatus;
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
@Table(name = "refunds", indexes = {
        @Index(name = "idx_refund_ticket", columnList = "ticket_id"),
        @Index(name = "idx_refund_status", columnList = "status"),
        @Index(name = "idx_refund_m_refund_id", columnList = "mRefundId")
})
public class Refund {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    String id;

    @ManyToOne
    @JoinColumn(name = "ticket_id", nullable = false)
    Ticket ticket;

    @ManyToOne
    @JoinColumn(name = "order_id", nullable = false)
    Order order;

    @Column(unique = true, nullable = false)
    String mRefundId;  // Idempotent refund ID: YYMMDD_ticketId

    String zpTransId;  // Original payment transaction ID

    @Column(nullable = false)
    Integer amount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    RefundStatus status;  // PENDING, PROCESSING, COMPLETED, FAILED

    Integer returnCode;

    @Column(length = 500)
    String returnMessage;

    String zpRefundId;  // ZaloPay refund transaction ID

    @Column(nullable = false)
    LocalDateTime createdAt;

    LocalDateTime processedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
