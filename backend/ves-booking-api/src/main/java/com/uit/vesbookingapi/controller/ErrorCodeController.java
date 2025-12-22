package com.uit.vesbookingapi.controller;

import com.uit.vesbookingapi.dto.request.ApiResponse;
import com.uit.vesbookingapi.dto.response.ErrorCodeResponse;
import com.uit.vesbookingapi.exception.ErrorCode;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/error-codes")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class ErrorCodeController {

    @GetMapping
    public ApiResponse<List<ErrorCodeResponse>> getAllErrorCodes() {
        List<ErrorCodeResponse> errorCodes = Arrays.stream(ErrorCode.values())
                .map(errorCode -> {
                    String category = getCategory(errorCode.getCode());
                    return ErrorCodeResponse.builder()
                            .name(errorCode.name())
                            .code(errorCode.getCode())
                            .message(errorCode.getMessage())
                            .httpStatus(errorCode.getStatusCode().value())
                            .category(category)
                            .build();
                })
                .collect(Collectors.toList());

        return ApiResponse.<List<ErrorCodeResponse>>builder()
                .result(errorCodes)
                .build();
    }

    private String getCategory(int code) {
        if (code == 9999) return "System errors";
        if (code >= 1000 && code < 2000) return "User errors";
        if (code >= 2000 && code < 3000) return "Event errors";
        if (code >= 3000 && code < 4000) return "Ticket errors";
        if (code >= 4000 && code < 5000) return "Seat errors";
        if (code >= 5000 && code < 6000) return "Order errors";
        if (code >= 6000 && code < 7000) return "Voucher errors";
        if (code >= 7000 && code < 8000) return "Venue errors";
        if (code >= 8000 && code < 9000) return "Category/City errors";
        if (code >= 9000 && code < 10000) return "Notification errors";
        return "Other errors";
    }
}

