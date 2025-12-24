package com.uit.vesbookingapi.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class SeatRequest {
    @NotBlank(message = "Section name is required")
    String sectionName;

    @NotBlank(message = "Row name is required")
    String rowName;

    @NotBlank(message = "Seat number is required")
    String seatNumber;
}

