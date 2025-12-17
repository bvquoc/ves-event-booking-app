package com.uit.vesbookingapi.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class VenueRequest {
    @NotBlank(message = "Venue name is required")
    String name;

    String address;

    Integer capacity;

    @NotBlank(message = "City ID is required")
    String cityId;
}

