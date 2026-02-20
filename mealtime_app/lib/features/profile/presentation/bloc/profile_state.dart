import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {
  /// Temporary avatar URL from a recent upload, until reloaded profile has it.
  final String? tempAvatarUrl;

  const ProfileLoading({this.tempAvatarUrl});

  @override
  List<Object?> get props => [tempAvatarUrl];
}

class ProfileLoaded extends ProfileState {
  final Profile profile;
  /// Prefer this over profile.avatarUrl until the persisted profile has the avatar.
  final String? tempAvatarUrl;

  const ProfileLoaded(this.profile, {this.tempAvatarUrl});

  /// Use this in UI: tempAvatarUrl when present, otherwise profile.avatarUrl.
  String? get effectiveAvatarUrl => tempAvatarUrl ?? profile.avatarUrl;

  @override
  List<Object?> get props => [profile, tempAvatarUrl];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileOperationInProgress extends ProfileState {
  final Profile? lastProfile;
  /// Uploaded avatar URL when lastProfile is null (e.g. right after upload).
  final String? tempAvatarUrl;

  const ProfileOperationInProgress(this.lastProfile, {this.tempAvatarUrl});

  /// Use this in UI: tempAvatarUrl when present, otherwise lastProfile?.avatarUrl.
  String? get effectiveAvatarUrl => tempAvatarUrl ?? lastProfile?.avatarUrl;

  @override
  List<Object?> get props => [lastProfile, tempAvatarUrl];
}

class ProfileOperationSuccess extends ProfileState {
  final Profile profile;
  final String message;

  const ProfileOperationSuccess(this.profile, this.message);

  @override
  List<Object?> get props => [profile, message];
}
