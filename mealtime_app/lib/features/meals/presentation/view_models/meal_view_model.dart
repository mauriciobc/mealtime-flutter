import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';

class MealViewModel extends Equatable {
  final Meal meal;
  final String formattedDateTime;

  const MealViewModel({
    required this.meal,
    required this.formattedDateTime,
  });

  @override
  List<Object?> get props => [meal, formattedDateTime];
}
