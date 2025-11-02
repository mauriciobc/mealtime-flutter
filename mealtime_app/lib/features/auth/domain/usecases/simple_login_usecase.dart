import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/auth/domain/entities/user.dart';
import 'package:mealtime_app/features/auth/data/repositories/simple_auth_repository.dart';
import 'package:mealtime_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:mealtime_app/features/auth/domain/usecases/register_usecase.dart';

class SimpleLoginUseCase implements UseCase<User, LoginParams> {
  final SimpleAuthRepository repository;

  SimpleLoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}

class SimpleRegisterUseCase implements UseCase<User, RegisterParams> {
  final SimpleAuthRepository repository;

  SimpleRegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(params.email, params.password, params.fullName);
  }
}

class SimpleGetCurrentUserUseCase implements UseCase<User, NoParams> {
  final SimpleAuthRepository repository;

  SimpleGetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}

class SimpleLogoutUseCase implements UseCase<void, NoParams> {
  final SimpleAuthRepository repository;

  SimpleLogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}
