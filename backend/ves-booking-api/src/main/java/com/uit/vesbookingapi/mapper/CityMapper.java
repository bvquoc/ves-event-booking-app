package com.uit.vesbookingapi.mapper;

import com.uit.vesbookingapi.dto.request.CityRequest;
import com.uit.vesbookingapi.dto.response.CityResponse;
import com.uit.vesbookingapi.entity.City;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface CityMapper {
    CityResponse toCityResponse(City city);

    @Mapping(target = "id", ignore = true)
    City toCity(CityRequest request);

    @Mapping(target = "id", ignore = true)
    void updateCity(@MappingTarget City city, CityRequest request);
}
