package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.response.CategoryResponse;
import com.uit.vesbookingapi.mapper.CategoryMapper;
import com.uit.vesbookingapi.repository.CategoryRepository;
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
public class CategoryService {
    CategoryRepository categoryRepository;
    CategoryMapper categoryMapper;

    public List<CategoryResponse> getAllCategories() {
        // Get event counts in single query (prevents N+1)
        Map<String, Long> eventCounts = categoryRepository.countEventsByAllCategories().stream()
                .collect(Collectors.toMap(
                        map -> (String) map.get("categoryId"),
                        map -> ((Number) map.get("eventCount")).longValue()
                ));

        return categoryRepository.findAll().stream()
                .map(category -> {
                    CategoryResponse response = categoryMapper.toCategoryResponse(category);
                    response.setEventCount(eventCounts.getOrDefault(category.getId(), 0L));
                    return response;
                })
                .collect(Collectors.toList());
    }
}
