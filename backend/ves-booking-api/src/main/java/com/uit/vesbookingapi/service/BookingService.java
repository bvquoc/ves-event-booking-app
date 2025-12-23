package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.request.PurchaseRequest;
import com.uit.vesbookingapi.dto.response.PurchaseResponse;
import com.uit.vesbookingapi.dto.zalopay.ZaloPayCreateResponse;
import com.uit.vesbookingapi.entity.*;
import com.uit.vesbookingapi.enums.OrderStatus;
import com.uit.vesbookingapi.enums.TicketStatus;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import com.uit.vesbookingapi.mapper.OrderMapper;
import com.uit.vesbookingapi.repository.*;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class BookingService {
    OrderRepository orderRepository;
    TicketRepository ticketRepository;
    EventRepository eventRepository;
    TicketTypeRepository ticketTypeRepository;
    SeatRepository seatRepository;
    UserRepository userRepository;
    VoucherRepository voucherRepository;
    OrderMapper orderMapper;
    ZaloPayService zaloPayService;

    @Transactional(isolation = Isolation.SERIALIZABLE)
    public PurchaseResponse purchaseTickets(PurchaseRequest request) {
        log.info("Processing ticket purchase request: eventId={}, ticketTypeId={}, quantity={}",
                request.getEventId(), request.getTicketTypeId(), request.getQuantity());

        // Get current user
        User currentUser = getCurrentUser();

        // 1. Validate event exists
        Event event = eventRepository.findById(request.getEventId())
                .orElseThrow(() -> new AppException(ErrorCode.EVENT_NOT_FOUND));

        // 2. Validate and lock ticket type
        TicketType ticketType = ticketTypeRepository.findById(request.getTicketTypeId())
                .orElseThrow(() -> new AppException(ErrorCode.TICKET_TYPE_NOT_FOUND));

        // 3. Validate ticket type belongs to event
        if (!ticketType.getEvent().getId().equals(event.getId())) {
            throw new AppException(ErrorCode.INVALID_TICKET_QUANTITY);
        }

        // 4. Check ticket availability
        if (ticketType.getAvailable() < request.getQuantity()) {
            throw new AppException(ErrorCode.TICKETS_UNAVAILABLE);
        }

        // 5. Check max per order limit
        if (ticketType.getMaxPerOrder() != null && request.getQuantity() > ticketType.getMaxPerOrder()) {
            throw new AppException(ErrorCode.INVALID_TICKET_QUANTITY);
        }

        // 6. Handle seat selection if required
        List<Seat> selectedSeats = new ArrayList<>();
        if (ticketType.getRequiresSeatSelection()) {
            if (request.getSeatIds() == null || request.getSeatIds().isEmpty()) {
                throw new AppException(ErrorCode.SEAT_SELECTION_REQUIRED);
            }

            if (request.getSeatIds().size() != request.getQuantity()) {
                throw new AppException(ErrorCode.INVALID_TICKET_QUANTITY);
            }

            // Check seats are available with pessimistic locking to prevent double booking
            List<String> occupiedSeats = ticketRepository.findOccupiedSeatIdsWithLock(
                    request.getEventId(),
                    request.getSeatIds()
            );

            if (!occupiedSeats.isEmpty()) {
                throw new AppException(ErrorCode.SEAT_ALREADY_TAKEN);
            }

            // Load seat entities
            selectedSeats = seatRepository.findAllById(request.getSeatIds());
            if (selectedSeats.size() != request.getSeatIds().size()) {
                throw new AppException(ErrorCode.SEAT_NOT_FOUND);
            }
        }

        // 7. Validate voucher if provided
        Voucher voucher = null;
        int discount = 0;

        if (request.getVoucherCode() != null && !request.getVoucherCode().trim().isEmpty()) {
            voucher = validateAndApplyVoucher(
                    request.getVoucherCode(),
                    event,
                    ticketType.getPrice() * request.getQuantity()
            );
            discount = calculateVoucherDiscount(voucher, ticketType.getPrice() * request.getQuantity());
        }

        // 8. Calculate pricing
        int subtotal = ticketType.getPrice() * request.getQuantity();
        int total = subtotal - discount;

        // 9. Create order (WITHOUT paymentUrl initially)
        Order order = Order.builder()
                .user(currentUser)
                .event(event)
                .ticketType(ticketType)
                .quantity(request.getQuantity())
                .subtotal(subtotal)
                .discount(discount)
                .total(total)
                .currency(ticketType.getCurrency())
                .voucher(voucher)
                .status(OrderStatus.PENDING)
                .paymentMethod(request.getPaymentMethod())
                .paymentGateway("ZALOPAY")
                .expiresAt(LocalDateTime.now().plusMinutes(15))
                .build();

        order = orderRepository.save(order);
        log.info("Order created: orderId={}, total={}", order.getId(), order.getTotal());

        // 10. Call ZaloPay Create Order API
        try {
            ZaloPayCreateResponse zpResponse = zaloPayService.createOrder(order);

            if (zpResponse.getReturnCode() != 1) {
                log.error("ZaloPay order creation failed: code={}, msg={}",
                        zpResponse.getReturnCode(), zpResponse.getReturnMessage());
                // Rollback: release tickets
                ticketType.setAvailable(ticketType.getAvailable() + request.getQuantity());
                ticketTypeRepository.save(ticketType);
                order.setStatus(OrderStatus.CANCELLED);
                orderRepository.save(order);
                throw new AppException(ErrorCode.PAYMENT_GATEWAY_ERROR);
            }

            // Update order with ZaloPay data
            order.setAppTransId(zaloPayService.generateAppTransId(order.getId()));
            order.setPaymentUrl(zpResponse.getOrderUrl());
            orderRepository.save(order);

        } catch (AppException e) {
            throw e;
        } catch (Exception e) {
            log.error("Payment gateway error: {}", e.getMessage());
            // Rollback
            ticketType.setAvailable(ticketType.getAvailable() + request.getQuantity());
            ticketTypeRepository.save(ticketType);
            order.setStatus(OrderStatus.CANCELLED);
            orderRepository.save(order);
            throw new AppException(ErrorCode.PAYMENT_GATEWAY_ERROR);
        }

        // 11. Increment voucher usage count if voucher was applied
        if (voucher != null) {
            voucher.setUsedCount(voucher.getUsedCount() + 1);
            voucherRepository.save(voucher);
            log.info("Voucher usage incremented: code={}, usedCount={}", voucher.getCode(), voucher.getUsedCount());
        }

        // 12. Create tickets (reserved state)
        List<Ticket> tickets = new ArrayList<>();
        for (int i = 0; i < request.getQuantity(); i++) {
            Seat seat = ticketType.getRequiresSeatSelection() ? selectedSeats.get(i) : null;

            Ticket ticket = Ticket.builder()
                    .order(order)
                    .user(currentUser)
                    .event(event)
                    .ticketType(ticketType)
                    .seat(seat)
                    .qrCode(generateQrCode())
                    .qrCodeImage(null) // Generate image later
                    .status(TicketStatus.ACTIVE) // Mark as ACTIVE for pending orders
                    .purchaseDate(LocalDateTime.now())
                    .build();

            tickets.add(ticket);
        }

        ticketRepository.saveAll(tickets);
        log.info("Created {} tickets for order {}", tickets.size(), order.getId());

        // 13. Decrement available count (optimistic lock will prevent overselling)
        ticketType.setAvailable(ticketType.getAvailable() - request.getQuantity());
        ticketTypeRepository.save(ticketType);

        log.info("Ticket purchase successful: orderId={}, paymentUrl={}",
                order.getId(), order.getPaymentUrl());

        return orderMapper.toPurchaseResponse(order);
    }

    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));
    }

    private Voucher validateAndApplyVoucher(String code, Event event, int orderAmount) {
        Voucher voucher = voucherRepository.findByCode(code)
                .orElseThrow(() -> new AppException(ErrorCode.VOUCHER_NOT_FOUND));

        LocalDateTime now = LocalDateTime.now();

        // Check voucher validity period
        if (now.isBefore(voucher.getStartDate()) || now.isAfter(voucher.getEndDate())) {
            throw new AppException(ErrorCode.VOUCHER_INVALID);
        }

        // Check usage limit
        if (voucher.getUsageLimit() != null && voucher.getUsedCount() >= voucher.getUsageLimit()) {
            throw new AppException(ErrorCode.VOUCHER_USAGE_LIMIT_REACHED);
        }

        // Check minimum order amount
        if (voucher.getMinOrderAmount() != null && orderAmount < voucher.getMinOrderAmount()) {
            throw new AppException(ErrorCode.VOUCHER_MIN_ORDER_NOT_MET);
        }

        // Check if voucher is applicable to this event/category
        if (voucher.getApplicableEvents() != null && !voucher.getApplicableEvents().isEmpty()) {
            boolean isApplicable = voucher.getApplicableEvents().contains(event.getId());
            if (!isApplicable) {
                throw new AppException(ErrorCode.VOUCHER_NOT_APPLICABLE);
            }
        }

        if (voucher.getApplicableCategories() != null && !voucher.getApplicableCategories().isEmpty()) {
            boolean isApplicable = voucher.getApplicableCategories().contains(event.getCategory().getSlug());
            if (!isApplicable) {
                throw new AppException(ErrorCode.VOUCHER_NOT_APPLICABLE);
            }
        }

        return voucher;
    }

    private int calculateVoucherDiscount(Voucher voucher, int orderAmount) {
        int discount = 0;

        switch (voucher.getDiscountType()) {
            case PERCENTAGE:
                discount = (int) (orderAmount * voucher.getDiscountValue() / 100.0);
                break;
            case FIXED_AMOUNT:
                discount = voucher.getDiscountValue();
                break;
        }

        // Apply max discount cap if exists
        if (voucher.getMaxDiscount() != null && discount > voucher.getMaxDiscount()) {
            discount = voucher.getMaxDiscount();
        }

        return Math.min(discount, orderAmount); // Discount cannot exceed order amount
    }

    private String generatePaymentUrl() {
        return "http://ves-booking.io.vn/payments/order/" + UUID.randomUUID();
    }

    private String generateQrCode() {
        return "VES" + UUID.randomUUID().toString().replace("-", "").substring(0, 12).toUpperCase();
    }
}
