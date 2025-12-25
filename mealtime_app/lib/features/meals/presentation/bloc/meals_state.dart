import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';

abstract class MealsState extends Equatable {
  const MealsState();

  @override
  List<Object?> get props => [];
}

class MealsInitial extends MealsState {
  const MealsInitial();
}

class MealsLoading extends MealsState {
  const MealsLoading();
}

class MealsLoaded extends MealsState {
  final List<Meal> meals;
  final Meal? lastMeal;

  const MealsLoaded({required this.meals, this.lastMeal});

  @override
  List<Object?> get props => [meals, lastMeal];
}

class MealLoaded extends MealsState {
  final Meal meal;

  const MealLoaded({required this.meal});

  @override
  List<Object> get props => [meal];
}

class MealOperationInProgress extends MealsState {
  final String operation;
  final List<Meal> meals;

  const MealOperationInProgress({required this.operation, required this.meals});

  @override
  List<Object> get props => [operation, meals];
}

class MealOperationSuccess extends MealsState {
  final String message;
  final List<Meal> meals;
  final Meal? updatedMeal;
  final Meal? lastMeal;

  const MealOperationSuccess({
    required this.message,
    required this.meals,
    this.updatedMeal,
    this.lastMeal,
  });

  @override
  List<Object?> get props => [message, meals, updatedMeal, lastMeal];
}

class MealsError extends MealsState {
  final Failure failure;

  const MealsError(this.failure);

  @override
  List<Object> get props => [failure];
}
