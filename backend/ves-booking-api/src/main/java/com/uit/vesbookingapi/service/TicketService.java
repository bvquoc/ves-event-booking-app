package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.request.CancelTicketRequest;
import com.uit.vesbookingapi.dto.response.CancellationResponse;
import com.uit.vesbookingapi.dto.response.TicketDetailResponse;
import com.uit.vesbookingapi.dto.response.TicketResponse;
import com.uit.vesbookingapi.entity.Ticket;
import com.uit.vesbookingapi.entity.TicketType;
import com.uit.vesbookingapi.enums.RefundStatus;
import com.uit.vesbookingapi.enums.TicketStatus;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import com.uit.vesbookingapi.mapper.TicketMapper;
import com.uit.vesbookingapi.repository.TicketRepository;
import com.uit.vesbookingapi.repository.TicketTypeRepository;
import com.uit.vesbookingapi.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class TicketService {
    TicketRepository ticketRepository;
    TicketTypeRepository ticketTypeRepository;
    TicketMapper ticketMapper;
    CancellationService cancellationService;
    UserRepository userRepository;

    /**
     * Get user tickets with optional status filter
     */
    public Page<TicketResponse> getUserTickets(TicketStatus status, Pageable pageable) {
        // 1. Get current user
        String userId = getCurrentUserId();

        // 2-3. Build query based on status filter and query with pagination
        Page<Ticket> ticketPage;
        if (status == null) {
            ticketPage = ticketRepository.findByUserIdOrderByPurchaseDateDesc(userId, pageable);
        } else {
            ticketPage = ticketRepository.findByUserIdAndStatusOrderByPurchaseDateDesc(userId, status, pageable);
        }

        // 4. Map to response DTOs
        return ticketPage.map(ticketMapper::toTicketResponse);
    }

    /**
     * Get detailed ticket information
     */
    public TicketDetailResponse getTicketDetails(String ticketId) {
        // 1. Find ticket by ID
        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new AppException(ErrorCode.TICKET_NOT_FOUND));

        // 2. Validate belongs to current user
        String userId = getCurrentUserId();
        if (!ticket.getUser().getId().equals(userId)) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }

        // 3-4. Populate details and return (mapper handles relationships)
        return ticketMapper.toTicketDetailResponse(ticket);
    }

    /**
     * Cancel ticket and process refund
     */
    @Transactional
    public CancellationResponse cancelTicket(String ticketId, CancelTicketRequest request) {
        // 1. Find ticket and validate ownership
        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new AppException(ErrorCode.TICKET_NOT_FOUND));

        String userId = getCurrentUserId();
        if (!ticket.getUser().getId().equals(userId)) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }

        // 2. Validate status is ACTIVE
        if (ticket.getStatus() != TicketStatus.ACTIVE) {
            throw new AppException(ErrorCode.TICKET_NOT_CANCELLABLE);
        }

        // 3. Calculate refund via CancellationService
        CancellationService.CancellationResult refundResult =
                cancellationService.calculateRefund(ticket);

        // 4. Update ticket
        ticket.setStatus(TicketStatus.CANCELLED);
        ticket.setRefundAmount(refundResult.getRefundAmount());
        ticket.setRefundStatus(RefundStatus.PENDING);
        ticket.setCancelledAt(LocalDateTime.now());
        if (request.getReason() != null) {
            ticket.setCancellationReason(request.getReason());
        }

        // 5. Increment ticketType.available atomically
        ticketTypeRepository.incrementAvailable(ticket.getTicketType().getId(), 1);

        // 6. Release seat (if seat was assigned)
        if (ticket.getSeat() != null) {
            ticket.setSeat(null);
        }

        // Save ticket changes
        ticket = ticketRepository.save(ticket);

        // 7. Create notification (TODO: Phase 8 - Notification System)
        // notificationService.createCancellationNotification(ticket);

        // 8. Return cancellation response
        return CancellationResponse.builder()
                .ticketId(ticket.getId())
                .status(ticket.getStatus())
                .refundAmount(refundResult.getRefundAmount())
                .refundPercentage(refundResult.getRefundPercentage())
                .refundStatus(ticket.getRefundStatus())
                .cancelledAt(ticket.getCancelledAt())
                .message("Ticket cancelled successfully. Refund will be processed within 3-5 business days.")
                .build();
    }

    /**
     * Get current authenticated user ID
     */
    private String getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new AppException(ErrorCode.UNAUTHENTICATED);
        }
        // authentication.getName() returns username, not user ID
        String username = authentication.getName();
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED))
                .getId();
    }
}
