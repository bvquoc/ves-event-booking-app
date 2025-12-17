package com.uit.vesbookingapi.dto.request;

import com.uit.vesbookingapi.enums.PaymentMethod;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class PurchaseRequest {

    @NotNull(message = "Event ID is required")
    String eventId;

    @NotNull(message = "Ticket type ID is required")
    String ticketTypeId;

    @NotNull(message = "Quantity is required")
    @Min(value = 1, message = "Quantity must be at least 1")
    Integer quantity;

    List<String> seatIds; // Optional, required if ticket type requires seat selection

    String voucherCode; // Optional

    @NotNull(message = "Payment method is required")
    PaymentMethod paymentMethod;
}
