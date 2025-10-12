import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/cats/domain/repositories/cats_repository.dart';

class DeleteCat implements UseCase<void, String> {
  final CatsRepository repository;

  DeleteCat(this.repository);

  @override
  Future<Either<Failure, void>> call(String catId) async {
    return await repository.deleteCat(catId);
  }
}
