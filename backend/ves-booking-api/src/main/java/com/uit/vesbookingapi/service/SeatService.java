package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.request.SeatRequest;
import com.uit.vesbookingapi.dto.response.SeatResponse;
import com.uit.vesbookingapi.entity.Seat;
import com.uit.vesbookingapi.entity.Venue;
import com.uit.vesbookingapi.enums.SeatStatus;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import com.uit.vesbookingapi.repository.SeatRepository;
import com.uit.vesbookingapi.repository.TicketRepository;
import com.uit.vesbookingapi.repository.VenueRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class SeatService {
    SeatRepository seatRepository;
    VenueRepository venueRepository;
    TicketRepository ticketRepository;

    public List<SeatResponse> getSeatsByVenue(String venueId) {
        Venue venue = venueRepository.findById(venueId)
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));

        List<Seat> seats = seatRepository.findByVenueId(venueId);
        return seats.stream()
                .map(this::toSeatResponse)
                .collect(Collectors.toList());
    }

    public SeatResponse getSeatById(String seatId) {
        Seat seat = seatRepository.findById(seatId)
                .orElseThrow(() -> new AppException(ErrorCode.SEAT_NOT_FOUND));
        return toSeatResponse(seat);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public SeatResponse createSeat(String venueId, SeatRequest request) {
        Venue venue = venueRepository.findById(venueId)
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));

        // Check if seat already exists (same section, row, seatNumber in same venue)
        boolean exists = seatRepository.findByVenueId(venueId).stream()
                .anyMatch(s -> s.getSectionName().equals(request.getSectionName()) &&
                        s.getRowName().equals(request.getRowName()) &&
                        s.getSeatNumber().equals(request.getSeatNumber()));

        if (exists) {
            throw new AppException(ErrorCode.SEAT_ALREADY_EXISTS);
        }

        Seat seat = Seat.builder()
                .venue(venue)
                .sectionName(request.getSectionName())
                .rowName(request.getRowName())
                .seatNumber(request.getSeatNumber())
                .build();

        seat = seatRepository.save(seat);
        log.info("Created seat {} in venue {}", seat.getId(), venueId);
        return toSeatResponse(seat);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public SeatResponse updateSeat(String seatId, SeatRequest request) {
        Seat seat = seatRepository.findById(seatId)
                .orElseThrow(() -> new AppException(ErrorCode.SEAT_NOT_FOUND));

        // Check if another seat with same section/row/seatNumber exists in same venue
        boolean exists = seatRepository.findByVenueId(seat.getVenue().getId()).stream()
                .anyMatch(s -> !s.getId().equals(seatId) &&
                        s.getSectionName().equals(request.getSectionName()) &&
                        s.getRowName().equals(request.getRowName()) &&
                        s.getSeatNumber().equals(request.getSeatNumber()));

        if (exists) {
            throw new AppException(ErrorCode.SEAT_ALREADY_EXISTS);
        }

        seat.setSectionName(request.getSectionName());
        seat.setRowName(request.getRowName());
        seat.setSeatNumber(request.getSeatNumber());

        seat = seatRepository.save(seat);
        log.info("Updated seat {}", seatId);
        return toSeatResponse(seat);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public void deleteSeat(String seatId) {
        Seat seat = seatRepository.findById(seatId)
                .orElseThrow(() -> new AppException(ErrorCode.SEAT_NOT_FOUND));

        // Check if seat has any tickets
        boolean hasTickets = ticketRepository.findAll().stream()
                .anyMatch(t -> t.getSeat() != null && t.getSeat().getId().equals(seatId));

        if (hasTickets) {
            throw new AppException(ErrorCode.SEAT_HAS_TICKETS);
        }

        seatRepository.deleteById(seatId);
        log.info("Deleted seat {}", seatId);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public List<SeatResponse> createBulkSeats(String venueId, List<SeatRequest> requests) {
        Venue venue = venueRepository.findById(venueId)
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));

        List<Seat> existingSeats = seatRepository.findByVenueId(venueId);

        List<Seat> seatsToCreate = requests.stream()
                .filter(request -> {
                    // Check if seat already exists
                    boolean exists = existingSeats.stream()
                            .anyMatch(s -> s.getSectionName().equals(request.getSectionName()) &&
                                    s.getRowName().equals(request.getRowName()) &&
                                    s.getSeatNumber().equals(request.getSeatNumber()));
                    return !exists;
                })
                .map(request -> Seat.builder()
                        .venue(venue)
                        .sectionName(request.getSectionName())
                        .rowName(request.getRowName())
                        .seatNumber(request.getSeatNumber())
                        .build())
                .collect(Collectors.toList());

        List<Seat> savedSeats = seatRepository.saveAll(seatsToCreate);
        log.info("Created {} seats in venue {}", savedSeats.size(), venueId);
        return savedSeats.stream()
                .map(this::toSeatResponse)
                .collect(Collectors.toList());
    }

    private SeatResponse toSeatResponse(Seat seat) {
        return SeatResponse.builder()
                .id(seat.getId())
                .sectionName(seat.getSectionName())
                .rowName(seat.getRowName())
                .seatNumber(seat.getSeatNumber())
                .status(SeatStatus.AVAILABLE) // Default status, actual status calculated per event
                .build();
    }
}

