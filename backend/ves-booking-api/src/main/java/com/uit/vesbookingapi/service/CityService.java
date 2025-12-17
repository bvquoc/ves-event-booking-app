package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.response.CityResponse;
import com.uit.vesbookingapi.mapper.CityMapper;
import com.uit.vesbookingapi.repository.CityRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

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
}
