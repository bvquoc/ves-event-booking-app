package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.dto.request.ValidateVoucherRequest;
import com.uit.vesbookingapi.dto.response.UserVoucherResponse;
import com.uit.vesbookingapi.dto.response.VoucherResponse;
import com.uit.vesbookingapi.dto.response.VoucherValidationResponse;
import com.uit.vesbookingapi.entity.*;
import com.uit.vesbookingapi.enums.VoucherDiscountType;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import com.uit.vesbookingapi.mapper.VoucherMapper;
import com.uit.vesbookingapi.repository.*;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class VoucherService {
    VoucherRepository voucherRepository;
    UserVoucherRepository userVoucherRepository;
    EventRepository eventRepository;
    TicketTypeRepository ticketTypeRepository;
    VoucherMapper voucherMapper;

    /**
     * Get all public vouchers that are currently valid (not expired)
     */
    public List<VoucherResponse> getPublicVouchers() {
        List<Voucher> vouchers = voucherRepository.findPublicActiveVouchers(LocalDateTime.now());
        return vouchers.stream()
                .map(voucherMapper::toVoucherResponse)
                .collect(Collectors.toList());
    }

    /**
     * Get user's vouchers with optional status filter
     * @param status: "active", "used", "expired", or null for all
     */
    public List<UserVoucherResponse> getUserVouchers(String status) {
        String userId = getCurrentUserId();
        LocalDateTime now = LocalDateTime.now();

        List<UserVoucher> userVouchers;
        if (status == null || "all".equalsIgnoreCase(status)) {
            userVouchers = userVoucherRepository.findByUserIdOrderByAddedAtDesc(userId);
        } else if ("active".equalsIgnoreCase(status)) {
            userVouchers = userVoucherRepository.findActiveByUserId(userId, now);
        } else if ("used".equalsIgnoreCase(status)) {
            userVouchers = userVoucherRepository.findUsedByUserId(userId);
        } else if ("expired".equalsIgnoreCase(status)) {
            userVouchers = userVoucherRepository.findExpiredByUserId(userId, now);
        } else {
            throw new AppException(ErrorCode.INVALID_KEY);
        }

        return userVouchers.stream()
                .map(voucherMapper::toUserVoucherResponse)
                .collect(Collectors.toList());
    }

    /**
     * Validate voucher and calculate discount for a specific order
     */
    public VoucherValidationResponse validateVoucher(ValidateVoucherRequest request) {
        // 1. Find voucher by code
        Voucher voucher = voucherRepository.findByCode(request.getVoucherCode())
                .orElseThrow(() -> new AppException(ErrorCode.VOUCHER_NOT_FOUND));

        // 2. Check if expired
        LocalDateTime now = LocalDateTime.now();
        if (now.isBefore(voucher.getStartDate()) || now.isAfter(voucher.getEndDate())) {
            return VoucherValidationResponse.builder()
                    .isValid(false)
                    .message("Voucher is expired or not yet valid")
                    .voucher(voucherMapper.toVoucherResponse(voucher))
                    .build();
        }

        // 3. Check usage limit
        // NOTE: This check is not atomic and may allow concurrent requests to pass.
        // Final enforcement should be done atomically during booking transaction.
        if (voucher.getUsageLimit() != null && voucher.getUsedCount() >= voucher.getUsageLimit()) {
            return VoucherValidationResponse.builder()
                    .isValid(false)
                    .message("Voucher usage limit reached")
                    .voucher(voucherMapper.toVoucherResponse(voucher))
                    .build();
        }

        // 4. Load event and ticket type
        Event event = eventRepository.findById(request.getEventId())
                .orElseThrow(() -> new AppException(ErrorCode.EVENT_NOT_FOUND));

        TicketType ticketType = ticketTypeRepository.findById(request.getTicketTypeId())
                .orElseThrow(() -> new AppException(ErrorCode.TICKET_TYPE_NOT_FOUND));

        // 5. Validate quantity against ticket type limits
        if (ticketType.getMaxPerOrder() != null && request.getQuantity() > ticketType.getMaxPerOrder()) {
            return VoucherValidationResponse.builder()
                    .isValid(false)
                    .message("Quantity exceeds maximum per order: " + ticketType.getMaxPerOrder())
                    .build();
        }

        // 6. Calculate order amount
        int orderAmount = ticketType.getPrice() * request.getQuantity();

        // 7. Check min order amount
        if (voucher.getMinOrderAmount() != null && orderAmount < voucher.getMinOrderAmount()) {
            return VoucherValidationResponse.builder()
                    .isValid(false)
                    .message("Minimum order amount not met: " + voucher.getMinOrderAmount())
                    .orderAmount(orderAmount)
                    .voucher(voucherMapper.toVoucherResponse(voucher))
                    .build();
        }

        // 8. Check if applicable to event/category
        // If both lists are empty, voucher applies to all events
        boolean hasEventRestriction = voucher.getApplicableEvents() != null && !voucher.getApplicableEvents().isEmpty();
        boolean hasCategoryRestriction = voucher.getApplicableCategories() != null && !voucher.getApplicableCategories().isEmpty();

        boolean isApplicable;
        if (!hasEventRestriction && !hasCategoryRestriction) {
            // No restrictions - applies to all events
            isApplicable = true;
        } else {
            // Check if applicable to specific event
            boolean matchesEvent = hasEventRestriction && voucher.getApplicableEvents().contains(event.getId());

            // Check if applicable to event's category
            boolean matchesCategory = hasCategoryRestriction && event.getCategory() != null &&
                    voucher.getApplicableCategories().contains(event.getCategory().getSlug());

            // Voucher applies if it matches either event OR category restriction (OR logic)
            isApplicable = matchesEvent || matchesCategory;
        }

        if (!isApplicable) {
            return VoucherValidationResponse.builder()
                    .isValid(false)
                    .message("Voucher not applicable for this event")
                    .orderAmount(orderAmount)
                    .voucher(voucherMapper.toVoucherResponse(voucher))
                    .build();
        }

        // 9. Calculate discount
        int discountAmount;
        if (voucher.getDiscountType() == VoucherDiscountType.FIXED_AMOUNT) {
            // Validate fixed amount is positive
            if (voucher.getDiscountValue() <= 0) {
                return VoucherValidationResponse.builder()
                        .isValid(false)
                        .message("Invalid voucher discount value")
                        .orderAmount(orderAmount)
                        .voucher(voucherMapper.toVoucherResponse(voucher))
                        .build();
            }
            discountAmount = voucher.getDiscountValue();
        } else { // PERCENTAGE
            // Validate percentage is within valid range (0-100)
            if (voucher.getDiscountValue() <= 0 || voucher.getDiscountValue() > 100) {
                return VoucherValidationResponse.builder()
                        .isValid(false)
                        .message("Invalid voucher discount percentage")
                        .orderAmount(orderAmount)
                        .voucher(voucherMapper.toVoucherResponse(voucher))
                        .build();
            }
            // Use long to prevent overflow
            long discountLong = ((long) orderAmount * voucher.getDiscountValue()) / 100;
            discountAmount = (int) Math.min(discountLong, Integer.MAX_VALUE);

            // Cap at maxDiscount if specified
            if (voucher.getMaxDiscount() != null && discountAmount > voucher.getMaxDiscount()) {
                discountAmount = voucher.getMaxDiscount();
            }
        }

        // Ensure discount doesn't exceed order amount
        if (discountAmount > orderAmount) {
            discountAmount = orderAmount;
        }

        int finalAmount = orderAmount - discountAmount;

        // 10. Return validation result
        return VoucherValidationResponse.builder()
                .isValid(true)
                .message("Voucher is valid")
                .orderAmount(orderAmount)
                .discountAmount(discountAmount)
                .finalAmount(finalAmount)
                .voucher(voucherMapper.toVoucherResponse(voucher))
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
        return authentication.getName();
    }
}
