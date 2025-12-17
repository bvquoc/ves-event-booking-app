package com.uit.vesbookingapi.controller;

import com.uit.vesbookingapi.dto.request.ApiResponse;
import com.uit.vesbookingapi.dto.response.VenueResponse;
import com.uit.vesbookingapi.dto.response.VenueSeatingResponse;
import com.uit.vesbookingapi.service.VenueService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
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

    @GetMapping("/{venueId}/seats")
    public ApiResponse<VenueSeatingResponse> getVenueSeating(
            @PathVariable String venueId,
            @RequestParam String eventId) {
        return ApiResponse.<VenueSeatingResponse>builder()
                .result(venueService.getVenueSeating(venueId, eventId))
                .build();
    }
}
