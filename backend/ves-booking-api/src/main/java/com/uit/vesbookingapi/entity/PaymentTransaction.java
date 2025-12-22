package com.uit.vesbookingapi.entity;

import com.uit.vesbookingapi.enums.PaymentTransactionStatus;
import com.uit.vesbookingapi.enums.PaymentTransactionType;
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
@Table(name = "payment_transactions", indexes = {
        @Index(name = "idx_pt_order", columnList = "order_id"),
        @Index(name = "idx_pt_app_trans_id", columnList = "appTransId"),
        @Index(name = "idx_pt_created", columnList = "createdAt")
})
public class PaymentTransaction {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    String id;

    @ManyToOne
    @JoinColumn(name = "order_id", nullable = false)
    Order order;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    PaymentTransactionType type;  // CREATE, CALLBACK, QUERY, REFUND

    @Column(nullable = false)
    String appTransId;

    String zpTransId;

    @Column(nullable = false)
    Integer amount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    PaymentTransactionStatus status;  // PENDING, SUCCESS, FAILED

    Integer returnCode;  // ZaloPay return code

    @Column(length = 500)
    String returnMessage;

    @Column(columnDefinition = "TEXT")
    String requestPayload;

    @Column(columnDefinition = "TEXT")
    String responsePayload;

    @Column(nullable = false)
    LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
