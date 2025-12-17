package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.request.CityRequest;
import com.uit.vesbookingapi.dto.response.CityResponse;
import com.uit.vesbookingapi.entity.City;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import com.uit.vesbookingapi.mapper.CityMapper;
import com.uit.vesbookingapi.repository.CityRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class CityService {
    CityRepository cityRepository;
    CityMapper cityMapper;

    public List<CityResponse> getAllCities() {
        // Get event counts in single query (prevents N+1)
        Map<String, Long> eventCounts = cityRepository.countEventsByAllCities().stream()
                .collect(Collectors.toMap(
                        map -> (String) map.get("cityId"),
                        map -> ((Number) map.get("eventCount")).longValue()
                ));

        return cityRepository.findAll().stream()
                .map(city -> {
                    CityResponse response = cityMapper.toCityResponse(city);
                    response.setEventCount(eventCounts.getOrDefault(city.getId(), 0L));
                    return response;
                })
                .collect(Collectors.toList());
    }

    public CityResponse getCityById(String cityId) {
        City city = cityRepository.findById(cityId)
                .orElseThrow(() -> new AppException(ErrorCode.CITY_NOT_FOUND));

        CityResponse response = cityMapper.toCityResponse(city);
        Long eventCount = cityRepository.countEventsByCity(cityId);
        response.setEventCount(eventCount != null ? eventCount : 0L);

        return response;
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public CityResponse createCity(CityRequest request) {
        // Check if slug already exists
        if (cityRepository.findAll().stream().anyMatch(c -> c.getSlug().equals(request.getSlug()))) {
            throw new AppException(ErrorCode.UNCATEGORIZED_EXCEPTION);
        }

        City city = cityMapper.toCity(request);

        try {
            city = cityRepository.save(city);
        } catch (DataIntegrityViolationException e) {
            throw new AppException(ErrorCode.UNCATEGORIZED_EXCEPTION);
        }

        CityResponse response = cityMapper.toCityResponse(city);
        response.setEventCount(0L);
        return response;
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public CityResponse updateCity(String cityId, CityRequest request) {
        City city = cityRepository.findById(cityId)
                .orElseThrow(() -> new AppException(ErrorCode.CITY_NOT_FOUND));

        // Check if slug already exists (excluding current city)
        if (!city.getSlug().equals(request.getSlug()) &&
                cityRepository.findAll().stream().anyMatch(c -> c.getSlug().equals(request.getSlug()))) {
            throw new AppException(ErrorCode.UNCATEGORIZED_EXCEPTION);
        }

        cityMapper.updateCity(city, request);
        city = cityRepository.save(city);

        CityResponse response = cityMapper.toCityResponse(city);
        Long eventCount = cityRepository.countEventsByCity(cityId);
        response.setEventCount(eventCount != null ? eventCount : 0L);

        return response;
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void deleteCity(String cityId) {
        City city = cityRepository.findById(cityId)
                .orElseThrow(() -> new AppException(ErrorCode.CITY_NOT_FOUND));

        // Check if city has events
        Long eventCount = cityRepository.countEventsByCity(cityId);
        if (eventCount != null && eventCount > 0) {
            throw new AppException(ErrorCode.UNCATEGORIZED_EXCEPTION);
        }

        cityRepository.deleteById(cityId);
    }
}
