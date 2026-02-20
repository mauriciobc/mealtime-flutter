import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Profile profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileOperationInProgress extends ProfileState {
  final Profile? lastProfile;

  const ProfileOperationInProgress(this.lastProfile);

  @override
  List<Object?> get props => [lastProfile];
}

class ProfileOperationSuccess extends ProfileState {
  final Profile profile;
  final String message;

  const ProfileOperationSuccess(this.profile, this.message);

  @override
  List<Object?> get props => [profile, message];
}
