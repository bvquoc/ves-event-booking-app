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

    // Find seats that are sold for a specific event
    // SOLD: (Ticket USED - event happened) OR (Ticket ACTIVE AND Order COMPLETED - payment done)
    // Note: USED tickets are always sold regardless of order status (event already happened)
    //       ACTIVE tickets are sold only if order is COMPLETED (payment completed)
    @Query("SELECT DISTINCT t.seat.id FROM Ticket t JOIN t.order o WHERE t.event.id = :eventId " +
           "AND t.seat.id IS NOT NULL " +
           "AND (t.status = 'USED' OR (t.status = 'ACTIVE' AND o.status = 'COMPLETED'))")
    List<String> findSoldSeatIdsByEvent(@Param("eventId") String eventId);

    // Find seats that are reserved (order PENDING and not expired)
    // RESERVED: Tickets with ACTIVE status AND order is PENDING (payment not completed yet)
    @Query("SELECT t.seat.id FROM Ticket t JOIN t.order o WHERE t.event.id = :eventId " +
           "AND o.status = 'PENDING' AND o.expiresAt > :now")
    List<String> findReservedSeatIdsByEvent(@Param("eventId") String eventId, @Param("now") LocalDateTime now);
}