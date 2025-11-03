// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      timezone: json['timezone'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'full_name': instance.fullName,
      'email': instance.email,
      'avatar_url': instance.avatarUrl,
      'timezone': instance.timezone,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

ProfileInputModel _$ProfileInputModelFromJson(Map<String, dynamic> json) =>
    ProfileInputModel(
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      timezone: json['timezone'] as String?,
    );

Map<String, dynamic> _$ProfileInputModelToJson(ProfileInputModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'full_name': instance.fullName,
      'avatar_url': instance.avatarUrl,
      'timezone': instance.timezone,
    };
