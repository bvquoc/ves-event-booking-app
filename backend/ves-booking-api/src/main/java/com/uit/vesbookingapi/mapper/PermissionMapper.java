package com.uit.vesbookingapi.mapper;

import com.uit.vesbookingapi.dto.request.PermissionRequest;
import com.uit.vesbookingapi.dto.response.PermissionResponse;
import com.uit.vesbookingapi.entity.Permission;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface PermissionMapper {
    Permission toPermission(PermissionRequest request);

    PermissionResponse toPermissionResponse(Permission permission);
}
