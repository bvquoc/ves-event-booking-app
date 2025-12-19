package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.UserVoucher;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface UserVoucherRepository extends JpaRepository<UserVoucher, String> {

    // All user vouchers ordered by addedAt
    List<UserVoucher> findByUserIdOrderByAddedAtDesc(String userId);

    // Active vouchers (not used + not expired)
    @Query("SELECT uv FROM UserVoucher uv WHERE uv.user.id = :userId " +
           "AND uv.isUsed = false " +
           "AND uv.voucher.endDate > :now " +
           "ORDER BY uv.addedAt DESC")
    List<UserVoucher> findActiveByUserId(@Param("userId") String userId, @Param("now") LocalDateTime now);

    // Used vouchers
    @Query("SELECT uv FROM UserVoucher uv WHERE uv.user.id = :userId " +
           "AND uv.isUsed = true " +
           "ORDER BY uv.usedAt DESC")
    List<UserVoucher> findUsedByUserId(@Param("userId") String userId);

    // Expired vouchers (not used + expired)
    @Query("SELECT uv FROM UserVoucher uv WHERE uv.user.id = :userId " +
           "AND uv.isUsed = false " +
           "AND uv.voucher.endDate < :now " +
           "ORDER BY uv.addedAt DESC")
    List<UserVoucher> findExpiredByUserId(@Param("userId") String userId, @Param("now") LocalDateTime now);
}
