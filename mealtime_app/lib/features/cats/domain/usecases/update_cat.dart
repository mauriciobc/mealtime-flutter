import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/domain/repositories/cats_repository.dart';

class UpdateCat implements UseCase<Cat, Cat> {
  final CatsRepository repository;

  UpdateCat(this.repository);

  @override
  Future<Either<Failure, Cat>> call(Cat cat) async {
    return await repository.updateCat(cat);
  }
}
