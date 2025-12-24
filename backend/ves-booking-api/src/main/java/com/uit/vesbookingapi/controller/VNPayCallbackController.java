package com.uit.vesbookingapi.controller;

import com.uit.vesbookingapi.dto.vnpay.VNPayCallbackData;
import com.uit.vesbookingapi.service.PaymentCallbackService;
import com.uit.vesbookingapi.service.VNPayService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * VNPay callback controller
 * Handles IPN (server-to-server) and Return URL (browser redirect)
 */
@RestController
@RequestMapping("/payments/vnpay")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class VNPayCallbackController {

    VNPayService vnPayService;
    PaymentCallbackService callbackService;

    /**
     * VNPay IPN URL (server-to-server callback)
     * GET /api/payments/vnpay/ipn
     * <p>
     * This is called by VNPay server to notify payment result
     * Must return JSON response with RspCode and Message
     */
    @GetMapping("/ipn")
    public ResponseEntity<Map<String, String>> handleIpn(
            @RequestParam Map<String, String> params,
            HttpServletRequest request
    ) {
        String clientIp = getClientIp(request);
        log.info("VNPay IPN received from IP: {}", clientIp);

        Map<String, String> result = new HashMap<>();

        try {
            // Extract secure hash
            String vnpSecureHash = params.get("vnp_SecureHash");
            if (vnpSecureHash == null || vnpSecureHash.isEmpty()) {
                log.error("VNPay IPN missing vnp_SecureHash");
                result.put("RspCode", "97");
                result.put("Message", "Missing checksum");
                return ResponseEntity.ok(result);
            }

            // Verify signature
            if (!vnPayService.verifySignature(params, vnpSecureHash)) {
                log.error("VNPay IPN invalid checksum");
                result.put("RspCode", "97");
                result.put("Message", "Invalid checksum");
                return ResponseEntity.ok(result);
            }

            // Parse callback data
            VNPayCallbackData callbackData = parseCallbackData(params);

            // Check order exists
            boolean checkOrderId = callbackService.orderExists(callbackData.getVnpTxnRef());
            if (!checkOrderId) {
                log.warn("VNPay IPN order not found: txnRef={}", callbackData.getVnpTxnRef());
                result.put("RspCode", "01");
                result.put("Message", "Order not found");
                return ResponseEntity.ok(result);
            }

            // Check amount
            long vnpAmount = Long.parseLong(callbackData.getVnpAmount());
            boolean checkAmount = callbackService.verifyAmount(callbackData.getVnpTxnRef(), vnpAmount / 100);
            if (!checkAmount) {
                log.warn("VNPay IPN invalid amount: txnRef={}, amount={}",
                        callbackData.getVnpTxnRef(), vnpAmount);
                result.put("RspCode", "04");
                result.put("Message", "Invalid amount");
                return ResponseEntity.ok(result);
            }

            // Check order status (idempotency)
            boolean checkOrderStatus = callbackService.isOrderPending(callbackData.getVnpTxnRef());
            if (!checkOrderStatus) {
                log.info("VNPay IPN order already processed: txnRef={}", callbackData.getVnpTxnRef());
                result.put("RspCode", "02");
                result.put("Message", "Order already confirmed");
                return ResponseEntity.ok(result);
            }

            // Process payment callback
            if ("00".equals(callbackData.getVnpResponseCode()) &&
                    "00".equals(callbackData.getVnpTransactionStatus())) {
                // Payment successful
                callbackService.processVNPayPaymentCallback(callbackData, clientIp);
                result.put("RspCode", "00");
                result.put("Message", "Confirm Success");
            } else {
                // Payment failed
                callbackService.processVNPayPaymentFailure(callbackData, clientIp);
                result.put("RspCode", "00");
                result.put("Message", "Confirm Success");
            }

            log.info("VNPay IPN processed successfully: txnRef={}, responseCode={}",
                    callbackData.getVnpTxnRef(), callbackData.getVnpResponseCode());

        } catch (Exception e) {
            log.error("VNPay IPN processing error: {}", e.getMessage(), e);
            result.put("RspCode", "99");
            result.put("Message", "Unknown error");
        }

        return ResponseEntity.ok(result);
    }

    /**
     * VNPay Return URL (browser redirect after payment)
     * GET /api/payments/vnpay/return
     * <p>
     * This is where user is redirected after payment
     * Only verify signature and display result to user
     * Do NOT update order status here (use IPN for that)
     */
    @GetMapping("/return")
    public ResponseEntity<Map<String, Object>> handleReturn(
            @RequestParam Map<String, String> params,
            HttpServletRequest request
    ) {
        String clientIp = getClientIp(request);
        log.info("VNPay Return URL accessed from IP: {}", clientIp);

        Map<String, Object> result = new HashMap<>();

        try {
            // Extract secure hash
            String vnpSecureHash = params.get("vnp_SecureHash");
            if (vnpSecureHash == null || vnpSecureHash.isEmpty()) {
                result.put("success", false);
                result.put("message", "Missing checksum");
                return ResponseEntity.ok(result);
            }

            // Verify signature
            if (!vnPayService.verifySignature(params, vnpSecureHash)) {
                result.put("success", false);
                result.put("message", "Invalid checksum");
                return ResponseEntity.ok(result);
            }

            // Parse callback data
            VNPayCallbackData callbackData = parseCallbackData(params);

            // Check payment result
            if ("00".equals(callbackData.getVnpResponseCode()) &&
                    "00".equals(callbackData.getVnpTransactionStatus())) {
                result.put("success", true);
                result.put("message", "Giao dich thanh cong");
                result.put("orderId", callbackData.getVnpTxnRef());
                result.put("transactionNo", callbackData.getVnpTransactionNo());
            } else {
                result.put("success", false);
                result.put("message", "Giao dich khong thanh cong");
                result.put("responseCode", callbackData.getVnpResponseCode());
            }

        } catch (Exception e) {
            log.error("VNPay Return URL processing error: {}", e.getMessage(), e);
            result.put("success", false);
            result.put("message", "Error processing return");
        }

        return ResponseEntity.ok(result);
    }

    /**
     * Parse callback parameters to VNPayCallbackData
     */
    private VNPayCallbackData parseCallbackData(Map<String, String> params) {
        return VNPayCallbackData.builder()
                .vnpTmnCode(params.get("vnp_TmnCode"))
                .vnpAmount(params.get("vnp_Amount"))
                .vnpBankCode(params.get("vnp_BankCode"))
                .vnpBankTranNo(params.get("vnp_BankTranNo"))
                .vnpCardType(params.get("vnp_CardType"))
                .vnpPayDate(params.get("vnp_PayDate"))
                .vnpOrderInfo(params.get("vnp_OrderInfo"))
                .vnpTransactionNo(params.get("vnp_TransactionNo"))
                .vnpResponseCode(params.get("vnp_ResponseCode"))
                .vnpTransactionStatus(params.get("vnp_TransactionStatus"))
                .vnpTxnRef(params.get("vnp_TxnRef"))
                .vnpSecureHash(params.get("vnp_SecureHash"))
                .vnpSecureHashType(params.get("vnp_SecureHashType"))
                .build();
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty()) {
            ip = request.getRemoteAddr();
        } else {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }
}

