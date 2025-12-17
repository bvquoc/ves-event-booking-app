package com.uit.vesbookingapi.controller;

import com.uit.vesbookingapi.dto.request.ApiResponse;
import com.uit.vesbookingapi.dto.request.PurchaseRequest;
import com.uit.vesbookingapi.dto.response.PurchaseResponse;
import com.uit.vesbookingapi.service.BookingService;
import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/tickets")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class TicketController {
    BookingService bookingService;

    @PostMapping("/purchase")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<PurchaseResponse> purchaseTickets(@Valid @RequestBody PurchaseRequest request) {
        return ApiResponse.<PurchaseResponse>builder()
                .result(bookingService.purchaseTickets(request))
                .build();
    }
}
