package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.response.NotificationResponse;
import com.uit.vesbookingapi.dto.response.PageResponse;
import com.uit.vesbookingapi.entity.Notification;
import com.uit.vesbookingapi.entity.Order;
import com.uit.vesbookingapi.entity.User;
import com.uit.vesbookingapi.enums.NotificationType;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import com.uit.vesbookingapi.mapper.NotificationMapper;
import com.uit.vesbookingapi.repository.NotificationRepository;
import com.uit.vesbookingapi.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class NotificationService {
    NotificationRepository notificationRepository;
    NotificationMapper notificationMapper;
    UserRepository userRepository;

    /**
     * Get user's notifications with optional filter
     */
    public PageResponse<NotificationResponse> getUserNotifications(Boolean unreadOnly, Pageable pageable) {
        String userId = getCurrentUserId();

        Page<Notification> notifications;
        if (Boolean.TRUE.equals(unreadOnly)) {
            notifications = notificationRepository.findUnreadByUserId(userId, pageable);
        } else {
            notifications = notificationRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
        }

        Page<NotificationResponse> notificationResponses = notifications.map(notificationMapper::toNotificationResponse);

        return PageResponse.<NotificationResponse>builder()
                .content(notificationResponses.getContent())
                .page(notificationResponses.getNumber() + 1)
                .size(notificationResponses.getSize())
                .totalElements(notificationResponses.getTotalElements())
                .totalPages(notificationResponses.getTotalPages())
                .first(notificationResponses.isFirst())
                .last(notificationResponses.isLast())
                .build();
    }

    /**
     * Mark a notification as read
     */
    @Transactional
    public void markAsRead(String notificationId) {
        String userId = getCurrentUserId();

        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new AppException(ErrorCode.NOTIFICATION_NOT_FOUND));

        // Verify notification belongs to user
        if (!notification.getUser().getId().equals(userId)) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }

        notification.setIsRead(true);
        notificationRepository.save(notification);
    }

    /**
     * Mark all user notifications as read
     */
    @Transactional
    public void markAllAsRead() {
        String userId = getCurrentUserId();
        notificationRepository.markAllAsReadByUserId(userId);
    }

    /**
     * Get unread notification count
     */
    public long getUnreadCount() {
        String userId = getCurrentUserId();
        return notificationRepository.countByUserIdAndIsRead(userId, false);
    }

    /**
     * Create notification for ticket purchase
     */
    @Transactional
    public void notifyTicketPurchased(Order order) {
        Notification notification = Notification.builder()
                .user(order.getUser())
                .type(NotificationType.TICKET_PURCHASED)
                .title("Mua vé thành công")
                .message("Bạn đã mua " + order.getQuantity() + " vé cho sự kiện '" + order.getEvent().getName() + "'")
                .data(Map.of(
                        "orderId", order.getId(),
                        "eventId", order.getEvent().getId(),
                        "ticketCount", order.getQuantity().toString()
                ))
                .build();

        notificationRepository.save(notification);
    }

    /**
     * Create notification for event reminder (future enhancement)
     */
    @Transactional
    public void notifyEventReminder(User user, String eventId, String eventName) {
        Notification notification = Notification.builder()
                .user(user)
                .type(NotificationType.EVENT_REMINDER)
                .title("Nhắc nhở sự kiện")
                .message("Sự kiện '" + eventName + "' sẽ diễn ra trong 24 giờ nữa!")
                .data(Map.of("eventId", eventId))
                .build();

        notificationRepository.save(notification);
    }

    /**
     * Create notification for event cancellation
     */
    @Transactional
    public void notifyEventCancelled(User user, String eventId, String eventName) {
        Notification notification = Notification.builder()
                .user(user)
                .type(NotificationType.EVENT_CANCELLED)
                .title("Sự kiện đã bị hủy")
                .message("Rất tiếc, sự kiện '" + eventName + "' đã bị hủy. Bạn sẽ được hoàn tiền.")
                .data(Map.of("eventId", eventId))
                .build();

        notificationRepository.save(notification);
    }

    /**
     * Create promotion notification
     */
    @Transactional
    public void notifyPromotion(User user, String title, String message, Map<String, String> data) {
        Notification notification = Notification.builder()
                .user(user)
                .type(NotificationType.PROMOTION)
                .title(title)
                .message(message)
                .data(data)
                .build();

        notificationRepository.save(notification);
    }

    /**
     * Create system notification
     */
    @Transactional
    public void notifySystem(User user, String title, String message, Map<String, String> data) {
        Notification notification = Notification.builder()
                .user(user)
                .type(NotificationType.SYSTEM)
                .title(title)
                .message(message)
                .data(data)
                .build();

        notificationRepository.save(notification);
    }

    /**
     * Get current authenticated user ID
     */
    private String getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null
                || !authentication.isAuthenticated()
                || authentication instanceof AnonymousAuthenticationToken) {
            throw new AppException(ErrorCode.UNAUTHENTICATED);
        }
        // authentication.getName() returns username, not user ID
        String username = authentication.getName();
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED))
                .getId();
    }
}
