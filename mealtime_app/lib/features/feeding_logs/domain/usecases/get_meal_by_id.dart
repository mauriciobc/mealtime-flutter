import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:mealtime_app/features/meals/domain/repositories/meals_repository.dart';

class GetMealById implements UseCase<Meal, String> {
  final MealsRepository repository;

  GetMealById(this.repository);

  @override
  Future<Either<Failure, Meal>> call(String mealId) async {
    return await repository.getMealById(mealId);
  }
}
