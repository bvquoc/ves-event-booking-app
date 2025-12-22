package com.uit.vesbookingapi.payment.zalopay;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.uit.vesbookingapi.dto.request.ApiResponse;
import com.uit.vesbookingapi.payment.zalopay.dto.ZaloPayCallbackRequest;
import com.uit.vesbookingapi.payment.zalopay.dto.ZaloPayQueryStatusResponse;
import com.uit.vesbookingapi.repository.OrderRepository;
import com.uit.vesbookingapi.service.OrderService;
import com.uit.vesbookingapi.entity.Order;
import com.uit.vesbookingapi.enums.OrderStatus;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/payments/zalopay")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class ZaloPayController {
    ZaloPayService zaloPayService;
    OrderService orderService;
    OrderRepository orderRepository;
    ObjectMapper objectMapper;

    public ZaloPayController(ZaloPayService zaloPayService, OrderService orderService, 
                            OrderRepository orderRepository, ObjectMapper objectMapper) {
        this.zaloPayService = zaloPayService;
        this.orderService = orderService;
        this.orderRepository = orderRepository;
        this.objectMapper = objectMapper;
    }

    /**
     * Callback endpoint - ZaloPay will call this after payment
     * POST /api/payments/zalopay/callback
     */
    @PostMapping("/callback")
    public ResponseEntity<Map<String, Object>> handleCallback(
            @RequestParam Map<String, String> params) {
        log.info("Received ZaloPay callback: {}", params);

        try {
            // Parse callback data
            String dataStr = params.get("data");
            String mac = params.get("mac");

            if (dataStr == null || mac == null) {
                log.error("Missing data or mac in callback");
                return ResponseEntity.badRequest().body(createErrorResponse(2, "Missing data or mac"));
            }

            // Parse data JSON
            Map<String, Object> dataMap = objectMapper.readValue(dataStr, Map.class);
            
            ZaloPayCallbackRequest callbackRequest = ZaloPayCallbackRequest.builder()
                    .appId((String) dataMap.get("app_id"))
                    .appTransId((String) dataMap.get("app_trans_id"))
                    .pmcid(dataMap.get("pmcid") != null ? Long.valueOf(dataMap.get("pmcid").toString()) : null)
                    .bankCode((String) dataMap.get("bank_code"))
                    .amount(Long.valueOf(dataMap.get("amount").toString()))
                    .discountAmount(dataMap.get("discount_amount") != null 
                            ? Long.valueOf(dataMap.get("discount_amount").toString()) : 0L)
                    .status(Integer.valueOf(dataMap.get("status").toString()))
                    .mac(mac)
                    .build();

            // Verify signature
            boolean isValid = zaloPayService.verifyCallback(callbackRequest);
            if (!isValid) {
                log.error("Invalid ZaloPay callback signature");
                return ResponseEntity.badRequest().body(createErrorResponse(2, "Invalid signature"));
            }

            // Find order by ZaloPay transaction ID (app_trans_id)
            Order order = orderRepository.findByZalopayTransactionId(callbackRequest.getAppTransId());
            if (order == null) {
                log.error("Order not found for app_trans_id: {}", callbackRequest.getAppTransId());
                return ResponseEntity.badRequest().body(createErrorResponse(2, "Order not found"));
            }

            // Verify amount matches
            if (order.getTotal().longValue() != callbackRequest.getAmount()) {
                log.error("Amount mismatch: order={}, callback={}", order.getTotal(), callbackRequest.getAmount());
                return ResponseEntity.badRequest().body(createErrorResponse(2, "Amount mismatch"));
            }

            // Process payment based on status
            // Status: 1 = success, 2 = failed, 3 = processing
            if (callbackRequest.getStatus() == 1) {
                // Payment successful
                if (order.getStatus() == OrderStatus.PENDING) {
                    order.setZalopayTransactionId(callbackRequest.getAppTransId());
                    orderService.completeOrder(order.getId());
                    log.info("Order completed via ZaloPay callback: orderId={}, appTransId={}",
                            order.getId(), callbackRequest.getAppTransId());
                } else {
                    log.warn("Order already processed: orderId={}, status={}", order.getId(), order.getStatus());
                }
            } else {
                log.warn("ZaloPay payment failed or processing: orderId={}, status={}",
                        order.getId(), callbackRequest.getStatus());
            }

            // Return success response to ZaloPay
            return ResponseEntity.ok(createSuccessResponse());

        } catch (Exception e) {
            log.error("Error processing ZaloPay callback", e);
            return ResponseEntity.badRequest().body(createErrorResponse(2, "Internal error"));
        }
    }

    /**
     * Query payment status
     * GET /api/payments/zalopay/status/{orderId}
     */
    @GetMapping("/status/{orderId}")
    public ApiResponse<ZaloPayQueryStatusResponse> queryPaymentStatus(@PathVariable String orderId) {
        Order order = orderService.getOrderById(orderId);
        
        if (order.getZalopayTransactionId() == null) {
            throw new RuntimeException("Order does not have ZaloPay transaction ID");
        }

        ZaloPayQueryStatusResponse response = zaloPayService.queryPaymentStatus(order.getZalopayTransactionId());
        
        return ApiResponse.<ZaloPayQueryStatusResponse>builder()
                .result(response)
                .build();
    }

    private Map<String, Object> createSuccessResponse() {
        Map<String, Object> response = new HashMap<>();
        response.put("return_code", 1);
        response.put("return_message", "success");
        return response;
    }

    private Map<String, Object> createErrorResponse(int returnCode, String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("return_code", returnCode);
        response.put("return_message", message);
        return response;
    }
}

