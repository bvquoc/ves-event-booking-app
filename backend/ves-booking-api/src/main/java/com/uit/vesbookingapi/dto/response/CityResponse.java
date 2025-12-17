package com.uit.vesbookingapi.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CityResponse {
    String id;
    String name;
    String slug;
    Long eventCount;
}
