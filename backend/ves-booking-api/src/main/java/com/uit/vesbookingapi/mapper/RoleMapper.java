package com.uit.vesbookingapi.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.uit.vesbookingapi.dto.request.RoleRequest;
import com.uit.vesbookingapi.dto.response.RoleResponse;
import com.uit.vesbookingapi.entity.Role;

@Mapper(componentModel = "spring")
public interface RoleMapper {
    @Mapping(target = "permissions", ignore = true)
    Role toRole(RoleRequest request);

    RoleResponse toRoleResponse(Role role);
}
