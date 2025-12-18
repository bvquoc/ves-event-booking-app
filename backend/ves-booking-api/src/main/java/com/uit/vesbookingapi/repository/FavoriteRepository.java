package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavoriteRepository extends JpaRepository<Favorite, String> {
    Optional<Favorite> findByUserIdAndEventId(String userId, String eventId);

    boolean existsByUserIdAndEventId(String userId, String eventId);

    @Query("SELECT f.event.id FROM Favorite f WHERE f.user.id = :userId")
    List<String> findEventIdsByUserId(@Param("userId") String userId);
}

