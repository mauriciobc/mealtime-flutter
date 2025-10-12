import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/homes/domain/repositories/homes_repository.dart';

class DeleteHome implements UseCase<void, String> {
  final HomesRepository repository;

  DeleteHome(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    try {
      await repository.deleteHome(params);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
