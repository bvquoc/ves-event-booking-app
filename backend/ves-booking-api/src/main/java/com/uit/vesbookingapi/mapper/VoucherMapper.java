package com.uit.vesbookingapi.mapper;

import com.uit.vesbookingapi.dto.response.UserVoucherResponse;
import com.uit.vesbookingapi.dto.response.VoucherResponse;
import com.uit.vesbookingapi.entity.UserVoucher;
import com.uit.vesbookingapi.entity.Voucher;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface VoucherMapper {

    VoucherResponse toVoucherResponse(Voucher voucher);

    @Mapping(source = "voucher", target = "voucher")
    @Mapping(source = "order.id", target = "orderId")
    UserVoucherResponse toUserVoucherResponse(UserVoucher userVoucher);
}
