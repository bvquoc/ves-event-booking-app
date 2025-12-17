package com.uit.vesbookingapi.mapper;

import com.uit.vesbookingapi.dto.request.EventRequest;
import com.uit.vesbookingapi.dto.response.EventDetailResponse;
import com.uit.vesbookingapi.dto.response.EventResponse;
import com.uit.vesbookingapi.entity.Event;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring", uses = {CategoryMapper.class, CityMapper.class})
public interface EventMapper {
    @Mapping(target = "category", ignore = true)
    @Mapping(target = "city", ignore = true)
    @Mapping(target = "venue", ignore = true)
    @Mapping(target = "ticketTypes", ignore = true)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Event toEvent(EventRequest request);
    
    @Mapping(target = "minPrice", ignore = true)
    @Mapping(target = "maxPrice", ignore = true)
    @Mapping(target = "availableTickets", ignore = true)
    @Mapping(target = "isFavorite", ignore = true)
    EventResponse toEventResponse(Event event);
    
    @Mapping(target = "minPrice", ignore = true)
    @Mapping(target = "maxPrice", ignore = true)
    @Mapping(target = "availableTickets", ignore = true)
    @Mapping(target = "isFavorite", ignore = true)
    EventDetailResponse toEventDetailResponse(Event event);
    
    @Mapping(target = "category", ignore = true)
    @Mapping(target = "city", ignore = true)
    @Mapping(target = "venue", ignore = true)
    @Mapping(target = "ticketTypes", ignore = true)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void updateEvent(@MappingTarget Event event, EventRequest request);
}

