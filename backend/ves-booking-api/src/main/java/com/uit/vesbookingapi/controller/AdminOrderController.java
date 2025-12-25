package com.uit.vesbookingapi.controller;

import com.uit.vesbookingapi.dto.request.ApiResponse;
import com.uit.vesbookingapi.dto.response.AdminOrderResponse;
import com.uit.vesbookingapi.enums.OrderStatus;
import com.uit.vesbookingapi.service.AdminOrderService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin/orders")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AdminOrderController {
    AdminOrderService adminOrderService;

    /**
     * Get all orders with optional filters (Admin only)
     * <p>
     * Query Parameters:
     * - userId: Filter by user ID
     * - eventId: Filter by event ID
     * - status: Filter by order status (PENDING, COMPLETED, CANCELLED, EXPIRED)
     * - page, size, sort: Standard pagination
     */
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Page<AdminOrderResponse>> getAllOrders(
            @RequestParam(required = false) String userId,
            @RequestParam(required = false) String eventId,
            @RequestParam(required = false) OrderStatus status,
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ApiResponse.<Page<AdminOrderResponse>>builder()
                .result(adminOrderService.getAllOrders(userId, eventId, status, pageable))
                .build();
    }

    /**
     * Get order details by ID (Admin can view any order)
     * Returns rich admin response with user, event, ticket type, and tickets information
     */
    @GetMapping("/{orderId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<AdminOrderResponse> getOrderDetails(@PathVariable String orderId) {
        return ApiResponse.<AdminOrderResponse>builder()
                .result(adminOrderService.getOrderDetails(orderId))
                .build();
    }
}

