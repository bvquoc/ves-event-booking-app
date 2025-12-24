package com.uit.vesbookingapi.controller;

import com.uit.vesbookingapi.dto.request.ApiResponse;
import com.uit.vesbookingapi.dto.request.CancelTicketRequest;
import com.uit.vesbookingapi.dto.request.PurchaseRequest;
import com.uit.vesbookingapi.dto.response.CancellationResponse;
import com.uit.vesbookingapi.dto.response.PurchaseResponse;
import com.uit.vesbookingapi.dto.response.TicketDetailResponse;
import com.uit.vesbookingapi.dto.response.TicketResponse;
import com.uit.vesbookingapi.enums.TicketStatus;
import com.uit.vesbookingapi.service.BookingService;
import com.uit.vesbookingapi.service.TicketService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
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
@RequestMapping("/tickets")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class TicketController {
    BookingService bookingService;
    TicketService ticketService;

    @PostMapping("/purchase")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<PurchaseResponse> purchaseTickets(
            @Valid @RequestBody PurchaseRequest request,
            HttpServletRequest httpRequest) {
        String clientIp = getClientIp(httpRequest);
        return ApiResponse.<PurchaseResponse>builder()
                .result(bookingService.purchaseTickets(request, clientIp))
                .build();
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty()) {
            ip = request.getRemoteAddr();
        } else {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<Page<TicketResponse>> getUserTickets(
            @RequestParam(required = false) String eventId,
            @RequestParam(required = false) TicketStatus status,
            @PageableDefault(size = 10, sort = "purchaseDate", direction = Sort.Direction.DESC) Pageable pageable) {
        return ApiResponse.<Page<TicketResponse>>builder()
                .result(ticketService.getUserTickets(eventId, status, pageable))
                .build();
    }

    @GetMapping("/{ticketId}")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<TicketDetailResponse> getTicketDetails(@PathVariable String ticketId) {
        return ApiResponse.<TicketDetailResponse>builder()
                .result(ticketService.getTicketDetails(ticketId))
                .build();
    }

    @PutMapping("/{ticketId}/cancel")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<CancellationResponse> cancelTicket(
            @PathVariable String ticketId,
            @RequestBody(required = false) CancelTicketRequest request) {
        if (request == null) {
            request = new CancelTicketRequest();
        }
        return ApiResponse.<CancellationResponse>builder()
                .result(ticketService.cancelTicket(ticketId, request))
                .build();
    }
}
