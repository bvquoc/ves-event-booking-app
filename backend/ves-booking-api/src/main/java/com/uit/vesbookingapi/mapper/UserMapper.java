package com.uit.vesbookingapi.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

import com.uit.vesbookingapi.dto.request.UserCreationRequest;
import com.uit.vesbookingapi.dto.request.UserUpdateRequest;
import com.uit.vesbookingapi.dto.response.UserResponse;
import com.uit.vesbookingapi.entity.User;

@Mapper(componentModel = "spring")
public interface UserMapper {
    User toUser(UserCreationRequest request);

    UserResponse toUserResponse(User user);

    @Mapping(target = "roles", ignore = true)
    void updateUser(@MappingTarget User user, UserUpdateRequest request);
}
