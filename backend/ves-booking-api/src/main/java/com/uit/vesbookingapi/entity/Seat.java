package com.uit.vesbookingapi.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@Entity
public class Seat {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    String id;

    @ManyToOne
    @JoinColumn(name = "venue_id", nullable = false)
    Venue venue;

    @Column(nullable = false)
    String sectionName; // e.g., "VIP Section"

    @Column(nullable = false)
    String rowName; // e.g., "A"

    @Column(nullable = false)
    String seatNumber; // e.g., "A12"

    // Note: Status is per event, not stored here
    // Will be calculated in SeatAvailability service
}
