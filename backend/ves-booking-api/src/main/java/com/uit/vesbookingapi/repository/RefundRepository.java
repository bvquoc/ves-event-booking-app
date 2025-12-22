package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.Refund;
import com.uit.vesbookingapi.enums.RefundStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RefundRepository extends JpaRepository<Refund, String> {
    Optional<Refund> findByMRefundId(String mRefundId);

    Optional<Refund> findByTicketId(String ticketId);

    List<Refund> findByStatus(RefundStatus status);
}
