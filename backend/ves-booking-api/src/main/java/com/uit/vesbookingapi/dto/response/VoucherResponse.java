package com.uit.vesbookingapi.dto.response;

import com.uit.vesbookingapi.enums.VoucherDiscountType;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class VoucherResponse {
    String id;
    String code;
    String title;
    String description;
    VoucherDiscountType discountType;
    Integer discountValue;
    Integer minOrderAmount;
    Integer maxDiscount;
    LocalDateTime startDate;
    LocalDateTime endDate;
    Integer usageLimit;
    Integer usedCount;
    List<String> applicableEvents;
    List<String> applicableCategories;
    Boolean isPublic;
}
