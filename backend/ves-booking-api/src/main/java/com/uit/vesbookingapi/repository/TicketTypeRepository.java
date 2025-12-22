package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.TicketType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TicketTypeRepository extends JpaRepository<TicketType, String> {
    List<TicketType> findByEventId(String eventId);

    @Query("SELECT MIN(tt.price) FROM TicketType tt WHERE tt.event.id = :eventId")
    Integer findMinPriceByEventId(@Param("eventId") String eventId);

    @Query("SELECT MAX(tt.price) FROM TicketType tt WHERE tt.event.id = :eventId")
    Integer findMaxPriceByEventId(@Param("eventId") String eventId);

    @Query("SELECT SUM(tt.available) FROM TicketType tt WHERE tt.event.id = :eventId")
    Integer sumAvailableTicketsByEventId(@Param("eventId") String eventId);

    @Query("SELECT tt FROM TicketType tt WHERE tt.event.id IN :eventIds")
    List<TicketType> findByEventIdIn(@Param("eventIds") List<String> eventIds);

    @Modifying
    @Query("UPDATE TicketType tt SET tt.available = tt.available + :increment WHERE tt.id = :ticketTypeId")
    int incrementAvailable(@Param("ticketTypeId") String ticketTypeId, @Param("increment") int increment);
}

