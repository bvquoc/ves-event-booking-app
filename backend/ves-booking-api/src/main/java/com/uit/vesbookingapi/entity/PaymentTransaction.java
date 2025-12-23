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
        @Index(name = "idx_pt_app_trans_id", columnList = "app_trans_id"),
        @Index(name = "idx_pt_created", columnList = "created_at")
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

    @Column(name = "app_trans_id", nullable = false)
    String appTransId;

    @Column(name = "zp_trans_id")
    String zpTransId;

    @Column(nullable = false)
    Integer amount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    PaymentTransactionStatus status;  // PENDING, SUCCESS, FAILED

    @Column(name = "return_code")
    Integer returnCode;  // ZaloPay return code

    @Column(length = 500, name = "return_message")
    String returnMessage;

    @Column(columnDefinition = "TEXT")
    String requestPayload;

    @Column(columnDefinition = "TEXT")
    String responsePayload;

    @Column(name = "created_at", nullable = false)
    LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
