package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.response.TicketTypeResponse;
import com.uit.vesbookingapi.entity.Event;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import com.uit.vesbookingapi.mapper.TicketTypeMapper;
import com.uit.vesbookingapi.repository.EventRepository;
import com.uit.vesbookingapi.repository.TicketTypeRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class TicketTypeService {
    TicketTypeRepository ticketTypeRepository;
    EventRepository eventRepository;
    TicketTypeMapper ticketTypeMapper;
    
    public List<TicketTypeResponse> getTicketTypesByEvent(String eventId) {
        if (!eventRepository.existsById(eventId)) {
            throw new AppException(ErrorCode.EVENT_NOT_FOUND);
        }
        
        return ticketTypeRepository.findByEventId(eventId).stream()
                .map(ticketTypeMapper::toTicketTypeResponse)
                .collect(Collectors.toList());
    }
}

