import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String authId;
  final String fullName;
  final String email;
  final String? householdId;
  final dynamic household; // HouseholdModel será importado quando necessário
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final String? currentHomeId;

  const User({
    required this.id,
    required this.authId,
    required this.fullName,
    required this.email,
    this.householdId,
    this.household,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
    this.currentHomeId,
  });

  @override
  List<Object?> get props => [
    id,
    authId,
    fullName,
    email,
    householdId,
    household,
    createdAt,
    updatedAt,
    isEmailVerified,
    currentHomeId,
  ];

  User copyWith({
    String? id,
    String? authId,
    String? fullName,
    String? email,
    String? householdId,
    dynamic household,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    String? currentHomeId,
  }) {
    return User(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      householdId: householdId ?? this.householdId,
      household: household ?? this.household,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      currentHomeId: currentHomeId ?? this.currentHomeId,
    );
  }
}
