package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.Voucher;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface VoucherRepository extends JpaRepository<Voucher, String> {

    Optional<Voucher> findByCode(String code);
}
