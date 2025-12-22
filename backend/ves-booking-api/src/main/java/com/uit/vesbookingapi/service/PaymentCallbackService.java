package com.uit.vesbookingapi.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.uit.vesbookingapi.dto.zalopay.ZaloPayCallbackData;
import com.uit.vesbookingapi.entity.*;
import com.uit.vesbookingapi.enums.*;
import com.uit.vesbookingapi.repository.*;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class PaymentCallbackService {

    OrderRepository orderRepository;
    TicketRepository ticketRepository;
    PaymentTransactionRepository transactionRepository;
    PaymentAuditLogRepository auditLogRepository;
    RefundRepository refundRepository;
    ObjectMapper objectMapper;

    @Transactional
    public void processPaymentCallback(ZaloPayCallbackData data, String clientIp) {
        String appTransId = data.getAppTransId();

        log.info("Processing payment callback: appTransId={}, amount={}, zpTransId={}",
                appTransId, data.getAmount(), data.getZpTransId());

        // 1. Log audit
        logAudit(null, appTransId, "CALLBACK_RECEIVED", clientIp, toJson(data));

        // 2. Find order by appTransId
        Order order = orderRepository.findByAppTransId(appTransId)
                .orElseThrow(() -> {
                    log.error("Order not found for appTransId: {}", appTransId);
                    return new RuntimeException("Order not found: " + appTransId);
                });

        // 3. Idempotency check: skip if already completed
        if (order.getStatus() == OrderStatus.COMPLETED) {
            log.info("Order already completed, skipping: orderId={}", order.getId());
            return;
        }

        // 4. Verify amount matches
        if (data.getAmount() != order.getTotal().longValue()) {
            log.error("Amount mismatch: expected={}, received={}",
                    order.getTotal(), data.getAmount());
            throw new RuntimeException("Amount mismatch");
        }

        // 5. Update order status
        order.setStatus(OrderStatus.COMPLETED);
        order.setZpTransId(data.getZpTransId());
        order.setPaymentConfirmedAt(LocalDateTime.now());
        order.setCompletedAt(LocalDateTime.now());
        orderRepository.save(order);

        // 6. Update ticket statuses
        ticketRepository.findByOrderId(order.getId()).forEach(ticket -> {
            ticket.setStatus(TicketStatus.ACTIVE);
            ticket.setPurchaseDate(LocalDateTime.now());
        });

        // 7. Save transaction record
        PaymentTransaction tx = PaymentTransaction.builder()
                .order(order)
                .appTransId(appTransId)
                .zpTransId(data.getZpTransId())
                .type(PaymentTransactionType.CALLBACK)
                .status(PaymentTransactionStatus.SUCCESS)
                .amount(data.getAmount().intValue())
                .returnCode(1)
                .returnMessage("Payment confirmed")
                .responsePayload(toJson(data))
                .build();
        transactionRepository.save(tx);

        log.info("Payment confirmed: orderId={}, zpTransId={}",
                order.getId(), data.getZpTransId());
    }

    @Transactional
    public void processRefundCallback(String data, String clientIp) {
        try {
            @SuppressWarnings("unchecked")
            var refundData = objectMapper.readValue(data, java.util.Map.class);

            String mRefundId = (String) refundData.get("m_refund_id");
            Integer returnCode = (Integer) refundData.get("return_code");

            log.info("Processing refund callback: mRefundId={}, returnCode={}",
                    mRefundId, returnCode);

            Refund refund = refundRepository.findByMRefundId(mRefundId)
                    .orElseThrow(() -> new RuntimeException("Refund not found: " + mRefundId));

            if (returnCode == 1) {
                refund.setStatus(RefundStatus.COMPLETED);
                refund.setProcessedAt(LocalDateTime.now());

                // Update ticket refund status
                Ticket ticket = refund.getTicket();
                ticket.setRefundStatus(RefundStatus.COMPLETED);
                ticketRepository.save(ticket);

            } else if (returnCode == 3) {
                refund.setStatus(RefundStatus.FAILED);
                refund.setReturnCode(returnCode);
                refund.setReturnMessage((String) refundData.get("return_message"));
            }
            // returnCode == 2 means still processing, don't update

            refundRepository.save(refund);

        } catch (Exception e) {
            log.error("Error processing refund callback: {}", e.getMessage(), e);
            throw new RuntimeException("Refund callback processing error", e);
        }
    }

    private void logAudit(String orderId, String appTransId, String action,
                          String ipAddress, String payload) {
        PaymentAuditLog log = PaymentAuditLog.builder()
                .orderId(orderId)
                .appTransId(appTransId)
                .action(action)
                .ipAddress(ipAddress)
                .payload(payload)
                .build();
        auditLogRepository.save(log);
    }

    private String toJson(Object obj) {
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (Exception e) {
            return "{}";
        }
    }
}
