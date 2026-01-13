import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';

class MealViewModel extends Equatable {
  final Meal meal;
  final String scheduledAtFormatted;

  const MealViewModel({
    required this.meal,
    required this.scheduledAtFormatted,
  });

  @override
  List<Object?> get props => [meal, scheduledAtFormatted];
}
