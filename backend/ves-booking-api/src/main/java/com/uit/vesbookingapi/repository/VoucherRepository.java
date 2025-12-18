package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.Voucher;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface VoucherRepository extends JpaRepository<Voucher, String> {

    Optional<Voucher> findByCode(String code);

    // Find public vouchers that are currently valid (not expired)
    @Query("SELECT v FROM Voucher v WHERE v.isPublic = true AND v.endDate > :now ORDER BY v.endDate ASC")
    List<Voucher> findPublicActiveVouchers(@Param("now") LocalDateTime now);
}
