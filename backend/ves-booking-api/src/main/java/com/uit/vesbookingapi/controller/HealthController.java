package com.uit.vesbookingapi.controller;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/healthz")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class HealthController {

    @GetMapping
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> healthStatus = new HashMap<>();
        healthStatus.put("status", "healthy");
        healthStatus.put("timestamp", LocalDateTime.now().toString());
        healthStatus.put("service", "ves-booking-api");
        
        return ResponseEntity.status(HttpStatus.OK).body(healthStatus);
    }
}
