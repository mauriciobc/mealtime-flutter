import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/domain/repositories/homes_repository.dart';

class CreateHome implements UseCase<Home, CreateHomeParams> {
  final HomesRepository repository;

  CreateHome(this.repository);

  @override
  Future<Either<Failure, Home>> call(CreateHomeParams params) async {
    try {
      final home = await repository.createHome(
        name: params.name,
        description: params.description,
      );
      return Right(home);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class CreateHomeParams {
  final String name;
  final String? description;

  CreateHomeParams({required this.name, this.description});
}
