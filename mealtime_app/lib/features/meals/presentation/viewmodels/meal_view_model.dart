import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';

class MealViewModel extends Equatable {
  final Meal meal;
  final String formattedScheduledAt;

  const MealViewModel({
    required this.meal,
    required this.formattedScheduledAt,
  });

  @override
  List<Object?> get props => [meal, formattedScheduledAt];
}
