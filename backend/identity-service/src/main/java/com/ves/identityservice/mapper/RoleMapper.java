package com.ves.identityservice.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.ves.identityservice.dto.request.RoleRequest;
import com.ves.identityservice.dto.response.RoleResponse;
import com.ves.identityservice.entity.Role;

@Mapper(componentModel = "spring")
public interface RoleMapper {
    @Mapping(target = "permissions", ignore = true)
    Role toRole(RoleRequest request);

    RoleResponse toRoleResponse(Role role);
}
