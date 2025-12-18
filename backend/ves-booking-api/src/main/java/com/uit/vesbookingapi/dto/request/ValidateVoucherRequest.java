package com.uit.vesbookingapi.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ValidateVoucherRequest {
    @NotNull(message = "Voucher code is required")
    @Pattern(regexp = "^[A-Z0-9_-]{3,30}$", message = "Invalid voucher code format")
    String voucherCode;

    @NotNull(message = "Event ID is required")
    String eventId;

    @NotNull(message = "Ticket type ID is required")
    String ticketTypeId;

    @NotNull(message = "Quantity is required")
    @Min(value = 1, message = "Quantity must be at least 1")
    Integer quantity;
}
