package com.uit.vesbookingapi.scheduler;

import com.uit.vesbookingapi.dto.zalopay.ZaloPayQueryResponse;
import com.uit.vesbookingapi.entity.Order;
import com.uit.vesbookingapi.entity.Ticket;
import com.uit.vesbookingapi.enums.OrderStatus;
import com.uit.vesbookingapi.enums.TicketStatus;
import com.uit.vesbookingapi.repository.OrderRepository;
import com.uit.vesbookingapi.repository.TicketRepository;
import com.uit.vesbookingapi.repository.TicketTypeRepository;
import com.uit.vesbookingapi.service.ZaloPayService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Component
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class PaymentReconciliationScheduler {

    OrderRepository orderRepository;
    TicketRepository ticketRepository;
    TicketTypeRepository ticketTypeRepository;
    ZaloPayService zaloPayService;

    /**
     * Query pending orders every 5 minutes
     * Check orders that have been pending for more than 5 minutes
     */
    @Scheduled(fixedRate = 300000)  // 5 minutes
    @Transactional
    public void reconcilePendingOrders() {
        log.info("Starting payment reconciliation...");

        LocalDateTime threshold = LocalDateTime.now().minusMinutes(5);
        List<Order> pendingOrders = orderRepository.findPendingOrdersOlderThan(threshold);

        log.info("Found {} pending orders to reconcile", pendingOrders.size());

        for (Order order : pendingOrders) {
            try {
                reconcileOrder(order);
            } catch (Exception e) {
                log.error("Error reconciling order {}: {}", order.getId(), e.getMessage());
            }
        }

        log.info("Payment reconciliation completed");
    }

    /**
     * Expire old pending orders every 15 minutes
     */
    @Scheduled(fixedRate = 900000)  // 15 minutes
    @Transactional
    public void expirePendingOrders() {
        log.info("Checking for expired orders...");

        List<Order> expiredOrders = orderRepository.findExpiredPendingOrders(LocalDateTime.now());

        for (Order order : expiredOrders) {
            try {
                expireOrder(order);
            } catch (Exception e) {
                log.error("Error expiring order {}: {}", order.getId(), e.getMessage());
            }
        }

        log.info("Expired {} orders", expiredOrders.size());
    }

    private void reconcileOrder(Order order) {
        if (order.getAppTransId() == null) {
            log.warn("Order {} has no appTransId, skipping", order.getId());
            return;
        }

        log.info("Reconciling order: orderId={}, appTransId={}",
                order.getId(), order.getAppTransId());

        ZaloPayQueryResponse response = zaloPayService.queryOrder(order.getAppTransId());

        switch (response.getReturnCode()) {
            case 1:  // Paid
                log.info("Order {} confirmed as paid via query", order.getId());
                order.setStatus(OrderStatus.COMPLETED);
                order.setZpTransId(response.getZpTransId());
                order.setPaymentConfirmedAt(LocalDateTime.now());
                order.setCompletedAt(LocalDateTime.now());
                orderRepository.save(order);

                // Update tickets
                ticketRepository.findByOrderId(order.getId()).forEach(ticket -> {
                    ticket.setStatus(TicketStatus.ACTIVE);
                    ticket.setPurchaseDate(LocalDateTime.now());
                });
                break;

            case 2:  // Still pending
                log.debug("Order {} still pending", order.getId());
                // Check if expired
                if (order.getExpiresAt() != null &&
                        LocalDateTime.now().isAfter(order.getExpiresAt())) {
                    expireOrder(order);
                }
                break;

            case 3:  // Failed
                log.info("Order {} payment failed", order.getId());
                expireOrder(order);
                break;

            default:
                log.warn("Unknown return code {} for order {}",
                        response.getReturnCode(), order.getId());
        }
    }

    private void expireOrder(Order order) {
        log.info("Expiring order: orderId={}", order.getId());

        order.setStatus(OrderStatus.EXPIRED);
        orderRepository.save(order);

        // Release tickets
        List<Ticket> tickets = ticketRepository.findByOrderId(order.getId());
        for (Ticket ticket : tickets) {
            ticket.setStatus(TicketStatus.CANCELLED);
            ticketRepository.save(ticket);

            // Return ticket to pool
            ticketTypeRepository.incrementAvailable(ticket.getTicketType().getId(), 1);
        }

        log.info("Order {} expired, released {} tickets", order.getId(), tickets.size());
    }
}
