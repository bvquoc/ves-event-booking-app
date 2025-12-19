package com.uit.vesbookingapi.dto.response;

import com.uit.vesbookingapi.enums.NotificationType;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class NotificationResponse {
    String id;
    NotificationType type;
    String title;
    String message;
    Boolean isRead;
    Map<String, String> data;
    LocalDateTime createdAt;
}
