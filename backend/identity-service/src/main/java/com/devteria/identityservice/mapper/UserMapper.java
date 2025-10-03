package com.devteria.identityservice.mapper;

import com.devteria.identityservice.dto.request.OAuth2Request;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

import com.devteria.identityservice.dto.request.UserCreationRequest;
import com.devteria.identityservice.dto.request.UserUpdateRequest;
import com.devteria.identityservice.dto.response.UserResponse;
import com.devteria.identityservice.entity.User;
import org.mapstruct.Mappings;

@Mapper(componentModel = "spring")
public interface UserMapper {
    User toUser(UserCreationRequest request);

    @Mappings({
        @Mapping(target = "username", expression = "java(request.getUsername())"),
    })
    User toUser(OAuth2Request request);

    UserResponse toUserResponse(User user);

    @Mapping(target = "roles", ignore = true)
    void updateUser(@MappingTarget User user, UserUpdateRequest request);
}
