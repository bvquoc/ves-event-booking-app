package com.uit.vesbookingapi.mapper;

import com.uit.vesbookingapi.dto.response.AdminTicketResponse;
import com.uit.vesbookingapi.entity.Ticket;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

@Mapper(componentModel = "spring")
public interface AdminTicketMapper {

    @Mapping(target = "user", source = "ticket", qualifiedByName = "mapUserInfo")
    @Mapping(target = "order", source = "ticket", qualifiedByName = "mapOrderInfo")
    @Mapping(target = "event", source = "ticket", qualifiedByName = "mapEventInfo")
    @Mapping(target = "ticketType", source = "ticket", qualifiedByName = "mapTicketTypeInfo")
    @Mapping(target = "seat", source = "ticket", qualifiedByName = "mapSeatInfo")
    AdminTicketResponse toAdminTicketResponse(Ticket ticket);

    @Named("mapUserInfo")
    default AdminTicketResponse.UserInfo mapUserInfo(Ticket ticket) {
        if (ticket.getUser() == null) return null;

        return AdminTicketResponse.UserInfo.builder()
                .id(ticket.getUser().getId())
                .username(ticket.getUser().getUsername())
                .email(ticket.getUser().getEmail())
                .phone(ticket.getUser().getPhone())
                .firstName(ticket.getUser().getFirstName())
                .lastName(ticket.getUser().getLastName())
                .fullName(buildFullName(ticket.getUser().getFirstName(), ticket.getUser().getLastName()))
                .build();
    }

    @Named("mapOrderInfo")
    default AdminTicketResponse.OrderInfo mapOrderInfo(Ticket ticket) {
        if (ticket.getOrder() == null) return null;

        return AdminTicketResponse.OrderInfo.builder()
                .id(ticket.getOrder().getId())
                .status(ticket.getOrder().getStatus())
                .paymentMethod(ticket.getOrder().getPaymentMethod())
                .total(ticket.getOrder().getTotal())
                .currency(ticket.getOrder().getCurrency())
                .createdAt(ticket.getOrder().getCreatedAt())
                .completedAt(ticket.getOrder().getCompletedAt())
                .build();
    }

    @Named("mapEventInfo")
    default AdminTicketResponse.EventInfo mapEventInfo(Ticket ticket) {
        if (ticket.getEvent() == null) return null;

        return AdminTicketResponse.EventInfo.builder()
                .id(ticket.getEvent().getId())
                .name(ticket.getEvent().getName())
                .slug(ticket.getEvent().getSlug())
                .description(ticket.getEvent().getDescription())
                .thumbnail(ticket.getEvent().getThumbnail())
                .venueName(ticket.getEvent().getVenueName())
                .venueAddress(ticket.getEvent().getVenueAddress())
                .startDate(ticket.getEvent().getStartDate())
                .endDate(ticket.getEvent().getEndDate())
                .build();
    }

    @Named("mapTicketTypeInfo")
    default AdminTicketResponse.TicketTypeInfo mapTicketTypeInfo(Ticket ticket) {
        if (ticket.getTicketType() == null) return null;

        return AdminTicketResponse.TicketTypeInfo.builder()
                .id(ticket.getTicketType().getId())
                .name(ticket.getTicketType().getName())
                .description(ticket.getTicketType().getDescription())
                .price(ticket.getTicketType().getPrice())
                .currency(ticket.getTicketType().getCurrency())
                .build();
    }

    @Named("mapSeatInfo")
    default AdminTicketResponse.SeatInfo mapSeatInfo(Ticket ticket) {
        if (ticket.getSeat() == null) return null;

        return AdminTicketResponse.SeatInfo.builder()
                .id(ticket.getSeat().getId())
                .seatNumber(ticket.getSeat().getSeatNumber())
                .section(ticket.getSeat().getSectionName())
                .row(ticket.getSeat().getRowName())
                .build();
    }

    default String buildFullName(String firstName, String lastName) {
        if (firstName == null && lastName == null) return null;
        if (firstName == null) return lastName;
        if (lastName == null) return firstName;
        return firstName + " " + lastName;
    }
}

