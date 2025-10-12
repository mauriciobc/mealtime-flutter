import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/meals/domain/repositories/meals_repository.dart';

class DeleteMeal implements UseCase<void, String> {
  final MealsRepository repository;

  DeleteMeal(this.repository);

  @override
  Future<Either<Failure, void>> call(String mealId) async {
    return await repository.deleteMeal(mealId);
  }
}
