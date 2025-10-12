import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/domain/repositories/cats_repository.dart';

class GetCatById implements UseCase<Cat, String> {
  final CatsRepository repository;

  GetCatById(this.repository);

  @override
  Future<Either<Failure, Cat>> call(String catId) async {
    return await repository.getCatById(catId);
  }
}
