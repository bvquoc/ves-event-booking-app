package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, String> {

    /**
     * Get all notifications for a user, ordered by newest first
     */
    @EntityGraph(attributePaths = {"data"})
    Page<Notification> findByUserIdOrderByCreatedAtDesc(String userId, Pageable pageable);

    /**
     * Get unread notifications for a user
     */
    @EntityGraph(attributePaths = {"data"})
    @Query("SELECT n FROM Notification n WHERE n.user.id = :userId AND n.isRead = false ORDER BY n.createdAt DESC")
    Page<Notification> findUnreadByUserId(@Param("userId") String userId, Pageable pageable);

    /**
     * Count unread notifications for a user
     */
    long countByUserIdAndIsRead(String userId, boolean isRead);

    /**
     * Mark all user notifications as read
     */
    @Transactional
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.user.id = :userId AND n.isRead = false")
    int markAllAsReadByUserId(@Param("userId") String userId);
}
