import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String id;
  final String? username;
  final String? website;
  final String? avatarUrl;
  final String? fullName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    this.username,
    this.website,
    this.avatarUrl,
    this.fullName,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? id,
    String? username,
    String? website,
    String? avatarUrl,
    String? fullName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      website: website ?? this.website,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fullName: fullName ?? this.fullName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, username: $username, website: $website, avatarUrl: $avatarUrl, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.id == id &&
        other.username == username &&
        other.website == website &&
        other.avatarUrl == avatarUrl &&
        other.fullName == fullName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        website.hashCode ^
        avatarUrl.hashCode ^
        fullName.hashCode;
  }
}
