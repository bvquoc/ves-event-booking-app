package com.uit.vesbookingapi.controller;

import com.uit.vesbookingapi.dto.request.ApiResponse;
import com.uit.vesbookingapi.dto.request.VenueRequest;
import com.uit.vesbookingapi.dto.response.VenueResponse;
import com.uit.vesbookingapi.dto.response.VenueSeatingResponse;
import com.uit.vesbookingapi.service.VenueService;
import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/venues")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class VenueController {
    VenueService venueService;

    @GetMapping
    public ApiResponse<List<VenueResponse>> getAllVenues() {
        return ApiResponse.<List<VenueResponse>>builder()
                .result(venueService.getAllVenues())
                .build();
    }

    @GetMapping("/{venueId}")
    public ApiResponse<VenueResponse> getVenueById(@PathVariable String venueId) {
        return ApiResponse.<VenueResponse>builder()
                .result(venueService.getVenueById(venueId))
                .build();
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<VenueResponse> createVenue(@Valid @RequestBody VenueRequest request) {
        return ApiResponse.<VenueResponse>builder()
                .result(venueService.createVenue(request))
                .build();
    }

    @PutMapping("/{venueId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<VenueResponse> updateVenue(
            @PathVariable String venueId,
            @Valid @RequestBody VenueRequest request) {
        return ApiResponse.<VenueResponse>builder()
                .result(venueService.updateVenue(venueId, request))
                .build();
    }

    @DeleteMapping("/{venueId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Void> deleteVenue(@PathVariable String venueId) {
        venueService.deleteVenue(venueId);
        return ApiResponse.<Void>builder().build();
    }

    @GetMapping("/{venueId}/seats")
    public ApiResponse<VenueSeatingResponse> getVenueSeating(
            @PathVariable String venueId,
            @RequestParam String eventId) {
        return ApiResponse.<VenueSeatingResponse>builder()
                .result(venueService.getVenueSeating(venueId, eventId))
                .build();
    }
}
