package com.uit.vesbookingapi.controller;

import com.uit.vesbookingapi.dto.request.ApiResponse;
import com.uit.vesbookingapi.dto.response.AdminTicketResponse;
import com.uit.vesbookingapi.enums.TicketStatus;
import com.uit.vesbookingapi.service.AdminTicketService;
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
@RequestMapping("/admin/tickets")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AdminTicketController {
    AdminTicketService adminTicketService;

    /**
     * Get all tickets with optional filters (Admin only)
     * 
     * Query Parameters:
     * - userId: Filter by user ID
     * - eventId: Filter by event ID
     * - status: Filter by ticket status (ACTIVE, USED, CANCELLED)
     * - page, size, sort: Standard pagination
     */
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Page<AdminTicketResponse>> getAllTickets(
            @RequestParam(required = false) String userId,
            @RequestParam(required = false) String eventId,
            @RequestParam(required = false) TicketStatus status,
            @PageableDefault(size = 20, sort = "purchaseDate", direction = Sort.Direction.DESC) Pageable pageable) {
        return ApiResponse.<Page<AdminTicketResponse>>builder()
                .result(adminTicketService.getAllTickets(userId, eventId, status, pageable))
                .build();
    }

    /**
     * Get ticket details by ID (Admin can view any ticket)
     * Returns rich admin response with user, order, event, and seat information
     */
    @GetMapping("/{ticketId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<AdminTicketResponse> getTicketDetails(@PathVariable String ticketId) {
        return ApiResponse.<AdminTicketResponse>builder()
                .result(adminTicketService.getTicketDetails(ticketId))
                .build();
    }
}

