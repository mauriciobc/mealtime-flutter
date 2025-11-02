import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String fullName,
  );
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> refreshToken();
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, void>> resetPassword(String token, String password);
}
