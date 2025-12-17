package com.uit.vesbookingapi.mapper;

import com.uit.vesbookingapi.dto.response.VenueResponse;
import com.uit.vesbookingapi.entity.Venue;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring", uses = {CityMapper.class})
public interface VenueMapper {
    VenueResponse toVenueResponse(Venue venue);
}

