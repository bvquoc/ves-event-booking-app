package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.request.VenueRequest;
import com.uit.vesbookingapi.dto.response.*;
import com.uit.vesbookingapi.entity.City;
import com.uit.vesbookingapi.entity.Seat;
import com.uit.vesbookingapi.entity.Venue;
import com.uit.vesbookingapi.enums.SeatStatus;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import com.uit.vesbookingapi.mapper.VenueMapper;
import com.uit.vesbookingapi.repository.*;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class VenueService {
    VenueRepository venueRepository;
    SeatRepository seatRepository;
    EventRepository eventRepository;
    TicketTypeRepository ticketTypeRepository;
    CityRepository cityRepository;
    VenueMapper venueMapper;

    public List<VenueResponse> getAllVenues() {
        return venueRepository.findAll().stream()
                .map(venueMapper::toVenueResponse)
                .collect(Collectors.toList());
    }

    public VenueResponse getVenueById(String venueId) {
        Venue venue = venueRepository.findById(venueId)
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
        return venueMapper.toVenueResponse(venue);
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ADMIN')")
    @org.springframework.transaction.annotation.Transactional
    public VenueResponse createVenue(VenueRequest request) {
        // Validate city exists
        City city = cityRepository.findById(request.getCityId())
                .orElseThrow(() -> new AppException(ErrorCode.CITY_NOT_FOUND));

        Venue venue = venueMapper.toVenue(request);
        venue.setCity(city);

        venue = venueRepository.save(venue);
        return venueMapper.toVenueResponse(venue);
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ADMIN')")
    @org.springframework.transaction.annotation.Transactional
    public VenueResponse updateVenue(String venueId, VenueRequest request) {
        Venue venue = venueRepository.findById(venueId)
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));

        // Validate city exists
        City city = cityRepository.findById(request.getCityId())
                .orElseThrow(() -> new AppException(ErrorCode.CITY_NOT_FOUND));

        venueMapper.updateVenue(venue, request);
        venue.setCity(city);

        venue = venueRepository.save(venue);
        return venueMapper.toVenueResponse(venue);
    }

    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ADMIN')")
    public void deleteVenue(String venueId) {
        if (!venueRepository.existsById(venueId)) {
            throw new AppException(ErrorCode.VENUE_NOT_FOUND);
        }
        venueRepository.deleteById(venueId);
    }

    public VenueSeatingResponse getVenueSeating(String venueId, String eventId) {
        // Find venue
        Venue venue = venueRepository.findById(venueId)
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));

        // Validate event exists
        if (!eventRepository.existsById(eventId)) {
            throw new AppException(ErrorCode.EVENT_NOT_FOUND);
        }

        // Check if event has any ticket types that require seat selection
        List<com.uit.vesbookingapi.entity.TicketType> ticketTypes = ticketTypeRepository.findByEventId(eventId);
        boolean hasSeatRequiringTickets = ticketTypes.stream()
                .anyMatch(com.uit.vesbookingapi.entity.TicketType::getRequiresSeatSelection);

        // If all tickets are standing tickets (no seat selection required), return empty sections
        if (!hasSeatRequiringTickets) {
            return VenueSeatingResponse.builder()
                    .venueId(venue.getId())
                    .venueName(venue.getName())
                    .eventId(eventId)
                    .sections(Collections.emptyList())
                    .build();
        }

        // Find all seats for this venue
        List<Seat> seats = seatRepository.findByVenueId(venueId);

        // Get sold and reserved seat IDs for this event
        List<String> soldSeatIds = seatRepository.findSoldSeatIdsByEvent(eventId);
        List<String> reservedSeatIds = seatRepository.findReservedSeatIdsByEvent(eventId, LocalDateTime.now());

        Set<String> soldSet = new HashSet<>(soldSeatIds);
        Set<String> reservedSet = new HashSet<>(reservedSeatIds);

        // Build seat status map and group by section -> row
        Map<String, Map<String, List<SeatResponse>>> sectionRowSeats = new LinkedHashMap<>();

        for (Seat seat : seats) {
            // Calculate seat status
            SeatStatus status;
            if (soldSet.contains(seat.getId())) {
                status = SeatStatus.SOLD;
            } else if (reservedSet.contains(seat.getId())) {
                status = SeatStatus.RESERVED;
            } else {
                status = SeatStatus.AVAILABLE;
            }

            // Create SeatResponse
            SeatResponse seatResponse = SeatResponse.builder()
                    .id(seat.getId())
                    .seatNumber(seat.getSeatNumber())
                    .status(status)
                    .build();

            // Group by section -> row
            sectionRowSeats
                    .computeIfAbsent(seat.getSectionName(), k -> new LinkedHashMap<>())
                    .computeIfAbsent(seat.getRowName(), k -> new ArrayList<>())
                    .add(seatResponse);
        }

        // Build nested response structure
        List<SectionResponse> sections = sectionRowSeats.entrySet().stream()
                .map(sectionEntry -> {
                    String sectionName = sectionEntry.getKey();
                    Map<String, List<SeatResponse>> rowSeats = sectionEntry.getValue();

                    List<RowResponse> rows = rowSeats.entrySet().stream()
                            .map(rowEntry -> RowResponse.builder()
                                    .rowName(rowEntry.getKey())
                                    .seats(rowEntry.getValue())
                                    .build())
                            .collect(Collectors.toList());

                    return SectionResponse.builder()
                            .sectionName(sectionName)
                            .rows(rows)
                            .build();
                })
                .collect(Collectors.toList());

        return VenueSeatingResponse.builder()
                .venueId(venue.getId())
                .venueName(venue.getName())
                .eventId(eventId)
                .sections(sections)
                .build();
    }
}
