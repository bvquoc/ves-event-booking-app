package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.response.AdminTicketResponse;
import com.uit.vesbookingapi.dto.response.CheckInResponse;
import com.uit.vesbookingapi.entity.Ticket;
import com.uit.vesbookingapi.enums.OrderStatus;
import com.uit.vesbookingapi.enums.TicketStatus;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import com.uit.vesbookingapi.mapper.AdminTicketMapper;
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
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class AdminTicketService {
    TicketRepository ticketRepository;
    AdminTicketMapper adminTicketMapper;

    /**
     * Get all tickets with optional filters (Admin, Staff, Organizer only)
     * Returns rich admin response with user, order, event, and seat information
     */
    @PreAuthorize("hasAnyRole('ADMIN', 'STAFF', 'ORGANIZER')")
    public Page<AdminTicketResponse> getAllTickets(
            String userId,
            String eventId,
            TicketStatus status,
            Pageable pageable) {

        Specification<Ticket> spec = buildSpecification(userId, eventId, status);
        Page<Ticket> ticketPage = ticketRepository.findAll(spec, pageable);

        return ticketPage.map(adminTicketMapper::toAdminTicketResponse);
    }

    /**
     * Get ticket details by ID (Admin, Staff, Organizer can view any ticket)
     * Returns rich admin response with all related information
     */
    @PreAuthorize("hasAnyRole('ADMIN', 'STAFF', 'ORGANIZER')")
    public AdminTicketResponse getTicketDetails(String ticketId) {
        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new AppException(ErrorCode.TICKET_NOT_FOUND));

        return adminTicketMapper.toAdminTicketResponse(ticket);
    }

    /**
     * Check in ticket via QR code (Admin, Staff, Organizer only)
     * Validates ticket status and order completion before check-in
     */
    @Transactional
    @PreAuthorize("hasAnyRole('ADMIN', 'STAFF', 'ORGANIZER')")
    public CheckInResponse checkInTicket(String qrCode) {
        log.info("Processing check-in request for QR code: {}", qrCode);

        // 1. Find ticket by QR code
        Ticket ticket = ticketRepository.findByQrCode(qrCode)
                .orElseThrow(() -> {
                    log.warn("QR code not found: {}", qrCode);
                    return new AppException(ErrorCode.QR_CODE_NOT_FOUND);
                });

        log.info("Found ticket: ticketId={}, status={}, orderStatus={}",
                ticket.getId(), ticket.getStatus(), ticket.getOrder().getStatus());

        // 2. Validate order status is COMPLETED
        if (ticket.getOrder().getStatus() != OrderStatus.COMPLETED) {
            log.warn("Order not completed for ticket: ticketId={}, orderStatus={}",
                    ticket.getId(), ticket.getOrder().getStatus());
            throw new AppException(ErrorCode.ORDER_NOT_COMPLETED);
        }

        // 3. Validate ticket status is ACTIVE
        if (ticket.getStatus() != TicketStatus.ACTIVE) {
            if (ticket.getStatus() == TicketStatus.USED) {
                log.warn("Ticket already checked in: ticketId={}", ticket.getId());
                throw new AppException(ErrorCode.TICKET_ALREADY_USED);
            } else {
                log.warn("Ticket not in ACTIVE status: ticketId={}, status={}",
                        ticket.getId(), ticket.getStatus());
                throw new AppException(ErrorCode.TICKET_NOT_ACTIVE);
            }
        }

        // 4. Update ticket: status = USED, checkedInAt = now()
        LocalDateTime checkInTime = LocalDateTime.now();
        ticket.setStatus(TicketStatus.USED);
        ticket.setCheckedInAt(checkInTime);
        ticket = ticketRepository.save(ticket);

        log.info("Ticket checked in successfully: ticketId={}, checkedInAt={}",
                ticket.getId(), checkInTime);

        // 5. Build response with ticket details
        AdminTicketResponse ticketDetails = adminTicketMapper.toAdminTicketResponse(ticket);

        return CheckInResponse.builder()
                .ticketId(ticket.getId())
                .qrCode(ticket.getQrCode())
                .status(ticket.getStatus())
                .checkedInAt(checkInTime)
                .message("Ticket checked in successfully")
                .ticketDetails(ticketDetails)
                .build();
    }

    /**
     * Get ticket by QR code (Admin, Staff, Organizer only)
     * Used for looking up ticket status before check-in
     */
    @PreAuthorize("hasAnyRole('ADMIN', 'STAFF', 'ORGANIZER')")
    public AdminTicketResponse getTicketByQrCode(String qrCode) {
        log.info("Looking up ticket by QR code: {}", qrCode);

        Ticket ticket = ticketRepository.findByQrCode(qrCode)
                .orElseThrow(() -> {
                    log.warn("QR code not found: {}", qrCode);
                    return new AppException(ErrorCode.QR_CODE_NOT_FOUND);
                });

        return adminTicketMapper.toAdminTicketResponse(ticket);
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

