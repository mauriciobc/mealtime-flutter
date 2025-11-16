// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HouseholdModel _$HouseholdModelFromJson(Map<String, dynamic> json) =>
    HouseholdModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['owner_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      owner: json['owner'] == null
          ? null
          : HouseholdOwner.fromJson(json['owner'] as Map<String, dynamic>),
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => HouseholdMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      householdMembers: (json['household_members'] as List<dynamic>?)
          ?.map(
            (e) => HouseholdMemberDetailed.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      inviteCode: json['inviteCode'] as String?,
    );

Map<String, dynamic> _$HouseholdModelToJson(HouseholdModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'owner_id': instance.ownerId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'owner': instance.owner?.toJson(),
      'members': instance.members?.map((e) => e.toJson()).toList(),
      'household_members': instance.householdMembers
          ?.map((e) => e.toJson())
          .toList(),
      'inviteCode': instance.inviteCode,
    };

HouseholdOwner _$HouseholdOwnerFromJson(Map<String, dynamic> json) =>
    HouseholdOwner(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$HouseholdOwnerToJson(HouseholdOwner instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };

HouseholdMember _$HouseholdMemberFromJson(Map<String, dynamic> json) =>
    HouseholdMember(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$HouseholdMemberToJson(HouseholdMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };

HouseholdMemberDetailed _$HouseholdMemberDetailedFromJson(
  Map<String, dynamic> json,
) => HouseholdMemberDetailed(
  id: json['id'] as String,
  householdId: json['household_id'] as String,
  userId: json['user_id'] as String,
  role: json['role'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  user: HouseholdUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$HouseholdMemberDetailedToJson(
  HouseholdMemberDetailed instance,
) => <String, dynamic>{
  'id': instance.id,
  'household_id': instance.householdId,
  'user_id': instance.userId,
  'role': instance.role,
  'created_at': instance.createdAt.toIso8601String(),
  'user': instance.user.toJson(),
};

HouseholdUser _$HouseholdUserFromJson(Map<String, dynamic> json) =>
    HouseholdUser(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$HouseholdUserToJson(HouseholdUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'email': instance.email,
    };
