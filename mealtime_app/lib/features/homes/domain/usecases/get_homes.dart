import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/domain/repositories/homes_repository.dart';

class GetHomes implements UseCase<List<Home>, NoParams> {
  final HomesRepository repository;

  GetHomes(this.repository);

  @override
  Future<Either<Failure, List<Home>>> call(NoParams params) async {
    try {
      final homes = await repository.getHomes();
      return Right(homes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
