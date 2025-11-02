import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}
