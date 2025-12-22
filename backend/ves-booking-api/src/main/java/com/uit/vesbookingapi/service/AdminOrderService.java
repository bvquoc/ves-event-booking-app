package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.response.AdminOrderResponse;
import com.uit.vesbookingapi.entity.Order;
import com.uit.vesbookingapi.enums.OrderStatus;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import com.uit.vesbookingapi.mapper.AdminOrderMapper;
import com.uit.vesbookingapi.repository.OrderRepository;
import jakarta.persistence.criteria.Predicate;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class AdminOrderService {
    OrderRepository orderRepository;
    AdminOrderMapper adminOrderMapper;

    /**
     * Get all orders with optional filters (Admin only)
     * Returns rich admin response with user, event, ticket type, and tickets information
     */
    @PreAuthorize("hasRole('ADMIN')")
    public Page<AdminOrderResponse> getAllOrders(
            String userId,
            String eventId,
            OrderStatus status,
            Pageable pageable) {
        
        Specification<Order> spec = buildSpecification(userId, eventId, status);
        Page<Order> orderPage = orderRepository.findAll(spec, pageable);

        return orderPage.map(order -> {
            AdminOrderResponse response = adminOrderMapper.toAdminOrderResponse(order);
            // Set zalopayTransactionId if exists (check for appTransId or zpTransId)
            // Note: This field may not exist in Order entity yet, so it will be null
            return response;
        });
    }

    /**
     * Get order details by ID (Admin can view any order)
     * Returns rich admin response with all related information
     */
    @PreAuthorize("hasRole('ADMIN')")
    public AdminOrderResponse getOrderDetails(String orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new AppException(ErrorCode.ORDER_NOT_FOUND));

        AdminOrderResponse response = adminOrderMapper.toAdminOrderResponse(order);
        // Set zalopayTransactionId if exists
        // Note: This field may not exist in Order entity yet, so it will be null
        return response;
    }

    /**
     * Build JPA Specification for filtering orders
     */
    private Specification<Order> buildSpecification(String userId, String eventId, OrderStatus status) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (userId != null && !userId.isEmpty()) {
                predicates.add(cb.equal(root.get("user").get("id"), userId));
            }

            if (eventId != null && !eventId.isEmpty()) {
                predicates.add(cb.equal(root.get("event").get("id"), eventId));
            }

            if (status != null) {
                predicates.add(cb.equal(root.get("status"), status));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}

