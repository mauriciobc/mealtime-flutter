import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';

abstract class ProfileRepository {
  /// Busca o perfil do usuário atual
  Future<Either<Failure, Profile>> getProfile(String idOrUsername);

  /// Atualiza o perfil do usuário
  Future<Either<Failure, Profile>> updateProfile(
    String idOrUsername,
    Profile profile,
  );

  /// Faz upload de avatar
  Future<Either<Failure, String>> uploadAvatar(String filePath);
}

