package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.Refund;
import com.uit.vesbookingapi.enums.RefundStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RefundRepository extends JpaRepository<Refund, String> {
    @Query("SELECT r FROM Refund r WHERE r.mRefundId = :mRefundId")
    Optional<Refund> findByMRefundId(@Param("mRefundId") String mRefundId);

    @Query("SELECT r FROM Refund r WHERE r.ticket.id = :ticketId")
    Optional<Refund> findByTicketId(@Param("ticketId") String ticketId);

    List<Refund> findByStatus(RefundStatus status);
}
