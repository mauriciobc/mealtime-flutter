import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/domain/repositories/homes_repository.dart';

class GetActiveHome implements UseCase<Home?, NoParams> {
  final HomesRepository repository;

  GetActiveHome(this.repository);

  @override
  Future<Either<Failure, Home?>> call(NoParams params) async {
    try {
      final result = await repository.getActiveHome();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
