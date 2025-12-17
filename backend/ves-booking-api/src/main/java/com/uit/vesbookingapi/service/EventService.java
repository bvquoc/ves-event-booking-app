package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.request.EventRequest;
import com.uit.vesbookingapi.dto.response.*;
import com.uit.vesbookingapi.entity.*;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import com.uit.vesbookingapi.mapper.EventMapper;
import com.uit.vesbookingapi.mapper.TicketTypeMapper;
import com.uit.vesbookingapi.repository.*;
import com.uit.vesbookingapi.utils.EventSpecification;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class EventService {
    EventRepository eventRepository;
    TicketTypeRepository ticketTypeRepository;
    CategoryRepository categoryRepository;
    CityRepository cityRepository;
    VenueRepository venueRepository;
    FavoriteRepository favoriteRepository;
    UserRepository userRepository;
    EventMapper eventMapper;
    TicketTypeMapper ticketTypeMapper;

    public PageResponse<EventResponse> getEvents(
            String categoryId,
            String cityId,
            Boolean trending,
            LocalDateTime startDate,
            LocalDateTime endDate,
            String search,
            String sortBy,
            Pageable pageable) {
        
        // Build specification
        Specification<Event> spec = EventSpecification.combine(
                EventSpecification.hasCategory(categoryId),
                EventSpecification.hasCity(cityId),
                EventSpecification.isTrending(trending),
                EventSpecification.inDateRange(startDate, endDate),
                EventSpecification.searchByKeyword(search)
        );
        
        // Apply sorting
        Pageable sortedPageable = applySorting(pageable, sortBy);
        
        // Query with pagination
        Page<Event> eventPage = eventRepository.findAll(spec, sortedPageable);
        
        // Get current user ID if authenticated
        String currentUserId = getCurrentUserId();
        
        // Get favorite event IDs for current user
        Set<String> favoriteEventIds = currentUserId != null 
                ? new HashSet<>(favoriteRepository.findEventIdsByUserId(currentUserId))
                : Collections.emptySet();
        
        // Map to response with calculated fields
        List<EventResponse> eventResponses = eventPage.getContent().stream()
                .map(event -> {
                    EventResponse response = eventMapper.toEventResponse(event);
                    enrichEventResponse(response, event, favoriteEventIds);
                    return response;
                })
                .collect(Collectors.toList());
        
        return PageResponse.<EventResponse>builder()
                .content(eventResponses)
                .page(eventPage.getNumber())
                .size(eventPage.getSize())
                .totalElements(eventPage.getTotalElements())
                .totalPages(eventPage.getTotalPages())
                .first(eventPage.isFirst())
                .last(eventPage.isLast())
                .build();
    }
    
    public EventDetailResponse getEventDetails(String eventId) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new AppException(ErrorCode.EVENT_NOT_FOUND));
        
        // Load ticket types
        List<TicketType> ticketTypes = ticketTypeRepository.findByEventId(eventId);
        event.setTicketTypes(ticketTypes);
        
        // Get current user ID if authenticated
        String currentUserId = getCurrentUserId();
        boolean isFavorite = currentUserId != null 
                && favoriteRepository.existsByUserIdAndEventId(currentUserId, eventId);
        
        EventDetailResponse response = eventMapper.toEventDetailResponse(event);
        
        // Set venue to null (VenueSeatingResponse requires VenueService call, can be added later if needed)
        response.setVenue(null);
        
        // Map ticket types
        List<TicketTypeResponse> ticketTypeResponses = ticketTypes.stream()
                .map(ticketTypeMapper::toTicketTypeResponse)
                .collect(Collectors.toList());
        response.setTicketTypes(ticketTypeResponses);
        
        // Calculate dynamic fields
        enrichEventDetailResponse(response, event, isFavorite);
        
        return response;
    }
    
    public List<TicketTypeResponse> getEventTickets(String eventId) {
        if (!eventRepository.existsById(eventId)) {
            throw new AppException(ErrorCode.EVENT_NOT_FOUND);
        }
        
        List<TicketType> ticketTypes = ticketTypeRepository.findByEventId(eventId);
        return ticketTypes.stream()
                .map(ticketTypeMapper::toTicketTypeResponse)
                .collect(Collectors.toList());
    }
    
    @Transactional
    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ADMIN')")
    public EventDetailResponse createEvent(EventRequest request) {
        // Validate slug uniqueness
        if (eventRepository.existsBySlug(request.getSlug())) {
            throw new AppException(ErrorCode.EVENT_SLUG_EXISTED);
        }
        
        // Validate category exists
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new AppException(ErrorCode.CATEGORY_NOT_FOUND));
        
        // Validate city exists
        City city = cityRepository.findById(request.getCityId())
                .orElseThrow(() -> new AppException(ErrorCode.CITY_NOT_FOUND));
        
        // Validate venue if provided
        Venue venue = null;
        if (request.getVenueId() != null && !request.getVenueId().isEmpty()) {
            venue = venueRepository.findById(request.getVenueId())
                    .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
        }
        
        // Validate date range
        if (request.getEndDate() != null && request.getStartDate().isAfter(request.getEndDate())) {
            throw new AppException(ErrorCode.INVALID_EVENT_DATE);
        }
        
        // Map request to entity
        Event event = eventMapper.toEvent(request);
        event.setCategory(category);
        event.setCity(city);
        event.setVenue(venue);
        
        // Save event first
        Event savedEvent = eventRepository.save(event);
        
        // Create ticket types
        if (request.getTicketTypes() != null && !request.getTicketTypes().isEmpty()) {
            final Event finalEvent = savedEvent;
            List<TicketType> ticketTypes = request.getTicketTypes().stream()
                    .map(ttRequest -> {
                        TicketType ticketType = ticketTypeMapper.toTicketType(ttRequest);
                        ticketType.setEvent(finalEvent);
                        return ticketType;
                    })
                    .collect(Collectors.toList());
            ticketTypeRepository.saveAll(ticketTypes);
            savedEvent.setTicketTypes(ticketTypes);
        }
        
        event = savedEvent;
        
        EventDetailResponse response = eventMapper.toEventDetailResponse(event);
        
        // Set venue to null (VenueSeatingResponse requires VenueService call, can be added later if needed)
        response.setVenue(null);
        
        // Map ticket types
        if (event.getTicketTypes() != null) {
            List<TicketTypeResponse> ticketTypeResponses = event.getTicketTypes().stream()
                    .map(ticketTypeMapper::toTicketTypeResponse)
                    .collect(Collectors.toList());
            response.setTicketTypes(ticketTypeResponses);
        }
        
        enrichEventDetailResponse(response, event, false);
        
        return response;
    }
    
    @Transactional
    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ADMIN')")
    public EventDetailResponse updateEvent(String eventId, EventRequest request) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new AppException(ErrorCode.EVENT_NOT_FOUND));
        
        // Validate slug uniqueness if changed
        if (!event.getSlug().equals(request.getSlug()) && eventRepository.existsBySlug(request.getSlug())) {
            throw new AppException(ErrorCode.EVENT_SLUG_EXISTED);
        }
        
        // Validate category exists
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new AppException(ErrorCode.CATEGORY_NOT_FOUND));
        
        // Validate city exists
        City city = cityRepository.findById(request.getCityId())
                .orElseThrow(() -> new AppException(ErrorCode.CITY_NOT_FOUND));
        
        // Validate venue if provided
        Venue venue = null;
        if (request.getVenueId() != null && !request.getVenueId().isEmpty()) {
            venue = venueRepository.findById(request.getVenueId())
                    .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
        }
        
        // Validate date range
        if (request.getEndDate() != null && request.getStartDate().isAfter(request.getEndDate())) {
            throw new AppException(ErrorCode.INVALID_EVENT_DATE);
        }
        
        // Update event
        eventMapper.updateEvent(event, request);
        event.setCategory(category);
        event.setCity(city);
        event.setVenue(venue);
        
        // Update ticket types (delete old ones and create new ones)
        ticketTypeRepository.deleteAll(event.getTicketTypes());
        final Event finalEvent = event;
        if (request.getTicketTypes() != null && !request.getTicketTypes().isEmpty()) {
            List<TicketType> ticketTypes = request.getTicketTypes().stream()
                    .map(ttRequest -> {
                        TicketType ticketType = ticketTypeMapper.toTicketType(ttRequest);
                        ticketType.setEvent(finalEvent);
                        return ticketType;
                    })
                    .collect(Collectors.toList());
            ticketTypeRepository.saveAll(ticketTypes);
            event.setTicketTypes(ticketTypes);
        } else {
            event.setTicketTypes(Collections.emptyList());
        }
        
        event = eventRepository.save(event);
        
        EventDetailResponse response = eventMapper.toEventDetailResponse(event);
        
        // Set venue to null (VenueSeatingResponse requires VenueService call, can be added later if needed)
        response.setVenue(null);
        
        // Map ticket types
        if (event.getTicketTypes() != null) {
            List<TicketTypeResponse> ticketTypeResponses = event.getTicketTypes().stream()
                    .map(ticketTypeMapper::toTicketTypeResponse)
                    .collect(Collectors.toList());
            response.setTicketTypes(ticketTypeResponses);
        }
        
        enrichEventDetailResponse(response, event, false);
        
        return response;
    }
    
    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ADMIN')")
    public void deleteEvent(String eventId) {
        if (!eventRepository.existsById(eventId)) {
            throw new AppException(ErrorCode.EVENT_NOT_FOUND);
        }
        eventRepository.deleteById(eventId);
    }
    
    private Pageable applySorting(Pageable pageable, String sortBy) {
        if (sortBy == null || sortBy.isEmpty()) {
            return pageable;
        }
        
        Sort sort;
        switch (sortBy.toLowerCase()) {
            case "date":
                sort = Sort.by(Sort.Direction.ASC, "startDate");
                break;
            case "popularity":
                // For popularity, we'll sort by createdAt as a proxy (can be enhanced with actual sales data)
                sort = Sort.by(Sort.Direction.DESC, "createdAt");
                break;
            case "price_low":
                // Price sorting requires custom query, for now use createdAt
                sort = Sort.by(Sort.Direction.ASC, "createdAt");
                break;
            case "price_high":
                sort = Sort.by(Sort.Direction.DESC, "createdAt");
                break;
            case "newest":
                sort = Sort.by(Sort.Direction.DESC, "createdAt");
                break;
            default:
                sort = Sort.by(Sort.Direction.DESC, "createdAt");
        }
        
        return PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(), sort);
    }
    
    private void enrichEventResponse(EventResponse response, Event event, Set<String> favoriteEventIds) {
        // Calculate min/max price and available tickets
        Integer minPrice = ticketTypeRepository.findMinPriceByEventId(event.getId());
        Integer maxPrice = ticketTypeRepository.findMaxPriceByEventId(event.getId());
        Integer availableTickets = ticketTypeRepository.sumAvailableTicketsByEventId(event.getId());
        
        response.setMinPrice(minPrice);
        response.setMaxPrice(maxPrice);
        response.setAvailableTickets(availableTickets != null ? availableTickets : 0);
        response.setIsFavorite(favoriteEventIds.contains(event.getId()));
    }
    
    private void enrichEventDetailResponse(EventDetailResponse response, Event event, boolean isFavorite) {
        // Calculate min/max price and available tickets
        Integer minPrice = ticketTypeRepository.findMinPriceByEventId(event.getId());
        Integer maxPrice = ticketTypeRepository.findMaxPriceByEventId(event.getId());
        Integer availableTickets = ticketTypeRepository.sumAvailableTicketsByEventId(event.getId());
        
        response.setMinPrice(minPrice);
        response.setMaxPrice(maxPrice);
        response.setAvailableTickets(availableTickets != null ? availableTickets : 0);
        response.setIsFavorite(isFavorite);
    }
    
    private String getCurrentUserId() {
        try {
            var context = SecurityContextHolder.getContext();
            if (context.getAuthentication() == null || !context.getAuthentication().isAuthenticated()) {
                return null;
            }
            String username = context.getAuthentication().getName();
            return userRepository.findByUsername(username)
                    .map(User::getId)
                    .orElse(null);
        } catch (Exception e) {
            return null;
        }
    }
}

