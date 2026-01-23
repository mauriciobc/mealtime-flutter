import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:mealtime_app/features/meals/presentation/view_models/meal_view_model.dart';

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
  final List<MealViewModel> meals;

  const MealsLoaded({required this.meals});

  @override
  List<Object> get props => [meals];
}

class MealLoaded extends MealsState {
  final Meal meal;

  const MealLoaded({required this.meal});

  @override
  List<Object> get props => [meal];
}

class MealOperationInProgress extends MealsState {
  final String operation;
  final List<MealViewModel> meals;

  const MealOperationInProgress({required this.operation, required this.meals});

  @override
  List<Object> get props => [operation, meals];
}

class MealOperationSuccess extends MealsState {
  final String message;
  final List<MealViewModel> meals;
  final Meal? updatedMeal;

  const MealOperationSuccess({
    required this.message,
    required this.meals,
    this.updatedMeal,
  });

  @override
  List<Object?> get props => [message, meals, updatedMeal];
}

class MealsError extends MealsState {
  final Failure failure;

  const MealsError(this.failure);

  @override
  List<Object> get props => [failure];
}
