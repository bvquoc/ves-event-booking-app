package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.Ticket;
import com.uit.vesbookingapi.enums.TicketStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TicketRepository extends JpaRepository<Ticket, String> {

    List<Ticket> findByUserIdOrderByPurchaseDateDesc(String userId);

    List<Ticket> findByUserIdAndStatusOrderByPurchaseDateDesc(String userId, TicketStatus status);

    List<Ticket> findByOrderId(String orderId);

    // Check if seats are occupied (sold or reserved) for a specific event
    @Query("SELECT t.seat.id FROM Ticket t WHERE t.event.id = :eventId AND t.seat.id IN :seatIds AND t.status IN ('ACTIVE', 'USED')")
    List<String> findOccupiedSeatIds(@Param("eventId") String eventId, @Param("seatIds") List<String> seatIds);
}
