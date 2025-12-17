package com.uit.vesbookingapi.mapper;

import com.uit.vesbookingapi.dto.response.CategoryResponse;
import com.uit.vesbookingapi.entity.Category;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface CategoryMapper {
    CategoryResponse toCategoryResponse(Category category);
}
