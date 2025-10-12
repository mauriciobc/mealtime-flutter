import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:mealtime_app/features/meals/domain/repositories/meals_repository.dart';

class CreateMeal implements UseCase<Meal, Meal> {
  final MealsRepository repository;

  CreateMeal(this.repository);

  @override
  Future<Either<Failure, Meal>> call(Meal meal) async {
    return await repository.createMeal(meal);
  }
}
