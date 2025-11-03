import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';

part 'profile_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProfileModel {
  final String id;
  final String? username;
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final String? timezone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileModel({
    required this.id,
    this.username,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.timezone,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  Profile toEntity() {
    return Profile(
      id: id,
      username: username,
      fullName: fullName,
      email: email,
      avatarUrl: avatarUrl,
      timezone: timezone,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      username: profile.username,
      fullName: profile.fullName,
      email: profile.email,
      avatarUrl: profile.avatarUrl,
      timezone: profile.timezone,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ProfileInputModel {
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? timezone;

  const ProfileInputModel({
    this.username,
    this.fullName,
    this.avatarUrl,
    this.timezone,
  });

  factory ProfileInputModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileInputModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileInputModelToJson(this);
}

