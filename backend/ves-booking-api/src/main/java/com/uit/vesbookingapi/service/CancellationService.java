package com.uit.vesbookingapi.service;

import com.uit.vesbookingapi.entity.Ticket;
import com.uit.vesbookingapi.exception.AppException;
import com.uit.vesbookingapi.exception.ErrorCode;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class CancellationService {

    public CancellationResult calculateRefund(Ticket ticket) {
        LocalDateTime eventStart = ticket.getEvent().getStartDate();
        LocalDateTime now = LocalDateTime.now();
        long hoursUntilEvent = ChronoUnit.HOURS.between(now, eventStart);

        log.info("Calculating refund for ticket {}: event in {} hours", ticket.getId(), hoursUntilEvent);

        if (hoursUntilEvent < 24) {
            log.warn("Ticket {} cannot be cancelled: less than 24 hours until event", ticket.getId());
            throw new AppException(ErrorCode.TICKET_NOT_CANCELLABLE);
        } else if (hoursUntilEvent < 48) {
            // 50% refund for cancellation 24-48 hours before
            int refundAmount = (int) (ticket.getTicketType().getPrice() * 0.5);
            return CancellationResult.builder()
                    .refundAmount(refundAmount)
                    .refundPercentage(50)
                    .build();
        } else {
            // 80% refund for cancellation > 48 hours before
            int refundAmount = (int) (ticket.getTicketType().getPrice() * 0.8);
            return CancellationResult.builder()
                    .refundAmount(refundAmount)
                    .refundPercentage(80)
                    .build();
        }
    }

    @lombok.Data
    @lombok.Builder
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    @FieldDefaults(level = AccessLevel.PRIVATE)
    public static class CancellationResult {
        Integer refundAmount;
        Integer refundPercentage;
    }
}
