package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.Event;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface EventRepository extends JpaRepository<Event, String>, JpaSpecificationExecutor<Event> {
    Optional<Event> findBySlug(String slug);
    
    boolean existsBySlug(String slug);
    
    @Query("SELECT COUNT(t) FROM Ticket t WHERE t.ticketType.event.id = :eventId AND t.status = 'CONFIRMED'")
    Long countSoldTickets(@Param("eventId") String eventId);
}

