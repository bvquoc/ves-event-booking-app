package com.uit.vesbookingapi.mapper;

import com.uit.vesbookingapi.dto.response.OrderResponse;
import com.uit.vesbookingapi.dto.response.PurchaseResponse;
import com.uit.vesbookingapi.entity.Order;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface OrderMapper {

    @Mapping(source = "user.id", target = "userId")
    @Mapping(source = "event.id", target = "eventId")
    @Mapping(source = "event.name", target = "eventName")
    @Mapping(source = "ticketType.id", target = "ticketTypeId")
    @Mapping(source = "ticketType.name", target = "ticketTypeName")
    @Mapping(source = "voucher.code", target = "voucherCode")
    OrderResponse toOrderResponse(Order order);

    @Mapping(source = "id", target = "orderId")
    PurchaseResponse toPurchaseResponse(Order order);
}
