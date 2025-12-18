package com.uit.vesbookingapi.controller;

import com.uit.vesbookingapi.dto.request.ApiResponse;
import com.uit.vesbookingapi.dto.request.EventRequest;
import com.uit.vesbookingapi.dto.response.EventDetailResponse;
import com.uit.vesbookingapi.dto.response.EventResponse;
import com.uit.vesbookingapi.dto.response.PageResponse;
import com.uit.vesbookingapi.dto.response.TicketTypeResponse;
import com.uit.vesbookingapi.service.EventService;
import com.uit.vesbookingapi.service.TicketTypeService;
import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/events")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class EventController {
    EventService eventService;
    TicketTypeService ticketTypeService;

    @GetMapping
    public ApiResponse<PageResponse<EventResponse>> getEvents(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) Boolean trending,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String sortBy,
            @PageableDefault(size = 20) Pageable pageable) {
        return ApiResponse.<PageResponse<EventResponse>>builder()
                .result(eventService.getEvents(category, city, trending, startDate, endDate, search, sortBy, pageable))
                .build();
    }

    @GetMapping("/{eventId}")
    public ApiResponse<EventDetailResponse> getEventDetails(@PathVariable String eventId) {
        return ApiResponse.<EventDetailResponse>builder()
                .result(eventService.getEventDetails(eventId))
                .build();
    }

    @GetMapping("/search")
    public ApiResponse<PageResponse<EventResponse>> searchEvents(
            @RequestParam String q,
            @PageableDefault(size = 20) Pageable pageable) {
        return ApiResponse.<PageResponse<EventResponse>>builder()
                .result(eventService.getEvents(null, null, null, null, null, q, null, pageable))
                .build();
    }

    @GetMapping("/{eventId}/tickets")
    public ApiResponse<List<TicketTypeResponse>> getEventTickets(@PathVariable String eventId) {
        return ApiResponse.<List<TicketTypeResponse>>builder()
                .result(ticketTypeService.getTicketTypesByEvent(eventId))
                .build();
    }

    @PostMapping
    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<EventDetailResponse> createEvent(@Valid @RequestBody EventRequest request) {
        return ApiResponse.<EventDetailResponse>builder()
                .result(eventService.createEvent(request))
                .build();
    }

    @PutMapping("/{eventId}")
    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<EventDetailResponse> updateEvent(
            @PathVariable String eventId,
            @Valid @RequestBody EventRequest request) {
        return ApiResponse.<EventDetailResponse>builder()
                .result(eventService.updateEvent(eventId, request))
                .build();
    }

    @DeleteMapping("/{eventId}")
    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Void> deleteEvent(@PathVariable String eventId) {
        eventService.deleteEvent(eventId);
        return ApiResponse.<Void>builder().build();
    }
}

