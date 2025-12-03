package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.example.qnuquiz.dto.user.UserRegisterDto;
import com.example.qnuquiz.dto.user.UserDto;
import com.example.qnuquiz.entity.Users;

@Mapper(componentModel = "spring")
public interface UserMapper {

    UserDto toDto(Users user);

    List<UserDto> toDtoList(List<Users> users);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "passwordHash", ignore = true)
    @Mapping(target = "role", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "questionses", ignore = true)
    @Mapping(target = "examses", ignore = true)
    @Mapping(target = "feedbacksesForUserId", ignore = true)
    @Mapping(target = "studentses", ignore = true)
    @Mapping(target = "announcementses", ignore = true)
    @Mapping(target = "teacherses", ignore = true)
    @Mapping(target = "mediaFileses", ignore = true)
    @Mapping(target = "classeses", ignore = true)
    @Mapping(target = "feedbacksesForReviewedBy", ignore = true)
    Users toEntity(UserRegisterDto dto);

    @Mapping(target = "passwordHash", ignore = true)
    Users toEntity(UserDto dto);
}
