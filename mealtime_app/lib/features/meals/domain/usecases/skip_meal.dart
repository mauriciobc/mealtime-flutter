import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:mealtime_app/features/meals/domain/repositories/meals_repository.dart';

class SkipMealParams {
  final String mealId;
  final String? reason;

  SkipMealParams({required this.mealId, this.reason});
}

class SkipMeal implements UseCase<Meal, SkipMealParams> {
  final MealsRepository repository;

  SkipMeal(this.repository);

  @override
  Future<Either<Failure, Meal>> call(SkipMealParams params) async {
    return await repository.skipMeal(params.mealId, params.reason);
  }
}
