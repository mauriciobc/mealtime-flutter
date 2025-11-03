import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String? username;
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final String? timezone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Profile({
    required this.id,
    this.username,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.timezone,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        fullName,
        email,
        avatarUrl,
        timezone,
        createdAt,
        updatedAt,
      ];

  Profile copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

