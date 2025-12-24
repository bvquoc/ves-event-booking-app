package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.request.CancelTicketRequest;
import com.uit.vesbookingapi.dto.response.CancellationResponse;
import com.uit.vesbookingapi.dto.response.TicketDetailResponse;
import com.uit.vesbookingapi.dto.response.TicketResponse;
import com.uit.vesbookingapi.entity.Order;
import com.uit.vesbookingapi.entity.Refund;
import com.uit.vesbookingapi.entity.Ticket;
import com.uit.vesbookingapi.enums.RefundStatus;
import com.uit.vesbookingapi.enums.TicketStatus;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import com.uit.vesbookingapi.mapper.TicketMapper;
import com.uit.vesbookingapi.repository.*;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
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
@Slf4j
public class TicketService {
    TicketRepository ticketRepository;
    TicketTypeRepository ticketTypeRepository;
    TicketMapper ticketMapper;
    CancellationService cancellationService;
    UserRepository userRepository;
    RefundRepository refundRepository;
    OrderRepository orderRepository;

    /**
     * Get user tickets with optional event and status filters
     * Only returns tickets from COMPLETED orders
     */
    public Page<TicketResponse> getUserTickets(String eventId, TicketStatus status, Pageable pageable) {
        // 1. Get current user
        String userId = getCurrentUserId();

        // 2-3. Build query based on filters and query with pagination
        // Only return tickets from COMPLETED orders
        Page<Ticket> ticketPage;
        if (eventId != null && !eventId.isEmpty()) {
            // Filter by event
            if (status == null) {
                ticketPage = ticketRepository.findByUserIdAndEventIdAndOrderCompletedOrderByPurchaseDateDesc(
                        userId, eventId, pageable);
            } else {
                ticketPage = ticketRepository.findByUserIdAndEventIdAndStatusAndOrderCompletedOrderByPurchaseDateDesc(
                        userId, eventId, status, pageable);
            }
        } else {
            // No event filter
            if (status == null) {
                ticketPage = ticketRepository.findByUserIdAndOrderCompletedOrderByPurchaseDateDesc(userId, pageable);
            } else {
                ticketPage = ticketRepository.findByUserIdAndStatusAndOrderCompletedOrderByPurchaseDateDesc(
                        userId, status, pageable);
            }
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

        // 3. Validate order is COMPLETED (only show tickets from completed orders)
        if (ticket.getOrder().getStatus() != com.uit.vesbookingapi.enums.OrderStatus.COMPLETED) {
            throw new AppException(ErrorCode.ORDER_NOT_COMPLETED);
        }

        // 4. Populate details and return (mapper handles relationships)
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

        // 5. Create refund record if payment gateway supports refunds
        // TODO: Implement VNPay refund integration when needed
        Order order = ticket.getOrder();
        if (order.getPaymentGateway() != null && 
                order.getZpTransId() != null &&
                refundResult.getRefundAmount() > 0) {

            // Create refund record for future processing
            String mRefundId = generateMRefundId(ticket.getId());
            Refund refund = Refund.builder()
                    .ticket(ticket)
                    .order(order)
                    .mRefundId(mRefundId)
                    .zpTransId(order.getZpTransId())
                    .amount(refundResult.getRefundAmount())
                    .status(RefundStatus.PENDING)
                    .build();
            refundRepository.save(refund);

            log.info("Refund record created: mRefundId={}, amount={}", mRefundId, refundResult.getRefundAmount());
        }

        // 6. Increment ticketType.available atomically
        ticketTypeRepository.incrementAvailable(ticket.getTicketType().getId(), 1);

        // 7. Release seat (if seat was assigned)
        if (ticket.getSeat() != null) {
            ticket.setSeat(null);
        }

        // Save ticket changes
        ticket = ticketRepository.save(ticket);

        // 8. Create notification (TODO: Phase 8 - Notification System)
        // notificationService.createCancellationNotification(ticket);

        // 9. Return cancellation response
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
     * Generate idempotent m_refund_id: YYMMDD_ticketId
     */
    private String generateMRefundId(String ticketId) {
        String datePart = LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyMMdd"));
        return datePart + "_" + ticketId.substring(0, Math.min(8, ticketId.length()));
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
