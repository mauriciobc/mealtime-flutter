import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/domain/repositories/homes_repository.dart';

class UpdateHome implements UseCase<Home, UpdateHomeParams> {
  final HomesRepository repository;

  UpdateHome(this.repository);

  @override
  Future<Either<Failure, Home>> call(UpdateHomeParams params) async {
    try {
      final home = await repository.updateHome(
        id: params.id,
        name: params.name,
        description: params.description,
      );
      return Right(home);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class UpdateHomeParams {
  final String id;
  final String name;
  final String? description;

  UpdateHomeParams({required this.id, required this.name, this.description});
}
