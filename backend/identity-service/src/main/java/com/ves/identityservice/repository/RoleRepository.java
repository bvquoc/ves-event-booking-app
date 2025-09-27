package com.ves.identityservice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.ves.identityservice.entity.Role;

@Repository
public interface RoleRepository extends JpaRepository<Role, String> {}
