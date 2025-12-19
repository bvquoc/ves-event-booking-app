package com.uit.vesbookingapi.controller;

import com.uit.vesbookingapi.dto.request.ApiResponse;
import com.uit.vesbookingapi.dto.response.EventResponse;
import com.uit.vesbookingapi.dto.response.PageResponse;
import com.uit.vesbookingapi.service.FavoriteService;
import jakarta.validation.constraints.Pattern;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/favorites")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Validated
public class FavoriteController {
    FavoriteService favoriteService;

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<PageResponse<EventResponse>> getUserFavorites(
            @PageableDefault(size = 10) Pageable pageable) {
        return ApiResponse.<PageResponse<EventResponse>>builder()
                .result(favoriteService.getUserFavorites(pageable))
                .build();
    }

    @PostMapping("/{eventId}")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<Void> addFavorite(
            @PathVariable @Pattern(regexp = "^[a-fA-F0-9-]{36}$", message = "Invalid event ID format")
            String eventId) {
        favoriteService.addFavorite(eventId);
        return ApiResponse.<Void>builder()
                .message("Event added to favorites")
                .build();
    }

    @DeleteMapping("/{eventId}")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<Void> removeFavorite(
            @PathVariable @Pattern(regexp = "^[a-fA-F0-9-]{36}$", message = "Invalid event ID format")
            String eventId) {
        favoriteService.removeFavorite(eventId);
        return ApiResponse.<Void>builder()
                .message("Event removed from favorites")
                .build();
    }
}
