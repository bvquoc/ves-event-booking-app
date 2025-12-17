package com.uit.vesbookingapi.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@Entity
public class TicketType {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    String id;

    @ManyToOne
    @JoinColumn(name = "event_id", nullable = false)
    Event event;

    @Column(nullable = false)
    String name; // "VIP TICKET", "STANDARD TICKET"

    @Column(columnDefinition = "TEXT")
    String description;

    @Column(nullable = false)
    Integer price;

    String currency;

    @Column(nullable = false)
    Integer available; // Available quantity

    Integer maxPerOrder;

    @ElementCollection
    @CollectionTable(name = "ticket_type_benefits", joinColumns = @JoinColumn(name = "ticket_type_id"))
    @Column(name = "benefit")
    List<String> benefits;

    @Column(nullable = false)
    Boolean requiresSeatSelection;
}
