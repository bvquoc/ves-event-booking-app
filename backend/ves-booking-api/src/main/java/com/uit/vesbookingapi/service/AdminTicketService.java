package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.response.TicketDetailResponse;
import com.uit.vesbookingapi.dto.response.TicketResponse;
import com.uit.vesbookingapi.entity.Ticket;
import com.uit.vesbookingapi.enums.TicketStatus;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import com.uit.vesbookingapi.mapper.TicketMapper;
import com.uit.vesbookingapi.repository.TicketRepository;
import jakarta.persistence.criteria.Predicate;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class AdminTicketService {
    TicketRepository ticketRepository;
    TicketMapper ticketMapper;

    /**
     * Get all tickets with optional filters (Admin only)
     */
    @PreAuthorize("hasRole('ADMIN')")
    public Page<TicketResponse> getAllTickets(
            String userId,
            String eventId,
            TicketStatus status,
            Pageable pageable) {
        
        Specification<Ticket> spec = buildSpecification(userId, eventId, status);
        Page<Ticket> ticketPage = ticketRepository.findAll(spec, pageable);
        
        return ticketPage.map(ticketMapper::toTicketResponse);
    }

    /**
     * Get ticket details by ID (Admin can view any ticket)
     */
    @PreAuthorize("hasRole('ADMIN')")
    public TicketDetailResponse getTicketDetails(String ticketId) {
        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new AppException(ErrorCode.TICKET_NOT_FOUND));
        
        return ticketMapper.toTicketDetailResponse(ticket);
    }

    /**
     * Build JPA Specification for filtering tickets
     */
    private Specification<Ticket> buildSpecification(String userId, String eventId, TicketStatus status) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (userId != null && !userId.isEmpty()) {
                predicates.add(cb.equal(root.get("user").get("id"), userId));
            }

            if (eventId != null && !eventId.isEmpty()) {
                predicates.add(cb.equal(root.get("event").get("id"), eventId));
            }

            if (status != null) {
                predicates.add(cb.equal(root.get("status"), status));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}

