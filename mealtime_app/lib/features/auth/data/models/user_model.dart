import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/features/auth/domain/entities/user.dart';
import 'package:mealtime_app/features/auth/data/models/household_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  @JsonKey(name: 'auth_id')
  final String? authId; // Opcional: pode vir do Supabase ou do backend
  @JsonKey(name: 'full_name')
  final String? fullName; // Opcional: Supabase não retorna
  final String email;
  @JsonKey(name: 'household_id')
  final String? householdId;
  final HouseholdModel? household;
  @JsonKey(name: 'created_at', includeIfNull: false)
  final DateTime? createdAt; // Opcional: Supabase usa formato string
  @JsonKey(name: 'updated_at', includeIfNull: false)
  final DateTime? updatedAt; // Opcional: Supabase usa formato string
  @JsonKey(name: 'is_email_verified')
  final bool isEmailVerified;
  @JsonKey(name: 'current_home_id')
  final String? currentHomeId;

  const UserModel({
    required this.id,
    this.authId,
    this.fullName,
    required this.email,
    this.householdId,
    this.household,
    this.createdAt,
    this.updatedAt,
    this.isEmailVerified = false,
    this.currentHomeId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      authId: user.authId,
      fullName: user.fullName,
      email: user.email,
      householdId: user.householdId,
      household: user.household,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isEmailVerified: user.isEmailVerified,
      currentHomeId: user.currentHomeId,
    );
  }

  User toEntity() {
    return User(
      id: id,
      authId: authId ?? id, // Usar id como fallback
      fullName: fullName ?? email.split('@').first, // Usar email como fallback
      email: email,
      householdId: householdId,
      household: household,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isEmailVerified: isEmailVerified,
      currentHomeId: currentHomeId,
    );
  }
}
