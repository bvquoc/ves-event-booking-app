package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.PaymentTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PaymentTransactionRepository extends JpaRepository<PaymentTransaction, String> {
    List<PaymentTransaction> findByOrderIdOrderByCreatedAtDesc(String orderId);

    Optional<PaymentTransaction> findByAppTransId(String appTransId);
}
