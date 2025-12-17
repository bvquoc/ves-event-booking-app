package com.uit.vesbookingapi.mapper;

import com.uit.vesbookingapi.dto.request.TicketTypeRequest;
import com.uit.vesbookingapi.dto.response.TicketTypeResponse;
import com.uit.vesbookingapi.entity.TicketType;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface TicketTypeMapper {
    @Mapping(target = "event", ignore = true)
    @Mapping(target = "id", ignore = true)
    TicketType toTicketType(TicketTypeRequest request);

    TicketTypeResponse toTicketTypeResponse(TicketType ticketType);
}

