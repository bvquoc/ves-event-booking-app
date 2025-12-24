package com.uit.vesbookingapi.dto.response;

import com.uit.vesbookingapi.enums.EventStatus;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class EventDetailResponse {
    String id;
    String name;
    String slug;
    String description;
    String longDescription;
    String thumbnail;
    List<String> images;
    LocalDateTime startDate;
    LocalDateTime endDate;
    CategoryResponse category;
    CityResponse city;
    String venueId;
    VenueSeatingResponse venue;
    String venueName;
    String venueAddress;
    String currency;
    Boolean isTrending;
    String organizerId;
    String organizerName;
    String organizerLogo;
    String terms;
    String cancellationPolicy;
    List<String> tags;
    List<TicketTypeResponse> ticketTypes;

    // Calculated fields
    EventStatus status;
    Integer minPrice;
    Integer maxPrice;
    Integer availableTickets;
    Boolean isFavorite;
    LocalDateTime createdAt;
    LocalDateTime updatedAt;
}

