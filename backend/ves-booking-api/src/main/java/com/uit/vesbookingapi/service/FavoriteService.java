package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.response.EventResponse;
import com.uit.vesbookingapi.dto.response.PageResponse;
import com.uit.vesbookingapi.entity.Event;
import com.uit.vesbookingapi.entity.Favorite;
import com.uit.vesbookingapi.entity.User;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import com.uit.vesbookingapi.mapper.EventMapper;
import com.uit.vesbookingapi.repository.EventRepository;
import com.uit.vesbookingapi.repository.FavoriteRepository;
import com.uit.vesbookingapi.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class FavoriteService {
    FavoriteRepository favoriteRepository;
    EventRepository eventRepository;
    UserRepository userRepository;
    EventMapper eventMapper;

    /**
     * Get user's favorite events
     */
    public PageResponse<EventResponse> getUserFavorites(Pageable pageable) {
        String userId = getCurrentUserId();

        Page<Favorite> favorites = favoriteRepository.findByUserIdWithEvent(userId, pageable);

        Page<EventResponse> eventResponses = favorites.map(favorite -> {
            EventResponse response = eventMapper.toEventResponse(favorite.getEvent());
            response.setIsFavorite(true); // All favorites are obviously favorited
            return response;
        });

        return PageResponse.<EventResponse>builder()
                .content(eventResponses.getContent())
                .page(eventResponses.getNumber() + 1)
                .size(eventResponses.getSize())
                .totalElements(eventResponses.getTotalElements())
                .totalPages(eventResponses.getTotalPages())
                .first(eventResponses.isFirst())
                .last(eventResponses.isLast())
                .build();
    }

    /**
     * Add event to favorites
     */
    @Transactional
    public void addFavorite(String eventId) {
        String userId = getCurrentUserId();

        // Verify event exists
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new AppException(ErrorCode.EVENT_NOT_FOUND));

        // Get user
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));

        // Create favorite (handle race condition with try-catch)
        Favorite favorite = Favorite.builder()
                .user(user)
                .event(event)
                .build();

        try {
            favoriteRepository.save(favorite);
        } catch (DataIntegrityViolationException e) {
            // Silently ignore duplicates (idempotent operation)
            log.debug("Duplicate favorite ignored: user={}, event={}", userId, eventId);
        }
    }

    /**
     * Remove event from favorites
     */
    @Transactional
    public void removeFavorite(String eventId) {
        String userId = getCurrentUserId();

        Favorite favorite = favoriteRepository.findByUserIdAndEventId(userId, eventId)
                .orElseThrow(() -> new AppException(ErrorCode.FAVORITE_NOT_FOUND));

        favoriteRepository.delete(favorite);
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
        return authentication.getName();
    }
}
