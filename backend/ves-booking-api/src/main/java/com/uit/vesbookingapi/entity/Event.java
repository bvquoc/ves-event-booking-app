package com.uit.vesbookingapi.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@Entity
@Table(indexes = {
        @Index(name = "idx_event_slug", columnList = "slug"),
        @Index(name = "idx_event_start_date", columnList = "startDate"),
        @Index(name = "idx_event_category", columnList = "category_id")
})
public class Event {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    String id;

    @Column(nullable = false)
    String name;

    @Column(unique = true, nullable = false)
    String slug;

    @Column(columnDefinition = "TEXT")
    String description;

    @Column(columnDefinition = "TEXT")
    String longDescription;

    @ManyToOne
    @JoinColumn(name = "category_id", nullable = false)
    Category category;

    String thumbnail; // URL

    @ElementCollection
    @CollectionTable(name = "event_images", joinColumns = @JoinColumn(name = "event_id"))
    @Column(name = "image_url")
    List<String> images;

    @Column(nullable = false)
    LocalDateTime startDate;

    LocalDateTime endDate;

    @ManyToOne
    @JoinColumn(name = "city_id", nullable = false)
    City city;

    @ManyToOne
    @JoinColumn(name = "venue_id")
    Venue venue;

    String venueName; // Denormalized for display
    String venueAddress;

    String currency;

    Boolean isTrending;

    String organizerId; // Future: link to Organizer entity
    String organizerName;
    String organizerLogo;

    @Column(columnDefinition = "TEXT")
    String terms;

    @Column(columnDefinition = "TEXT")
    String cancellationPolicy;

    @ElementCollection
    @CollectionTable(name = "event_tags", joinColumns = @JoinColumn(name = "event_id"))
    @Column(name = "tag")
    List<String> tags;

    @OneToMany(mappedBy = "event", cascade = CascadeType.ALL)
    List<TicketType> ticketTypes;

    @Column(nullable = false)
    LocalDateTime createdAt;

    LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
