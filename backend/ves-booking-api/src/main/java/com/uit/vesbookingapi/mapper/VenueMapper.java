package com.uit.vesbookingapi.mapper;

import com.uit.vesbookingapi.dto.request.VenueRequest;
import com.uit.vesbookingapi.dto.response.VenueResponse;
import com.uit.vesbookingapi.entity.Venue;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring", uses = {CityMapper.class})
public interface VenueMapper {
    VenueResponse toVenueResponse(Venue venue);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "city", ignore = true)
    @Mapping(target = "seats", ignore = true)
    Venue toVenue(VenueRequest request);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "city", ignore = true)
    @Mapping(target = "seats", ignore = true)
    void updateVenue(@MappingTarget Venue venue, VenueRequest request);
}

