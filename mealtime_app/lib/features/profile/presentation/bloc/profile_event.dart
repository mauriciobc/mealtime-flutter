import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String idOrUsername;

  const LoadProfile(this.idOrUsername);

  @override
  List<Object?> get props => [idOrUsername];
}

class UpdateProfileEvent extends ProfileEvent {
  final Profile profile;

  const UpdateProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}

class UploadAvatarEvent extends ProfileEvent {
  final String idOrUsername;
  final String filePath;

  const UploadAvatarEvent({
    required this.idOrUsername,
    required this.filePath,
  });

  @override
  List<Object?> get props => [idOrUsername, filePath];
}
