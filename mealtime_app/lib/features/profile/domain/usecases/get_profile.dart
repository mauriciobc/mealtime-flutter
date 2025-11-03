import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';
import 'package:mealtime_app/features/profile/domain/repositories/profile_repository.dart';

class GetProfile implements UseCase<Profile, GetProfileParams> {
  final ProfileRepository repository;

  GetProfile(this.repository);

  @override
  Future<Either<Failure, Profile>> call(GetProfileParams params) async {
    return await repository.getProfile(params.idOrUsername);
  }
}

class GetProfileParams extends Equatable {
  final String idOrUsername;

  const GetProfileParams({required this.idOrUsername});

  @override
  List<Object> get props => [idOrUsername];
}

