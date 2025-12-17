package com.uit.vesbookingapi.mapper;

import com.uit.vesbookingapi.dto.response.CityResponse;
import com.uit.vesbookingapi.entity.City;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface CityMapper {
    CityResponse toCityResponse(City city);
}
