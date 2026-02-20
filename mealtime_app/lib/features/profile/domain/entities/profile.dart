import 'package:equatable/equatable.dart';

const Object _absent = Object();

class Profile extends Equatable {
  final String id;
  final String? username;
  final String? fullName;
  final String? email;
  final String? website;
  final String? avatarUrl;
  final String? timezone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Profile({
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

  @override
  List<Object?> get props => [
        id,
        username,
        fullName,
        email,
        website,
        avatarUrl,
        timezone,
        createdAt,
        updatedAt,
      ];

  Profile copyWith({
    Object? username = _absent,
    Object? fullName = _absent,
    Object? email = _absent,
    Object? website = _absent,
    Object? avatarUrl = _absent,
    Object? timezone = _absent,
    Object? createdAt = _absent,
    Object? updatedAt = _absent,
  }) {
    return Profile(
      id: id,
      username: username == _absent ? this.username : username as String?,
      fullName: fullName == _absent ? this.fullName : fullName as String?,
      email: email == _absent ? this.email : email as String?,
      website: website == _absent ? this.website : website as String?,
      avatarUrl: avatarUrl == _absent ? this.avatarUrl : avatarUrl as String?,
      timezone: timezone == _absent ? this.timezone : timezone as String?,
      createdAt:
          createdAt == _absent ? this.createdAt : createdAt as DateTime?,
      updatedAt:
          updatedAt == _absent ? this.updatedAt : updatedAt as DateTime?,
    );
  }
}

