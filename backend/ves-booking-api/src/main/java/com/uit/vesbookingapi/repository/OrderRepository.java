package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.Order;
import com.uit.vesbookingapi.enums.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, String>, JpaSpecificationExecutor<Order> {

    List<Order> findByUserIdOrderByCreatedAtDesc(String userId);

    List<Order> findByUserIdAndStatusOrderByCreatedAtDesc(String userId, OrderStatus status);

    // Find expired pending orders for cleanup
    @Query("SELECT o FROM Order o WHERE o.status = 'PENDING' AND o.expiresAt < :now")
    List<Order> findExpiredPendingOrders(@Param("now") LocalDateTime now);

    // ZaloPay-specific queries
    Optional<Order> findByAppTransId(String appTransId);

    // For reconciliation: find PENDING orders older than X minutes
    @Query("SELECT o FROM Order o WHERE o.status = 'PENDING' AND o.createdAt < :threshold")
    List<Order> findPendingOrdersOlderThan(@Param("threshold") LocalDateTime threshold);
}
