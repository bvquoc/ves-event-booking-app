package com.uit.vesbookingapi.controller;

import com.uit.vesbookingapi.dto.request.ApiResponse;
import com.uit.vesbookingapi.dto.response.NotificationResponse;
import com.uit.vesbookingapi.dto.response.PageResponse;
import com.uit.vesbookingapi.service.NotificationService;
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
@RequestMapping("/notifications")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Validated
public class NotificationController {
    NotificationService notificationService;

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<PageResponse<NotificationResponse>> getUserNotifications(
            @RequestParam(required = false) Boolean unreadOnly,
            @PageableDefault(size = 20) Pageable pageable) {
        return ApiResponse.<PageResponse<NotificationResponse>>builder()
                .result(notificationService.getUserNotifications(unreadOnly, pageable))
                .build();
    }

    @PutMapping("/{notificationId}/read")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<Void> markAsRead(
            @PathVariable @Pattern(regexp = "^[a-fA-F0-9-]{36}$", message = "Invalid notification ID format")
            String notificationId) {
        notificationService.markAsRead(notificationId);
        return ApiResponse.<Void>builder()
                .message("Notification marked as read")
                .build();
    }

    @PutMapping("/read-all")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<Void> markAllAsRead() {
        notificationService.markAllAsRead();
        return ApiResponse.<Void>builder()
                .message("All notifications marked as read")
                .build();
    }
}
