import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/profile/domain/repositories/profile_repository.dart';

class UploadAvatar implements UseCase<String, UploadAvatarParams> {
  final ProfileRepository repository;

  UploadAvatar(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadAvatarParams params) async {
    return await repository.uploadAvatar(params.filePath);
  }
}

class UploadAvatarParams extends Equatable {
  final String filePath;

  const UploadAvatarParams({required this.filePath});

  @override
  List<Object> get props => [filePath];
}

