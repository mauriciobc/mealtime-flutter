// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      authId: json['auth_id'] as String?,
      fullName: json['full_name'] as String?,
      email: json['email'] as String,
      householdId: json['household_id'] as String?,
      household: json['household'] == null
          ? null
          : HouseholdModel.fromJson(json['household'] as Map<String, dynamic>),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      currentHomeId: json['current_home_id'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'auth_id': instance.authId,
      'full_name': instance.fullName,
      'email': instance.email,
      'household_id': instance.householdId,
      'household': instance.household,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updated_at': value,
      'is_email_verified': instance.isEmailVerified,
      'current_home_id': instance.currentHomeId,
    };
