package com.uit.vesbookingapi.mapper;

import com.uit.vesbookingapi.dto.response.TicketDetailResponse;
import com.uit.vesbookingapi.dto.response.TicketResponse;
import com.uit.vesbookingapi.entity.Ticket;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface TicketMapper {

    @Mapping(source = "event.id", target = "eventId")
    @Mapping(source = "event.name", target = "eventName")
    @Mapping(source = "event.thumbnail", target = "eventThumbnail")
    @Mapping(source = "event.startDate", target = "eventStartDate")
    @Mapping(source = "event.venueName", target = "venueName")
    @Mapping(source = "ticketType.name", target = "ticketTypeName")
    @Mapping(source = "seat.seatNumber", target = "seatNumber")
    @Mapping(source = "seat.sectionName", target = "seatSectionName")
    @Mapping(source = "seat.rowName", target = "seatRowName")
    TicketResponse toTicketResponse(Ticket ticket);

    @Mapping(source = "event.id", target = "eventId")
    @Mapping(source = "event.name", target = "eventName")
    @Mapping(source = "event.description", target = "eventDescription")
    @Mapping(source = "event.thumbnail", target = "eventThumbnail")
    @Mapping(source = "event.startDate", target = "eventStartDate")
    @Mapping(source = "event.endDate", target = "eventEndDate")
    @Mapping(source = "event.venueName", target = "venueName")
    @Mapping(source = "event.venueAddress", target = "venueAddress")
    @Mapping(source = "ticketType.id", target = "ticketTypeId")
    @Mapping(source = "ticketType.name", target = "ticketTypeName")
    @Mapping(source = "ticketType.description", target = "ticketTypeDescription")
    @Mapping(source = "ticketType.price", target = "ticketTypePrice")
    @Mapping(source = "seat.seatNumber", target = "seatNumber")
    @Mapping(source = "seat.sectionName", target = "seatSectionName")
    @Mapping(source = "seat.rowName", target = "seatRowName")
    TicketDetailResponse toTicketDetailResponse(Ticket ticket);
}
