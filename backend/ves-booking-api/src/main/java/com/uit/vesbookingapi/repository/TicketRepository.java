package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.Ticket;
import com.uit.vesbookingapi.enums.OrderStatus;
import com.uit.vesbookingapi.enums.TicketStatus;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TicketRepository extends JpaRepository<Ticket, String>, JpaSpecificationExecutor<Ticket> {

    List<Ticket> findByUserIdOrderByPurchaseDateDesc(String userId);

    Page<Ticket> findByUserIdOrderByPurchaseDateDesc(String userId, Pageable pageable);

    List<Ticket> findByUserIdAndStatusOrderByPurchaseDateDesc(String userId, TicketStatus status);

    Page<Ticket> findByUserIdAndStatusOrderByPurchaseDateDesc(String userId, TicketStatus status, Pageable pageable);

    // Find tickets by order ID
    List<Ticket> findByOrderId(String orderId);

    // Find tickets by user and event (only from COMPLETED orders)
    @Query("SELECT t FROM Ticket t JOIN t.order o WHERE t.user.id = :userId AND t.event.id = :eventId AND o.status = 'COMPLETED' ORDER BY t.purchaseDate DESC")
    Page<Ticket> findByUserIdAndEventIdAndOrderCompletedOrderByPurchaseDateDesc(
            @Param("userId") String userId, 
            @Param("eventId") String eventId, 
            Pageable pageable);

    // Find tickets by user, event, and status (only from COMPLETED orders)
    @Query("SELECT t FROM Ticket t JOIN t.order o WHERE t.user.id = :userId AND t.event.id = :eventId AND t.status = :status AND o.status = 'COMPLETED' ORDER BY t.purchaseDate DESC")
    Page<Ticket> findByUserIdAndEventIdAndStatusAndOrderCompletedOrderByPurchaseDateDesc(
            @Param("userId") String userId, 
            @Param("eventId") String eventId, 
            @Param("status") TicketStatus status, 
            Pageable pageable);

    // Find tickets by user (only from COMPLETED orders)
    @Query("SELECT t FROM Ticket t JOIN t.order o WHERE t.user.id = :userId AND o.status = 'COMPLETED' ORDER BY t.purchaseDate DESC")
    Page<Ticket> findByUserIdAndOrderCompletedOrderByPurchaseDateDesc(
            @Param("userId") String userId, 
            Pageable pageable);

    // Find tickets by user and status (only from COMPLETED orders)
    @Query("SELECT t FROM Ticket t JOIN t.order o WHERE t.user.id = :userId AND t.status = :status AND o.status = 'COMPLETED' ORDER BY t.purchaseDate DESC")
    Page<Ticket> findByUserIdAndStatusAndOrderCompletedOrderByPurchaseDateDesc(
            @Param("userId") String userId, 
            @Param("status") TicketStatus status, 
            Pageable pageable);

    // Find ticket by QR code
    Optional<Ticket> findByQrCode(String qrCode);

    // Check if seats are occupied (sold or reserved) for a specific event
    @Query("SELECT t.seat.id FROM Ticket t WHERE t.event.id = :eventId AND t.seat.id IN :seatIds AND t.status IN ('ACTIVE', 'USED')")
    List<String> findOccupiedSeatIds(@Param("eventId") String eventId, @Param("seatIds") List<String> seatIds);

    // Check occupied seats with pessimistic locking to prevent double booking
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT t.seat.id FROM Ticket t WHERE t.event.id = :eventId AND t.seat.id IN :seatIds AND t.status IN ('ACTIVE', 'USED')")
    List<String> findOccupiedSeatIdsWithLock(@Param("eventId") String eventId, @Param("seatIds") List<String> seatIds);
}
