package com.uit.vesbookingapi.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class TicketTypeRequest {
    @NotBlank(message = "Ticket type name is required")
    String name;
    
    String description;
    
    @NotNull(message = "Price is required")
    @Positive(message = "Price must be positive")
    Integer price;
    
    String currency;
    
    @NotNull(message = "Available quantity is required")
    @Positive(message = "Available quantity must be positive")
    Integer available;
    
    Integer maxPerOrder;
    
    List<String> benefits;
    
    @NotNull(message = "Requires seat selection flag is required")
    Boolean requiresSeatSelection;
}

