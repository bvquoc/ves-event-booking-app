package com.uit.vesbookingapi.entity;

import com.uit.vesbookingapi.enums.VoucherDiscountType;
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
@Table(indexes = {
        @Index(name = "idx_voucher_code", columnList = "code")
})
public class Voucher {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    String id;

    @Column(unique = true, nullable = false)
    String code;

    @Column(nullable = false)
    String title;

    @Column(columnDefinition = "TEXT")
    String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    VoucherDiscountType discountType;

    @Column(nullable = false)
    Integer discountValue; // Amount or percentage

    Integer minOrderAmount;

    Integer maxDiscount; // For percentage type

    @Column(nullable = false)
    LocalDateTime startDate;

    @Column(nullable = false)
    LocalDateTime endDate;

    Integer usageLimit;

    @Column(nullable = false)
    Integer usedCount;

    @ElementCollection
    @CollectionTable(name = "voucher_applicable_events", joinColumns = @JoinColumn(name = "voucher_id"))
    @Column(name = "event_id")
    List<String> applicableEvents; // Empty = all events

    @ElementCollection
    @CollectionTable(name = "voucher_applicable_categories", joinColumns = @JoinColumn(name = "voucher_id"))
    @Column(name = "category_slug")
    List<String> applicableCategories; // Empty = all categories

    Boolean isPublic; // Public vouchers visible to all users
}
