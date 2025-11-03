import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';
import 'package:mealtime_app/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfile implements UseCase<Profile, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, Profile>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      params.idOrUsername,
      params.profile,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String idOrUsername;
  final Profile profile;

  const UpdateProfileParams({
    required this.idOrUsername,
    required this.profile,
  });

  @override
  List<Object> get props => [idOrUsername, profile];
}

