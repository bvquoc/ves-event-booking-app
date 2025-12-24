package com.uit.vesbookingapi.mapper;

import com.uit.vesbookingapi.dto.response.AdminOrderResponse;
import com.uit.vesbookingapi.entity.Order;
import com.uit.vesbookingapi.entity.Ticket;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

import java.util.List;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
public interface AdminOrderMapper {

    @Mapping(target = "user", source = "order", qualifiedByName = "mapUserInfo")
    @Mapping(target = "event", source = "order", qualifiedByName = "mapEventInfo")
    @Mapping(target = "ticketType", source = "order", qualifiedByName = "mapTicketTypeInfo")
    @Mapping(target = "tickets", source = "order.tickets", qualifiedByName = "mapTicketSummaries")
    @Mapping(target = "voucherCode", source = "voucher.code")
    @Mapping(target = "paymentTransactionId", ignore = true)
        // Will be set manually if exists
    AdminOrderResponse toAdminOrderResponse(Order order);

    @Named("mapUserInfo")
    default AdminOrderResponse.UserInfo mapUserInfo(Order order) {
        if (order.getUser() == null) return null;

        return AdminOrderResponse.UserInfo.builder()
                .id(order.getUser().getId())
                .username(order.getUser().getUsername())
                .email(order.getUser().getEmail())
                .phone(order.getUser().getPhone())
                .firstName(order.getUser().getFirstName())
                .lastName(order.getUser().getLastName())
                .fullName(buildFullName(order.getUser().getFirstName(), order.getUser().getLastName()))
                .build();
    }

    @Named("mapEventInfo")
    default AdminOrderResponse.EventInfo mapEventInfo(Order order) {
        if (order.getEvent() == null) return null;

        return AdminOrderResponse.EventInfo.builder()
                .id(order.getEvent().getId())
                .name(order.getEvent().getName())
                .slug(order.getEvent().getSlug())
                .thumbnail(order.getEvent().getThumbnail())
                .venueName(order.getEvent().getVenueName())
                .venueAddress(order.getEvent().getVenueAddress())
                .startDate(order.getEvent().getStartDate())
                .endDate(order.getEvent().getEndDate())
                .build();
    }

    @Named("mapTicketTypeInfo")
    default AdminOrderResponse.TicketTypeInfo mapTicketTypeInfo(Order order) {
        if (order.getTicketType() == null) return null;

        return AdminOrderResponse.TicketTypeInfo.builder()
                .id(order.getTicketType().getId())
                .name(order.getTicketType().getName())
                .description(order.getTicketType().getDescription())
                .price(order.getTicketType().getPrice())
                .currency(order.getTicketType().getCurrency())
                .build();
    }

    @Named("mapTicketSummaries")
    default List<AdminOrderResponse.TicketSummary> mapTicketSummaries(List<Ticket> tickets) {
        if (tickets == null) return null;

        return tickets.stream()
                .map(ticket -> AdminOrderResponse.TicketSummary.builder()
                        .id(ticket.getId())
                        .qrCode(ticket.getQrCode())
                        .seatNumber(ticket.getSeat() != null ? ticket.getSeat().getSeatNumber() : null)
                        .status(ticket.getStatus())
                        .purchaseDate(ticket.getPurchaseDate())
                        .checkedInAt(ticket.getCheckedInAt())
                        .cancelledAt(ticket.getCancelledAt())
                        .build())
                .collect(Collectors.toList());
    }

    default String buildFullName(String firstName, String lastName) {
        if (firstName == null && lastName == null) return null;
        if (firstName == null) return lastName;
        if (lastName == null) return firstName;
        return firstName + " " + lastName;
    }
}

