package com.uit.vesbookingapi.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class TicketTypeResponse {
    String id;
    String name;
    String description;
    Integer price;
    String currency;
    Integer available;
    Integer maxPerOrder;
    List<String> benefits;
    Boolean requiresSeatSelection;
}

