package com.uit.vesbookingapi.entity;

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
@Table(name = "payment_audit_logs", indexes = {
        @Index(name = "idx_pal_order", columnList = "order_id"),
        @Index(name = "idx_pal_created", columnList = "createdAt"),
        @Index(name = "idx_pal_action", columnList = "action")
})
public class PaymentAuditLog {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    String id;

    @Column(name = "order_id")
    String orderId;

    String appTransId;

    @Column(nullable = false)
    String action;  // CREATE_ORDER, CALLBACK_RECEIVED, QUERY_STATUS, REFUND_INITIATED

    String ipAddress;

    @Column(columnDefinition = "TEXT")
    String payload;

    @Column(length = 500)
    String result;

    @Column(nullable = false)
    LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
