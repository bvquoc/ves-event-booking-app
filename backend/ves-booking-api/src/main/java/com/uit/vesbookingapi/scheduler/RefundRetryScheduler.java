package com.uit.vesbookingapi.scheduler;

import com.uit.vesbookingapi.dto.zalopay.ZaloPayRefundResponse;
import com.uit.vesbookingapi.entity.Refund;
import com.uit.vesbookingapi.enums.RefundStatus;
import com.uit.vesbookingapi.repository.RefundRepository;
import com.uit.vesbookingapi.service.ZaloPayService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Component
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class RefundRetryScheduler {

    RefundRepository refundRepository;
    ZaloPayService zaloPayService;

    /**
     * Retry failed refunds every 30 minutes
     */
    @Scheduled(fixedRate = 1800000)  // 30 minutes
    @Transactional
    public void retryFailedRefunds() {
        log.info("Checking for pending refunds...");

        List<Refund> pendingRefunds = refundRepository.findByStatus(RefundStatus.PENDING);

        log.info("Found {} pending refunds to retry", pendingRefunds.size());

        for (Refund refund : pendingRefunds) {
            try {
                ZaloPayRefundResponse response = zaloPayService.refund(refund);

                if (response.getReturnCode() == 1) {
                    refund.setStatus(RefundStatus.COMPLETED);
                    refund.setZpRefundId(String.valueOf(response.getRefundId()));
                    log.info("Refund completed: mRefundId={}", refund.getMRefundId());
                } else if (response.getReturnCode() == 2) {
                    refund.setStatus(RefundStatus.PROCESSING);
                    log.info("Refund processing: mRefundId={}", refund.getMRefundId());
                } else {
                    refund.setReturnCode(response.getReturnCode());
                    refund.setReturnMessage(response.getReturnMessage());
                    log.warn("Refund failed: mRefundId={}, code={}, msg={}",
                            refund.getMRefundId(), response.getReturnCode(), response.getReturnMessage());
                    // Keep as PENDING for next retry
                }

                refundRepository.save(refund);

            } catch (Exception e) {
                log.error("Refund retry failed for {}: {}",
                        refund.getMRefundId(), e.getMessage());
            }
        }

        log.info("Refund retry completed");
    }
}
