package com.uit.vesbookingapi.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class EventResponse {
    String id;
    String name;
    String slug;
    String description;
    String thumbnail;
    List<String> images;
    LocalDateTime startDate;
    LocalDateTime endDate;
    CategoryResponse category;
    CityResponse city;
    String venueId;
    String venueName;
    String venueAddress;
    String currency;
    Boolean isTrending;
    String organizerName;
    String organizerLogo;
    List<String> tags;

    // Calculated fields
    Integer minPrice;
    Integer maxPrice;
    Integer availableTickets;
    Boolean isFavorite;
}

