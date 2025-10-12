import 'package:dartz/dartz.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';

abstract class MealsRepository {
  Future<Either<Failure, List<Meal>>> getMeals();
  Future<Either<Failure, List<Meal>>> getMealsByCat(String catId);
  Future<Either<Failure, Meal>> getMealById(String mealId);
  Future<Either<Failure, List<Meal>>> getTodayMeals();
  Future<Either<Failure, Meal>> createMeal(Meal meal);
  Future<Either<Failure, Meal>> updateMeal(Meal meal);
  Future<Either<Failure, void>> deleteMeal(String mealId);
  Future<Either<Failure, Meal>> completeMeal(
    String mealId,
    String? notes,
    double? amount,
  );
  Future<Either<Failure, Meal>> skipMeal(String mealId, String? reason);
}
