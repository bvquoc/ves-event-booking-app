package com.uit.vesbookingapi.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.uit.vesbookingapi.entity.Permission;

@Repository
public interface PermissionRepository extends JpaRepository<Permission, String> {}
