package com.uit.vesbookingapi.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class EventRequest {
    @NotBlank(message = "Event name is required")
    String name;

    @NotBlank(message = "Event slug is required")
    String slug;

    String description;
    String longDescription;

    @NotBlank(message = "Category ID is required")
    String categoryId;

    String thumbnail;
    List<String> images;

    @NotNull(message = "Start date is required")
    LocalDateTime startDate;

    LocalDateTime endDate;

    @NotBlank(message = "City ID is required")
    String cityId;

    String venueId;
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

    List<TicketTypeRequest> ticketTypes;
}

