package com.uit.vesbookingapi.mapper;

import com.uit.vesbookingapi.dto.response.NotificationResponse;
import com.uit.vesbookingapi.entity.Notification;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface NotificationMapper {
    NotificationResponse toNotificationResponse(Notification notification);
}
