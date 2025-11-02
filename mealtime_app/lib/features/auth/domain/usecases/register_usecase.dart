import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/auth/domain/entities/user.dart';
import 'package:mealtime_app/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
      params.email,
      params.password,
      params.fullName,
    );
  }
}

class RegisterParams {
  final String email;
  final String password;
  final String fullName;
  final String? householdName;

  RegisterParams({
    required this.email,
    required this.password,
    required this.fullName,
    this.householdName,
  });
}
