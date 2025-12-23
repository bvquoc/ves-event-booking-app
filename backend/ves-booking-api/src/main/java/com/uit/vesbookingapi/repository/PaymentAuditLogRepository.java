package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.PaymentAuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PaymentAuditLogRepository extends JpaRepository<PaymentAuditLog, String> {
    List<PaymentAuditLog> findByOrderIdOrderByCreatedAtDesc(String orderId);

    List<PaymentAuditLog> findByAppTransIdOrderByCreatedAtDesc(String appTransId);
}
