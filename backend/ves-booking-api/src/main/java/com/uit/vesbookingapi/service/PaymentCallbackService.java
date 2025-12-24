package com.uit.vesbookingapi.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.uit.vesbookingapi.dto.vnpay.VNPayCallbackData;
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

    /**
     * Process VNPay payment callback (IPN)
     */
    @Transactional
    public void processVNPayPaymentCallback(VNPayCallbackData data, String clientIp) {
        String txnRef = data.getVnpTxnRef();

        log.info("Processing VNPay payment callback: txnRef={}, amount={}, transactionNo={}",
                txnRef, data.getVnpAmount(), data.getVnpTransactionNo());

        // 1. Log audit
        logAudit(null, txnRef, "VNPAY_CALLBACK_RECEIVED", clientIp, toJson(data));

        // 2. Find order by txnRef (appTransId)
        Order order = orderRepository.findByAppTransId(txnRef)
                .orElseThrow(() -> {
                    log.error("Order not found for txnRef: {}", txnRef);
                    return new RuntimeException("Order not found: " + txnRef);
                });

        // 3. Idempotency check: skip if already completed
        if (order.getStatus() == OrderStatus.COMPLETED) {
            log.info("Order already completed, skipping: orderId={}", order.getId());
            return;
        }

        // 4. Verify amount matches (VNPay amount is * 100)
        long vnpAmount = Long.parseLong(data.getVnpAmount());
        if (vnpAmount != order.getTotal() * 100L) {
            log.error("Amount mismatch: expected={}, received={}",
                    order.getTotal() * 100L, vnpAmount);
            throw new RuntimeException("Amount mismatch");
        }

        // 5. Update order status
        order.setStatus(OrderStatus.COMPLETED);
        order.setZpTransId(data.getVnpTransactionNo());  // Store VNPay transaction ID
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
                .appTransId(txnRef)
                .zpTransId(data.getVnpTransactionNo())
                .type(PaymentTransactionType.CALLBACK)
                .status(PaymentTransactionStatus.SUCCESS)
                .amount((int) (vnpAmount / 100))
                .returnCode(0)  // VNPay uses 00 for success
                .returnMessage("Payment confirmed")
                .responsePayload(toJson(data))
                .build();
        transactionRepository.save(tx);

        log.info("VNPay payment confirmed: orderId={}, transactionNo={}",
                order.getId(), data.getVnpTransactionNo());
    }

    /**
     * Process VNPay payment failure
     */
    @Transactional
    public void processVNPayPaymentFailure(VNPayCallbackData data, String clientIp) {
        String txnRef = data.getVnpTxnRef();

        log.info("Processing VNPay payment failure: txnRef={}, responseCode={}",
                txnRef, data.getVnpResponseCode());

        // Find order
        Order order = orderRepository.findByAppTransId(txnRef)
                .orElseThrow(() -> new RuntimeException("Order not found: " + txnRef));

        // Update order status to CANCELLED (if still pending)
        if (order.getStatus() == OrderStatus.PENDING) {
            order.setStatus(OrderStatus.CANCELLED);
            orderRepository.save(order);
        }

        // Log transaction
        PaymentTransaction tx = PaymentTransaction.builder()
                .order(order)
                .appTransId(txnRef)
                .type(PaymentTransactionType.CALLBACK)
                .status(PaymentTransactionStatus.FAILED)
                .amount(order.getTotal())
                .returnCode(Integer.parseInt(data.getVnpResponseCode()))
                .returnMessage("Payment failed: " + data.getVnpResponseCode())
                .responsePayload(toJson(data))
                .build();
        transactionRepository.save(tx);
    }

    /**
     * Check if order exists
     */
    public boolean orderExists(String txnRef) {
        return orderRepository.findByAppTransId(txnRef).isPresent();
    }

    /**
     * Verify amount matches
     */
    public boolean verifyAmount(String txnRef, long amount) {
        return orderRepository.findByAppTransId(txnRef)
                .map(order -> order.getTotal() == amount)
                .orElse(false);
    }

    /**
     * Check if order is pending
     */
    public boolean isOrderPending(String txnRef) {
        return orderRepository.findByAppTransId(txnRef)
                .map(order -> order.getStatus() == OrderStatus.PENDING)
                .orElse(false);
    }

    private String toJson(Object obj) {
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (Exception e) {
            return "{}";
        }
    }
}
