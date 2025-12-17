package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.Seat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface SeatRepository extends JpaRepository<Seat, String> {

    List<Seat> findByVenueId(String venueId);

    // Find seats that are sold for a specific event (ticket status ACTIVE or USED)
    @Query("SELECT t.seat.id FROM Ticket t WHERE t.event.id = :eventId AND t.status IN ('ACTIVE', 'USED')")
    List<String> findSoldSeatIdsByEvent(@Param("eventId") String eventId);

    // Find seats that are reserved (order PENDING and not expired)
    @Query("SELECT t.seat.id FROM Ticket t JOIN t.order o WHERE t.event.id = :eventId AND o.status = 'PENDING' AND o.expiresAt > :now")
    List<String> findReservedSeatIdsByEvent(@Param("eventId") String eventId, @Param("now") LocalDateTime now);
}
