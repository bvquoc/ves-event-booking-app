package com.uit.vesbookingapi.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ErrorCodeResponse {
    private String name;        // Error code enum name (e.g., "EVENT_NOT_FOUND")
    private int code;           // Error code number (e.g., 2001)
    private String message;     // Error message (e.g., "Event not found")
    private int httpStatus;     // HTTP status code (e.g., 404)
    private String category;    // Category based on code range (e.g., "Event errors")
}

