package com.uit.vesbookingapi.controller;

import com.uit.vesbookingapi.dto.request.ApiResponse;
import com.uit.vesbookingapi.dto.request.ValidateVoucherRequest;
import com.uit.vesbookingapi.dto.response.UserVoucherResponse;
import com.uit.vesbookingapi.dto.response.VoucherResponse;
import com.uit.vesbookingapi.dto.response.VoucherValidationResponse;
import com.uit.vesbookingapi.service.VoucherService;
import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/vouchers")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class VoucherController {
    VoucherService voucherService;

    @GetMapping
    public ApiResponse<List<VoucherResponse>> getPublicVouchers() {
        return ApiResponse.<List<VoucherResponse>>builder()
                .result(voucherService.getPublicVouchers())
                .build();
    }

    @GetMapping("/my-vouchers")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<List<UserVoucherResponse>> getUserVouchers(
            @RequestParam(required = false) String status) {
        return ApiResponse.<List<UserVoucherResponse>>builder()
                .result(voucherService.getUserVouchers(status))
                .build();
    }

    @PostMapping("/validate")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<VoucherValidationResponse> validateVoucher(
            @Valid @RequestBody ValidateVoucherRequest request) {
        return ApiResponse.<VoucherValidationResponse>builder()
                .result(voucherService.validateVoucher(request))
                .build();
    }
}
