package com.uit.vesbookingapi.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CityRequest {
    @NotBlank(message = "City name is required")
    String name;

    @NotBlank(message = "City slug is required")
    String slug;
}

