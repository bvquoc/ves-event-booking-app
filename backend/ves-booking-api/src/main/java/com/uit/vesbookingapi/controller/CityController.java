package com.uit.vesbookingapi.controller;

import com.uit.vesbookingapi.dto.request.ApiResponse;
import com.uit.vesbookingapi.dto.request.CityRequest;
import com.uit.vesbookingapi.dto.response.CityResponse;
import com.uit.vesbookingapi.service.CityService;
import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/cities")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class CityController {
    CityService cityService;

    @GetMapping
    public ApiResponse<List<CityResponse>> getAllCities() {
        return ApiResponse.<List<CityResponse>>builder()
                .result(cityService.getAllCities())
                .build();
    }

    @GetMapping("/{cityId}")
    public ApiResponse<CityResponse> getCityById(@PathVariable String cityId) {
        return ApiResponse.<CityResponse>builder()
                .result(cityService.getCityById(cityId))
                .build();
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<CityResponse> createCity(@Valid @RequestBody CityRequest request) {
        return ApiResponse.<CityResponse>builder()
                .result(cityService.createCity(request))
                .build();
    }

    @PutMapping("/{cityId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<CityResponse> updateCity(
            @PathVariable String cityId,
            @Valid @RequestBody CityRequest request) {
        return ApiResponse.<CityResponse>builder()
                .result(cityService.updateCity(cityId, request))
                .build();
    }

    @DeleteMapping("/{cityId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Void> deleteCity(@PathVariable String cityId) {
        cityService.deleteCity(cityId);
        return ApiResponse.<Void>builder().build();
    }
}
