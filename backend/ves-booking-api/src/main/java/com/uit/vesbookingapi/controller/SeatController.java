package com.uit.vesbookingapi.controller;

import com.uit.vesbookingapi.dto.request.ApiResponse;
import com.uit.vesbookingapi.dto.request.SeatRequest;
import com.uit.vesbookingapi.dto.response.SeatResponse;
import com.uit.vesbookingapi.service.SeatService;
import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/venues/{venueId}/seats")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class SeatController {
    SeatService seatService;

    @GetMapping
    public ApiResponse<List<SeatResponse>> getSeatsByVenue(@PathVariable String venueId) {
        return ApiResponse.<List<SeatResponse>>builder()
                .result(seatService.getSeatsByVenue(venueId))
                .build();
    }

    @GetMapping("/{seatId}")
    public ApiResponse<SeatResponse> getSeatById(@PathVariable String seatId) {
        return ApiResponse.<SeatResponse>builder()
                .result(seatService.getSeatById(seatId))
                .build();
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<SeatResponse> createSeat(
            @PathVariable String venueId,
            @Valid @RequestBody SeatRequest request) {
        return ApiResponse.<SeatResponse>builder()
                .result(seatService.createSeat(venueId, request))
                .build();
    }

    @PostMapping("/bulk")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<SeatResponse>> createBulkSeats(
            @PathVariable String venueId,
            @Valid @RequestBody List<SeatRequest> requests) {
        return ApiResponse.<List<SeatResponse>>builder()
                .result(seatService.createBulkSeats(venueId, requests))
                .build();
    }

    @PutMapping("/{seatId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<SeatResponse> updateSeat(
            @PathVariable String seatId,
            @Valid @RequestBody SeatRequest request) {
        return ApiResponse.<SeatResponse>builder()
                .result(seatService.updateSeat(seatId, request))
                .build();
    }

    @DeleteMapping("/{seatId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Void> deleteSeat(@PathVariable String seatId) {
        seatService.deleteSeat(seatId);
        return ApiResponse.<Void>builder().build();
    }
}

