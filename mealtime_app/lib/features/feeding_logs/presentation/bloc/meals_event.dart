import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';

abstract class MealsEvent extends Equatable {
  const MealsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMeals extends MealsEvent {
  const LoadMeals();
}

class LoadMealsByCat extends MealsEvent {
  final String catId;

  const LoadMealsByCat(this.catId);

  @override
  List<Object> get props => [catId];
}

class LoadMealById extends MealsEvent {
  final String mealId;

  const LoadMealById(this.mealId);

  @override
  List<Object> get props => [mealId];
}

class LoadTodayMeals extends MealsEvent {
  const LoadTodayMeals();
}

class CreateMeal extends MealsEvent {
  final Meal meal;

  const CreateMeal(this.meal);

  @override
  List<Object> get props => [meal];
}

class UpdateMeal extends MealsEvent {
  final Meal meal;

  const UpdateMeal(this.meal);

  @override
  List<Object> get props => [meal];
}

class DeleteMeal extends MealsEvent {
  final String mealId;

  const DeleteMeal(this.mealId);

  @override
  List<Object> get props => [mealId];
}

class CompleteMeal extends MealsEvent {
  final String mealId;
  final String? notes;
  final double? amount;

  const CompleteMeal({required this.mealId, this.notes, this.amount});

  @override
  List<Object?> get props => [mealId, notes, amount];
}

class SkipMeal extends MealsEvent {
  final String mealId;
  final String? reason;

  const SkipMeal({required this.mealId, this.reason});

  @override
  List<Object?> get props => [mealId, reason];
}

class RefreshMeals extends MealsEvent {
  const RefreshMeals();
}

class ClearMealsError extends MealsEvent {
  const ClearMealsError();
}
