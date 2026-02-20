import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';

part 'profile_model.g.dart';

/// Conversor customizado para lidar com conversão segura de String para DateTime
/// Retorna null ao invés de lançar FormatException em strings malformadas
class SafeDateTimeConverter implements JsonConverter<DateTime?, String?> {
  const SafeDateTimeConverter();

  @override
  DateTime? fromJson(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      return DateTime.parse(json);
    } catch (e) {
      // Retorna null ao invés de lançar exceção para dados malformados
      // Isso previne crashes em produção quando o backend retorna datas inválidas
      return null;
    }
  }

  @override
  String? toJson(DateTime? object) => object?.toIso8601String();
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ProfileModel {
  final String id;
  final String? username;
  final String? fullName;
  final String? email;
  final String? website;
  final String? avatarUrl;
  final String? timezone;
  @SafeDateTimeConverter()
  final DateTime? createdAt;
  @SafeDateTimeConverter()
  final DateTime? updatedAt;

  const ProfileModel({
    required this.id,
    this.username,
    this.fullName,
    this.email,
    this.website,
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
      website: website,
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
      website: profile.website,
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
  final String? website;
  final String? avatarUrl;
  final String? timezone;

  const ProfileInputModel({
    this.username,
    this.fullName,
    this.website,
    this.avatarUrl,
    this.timezone,
  });

  factory ProfileInputModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileInputModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileInputModelToJson(this);
}

