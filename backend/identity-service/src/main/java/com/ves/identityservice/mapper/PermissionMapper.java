package com.ves.identityservice.mapper;

import org.mapstruct.Mapper;

import com.ves.identityservice.dto.request.PermissionRequest;
import com.ves.identityservice.dto.response.PermissionResponse;
import com.ves.identityservice.entity.Permission;

@Mapper(componentModel = "spring")
public interface PermissionMapper {
    Permission toPermission(PermissionRequest request);

    PermissionResponse toPermissionResponse(Permission permission);
}
