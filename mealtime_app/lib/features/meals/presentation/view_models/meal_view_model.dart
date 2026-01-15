import 'package:mealtime_app/features/meals/domain/entities/meal.dart';

class MealViewModel {
  final Meal meal;
  final String formattedDateTime;

  MealViewModel({
    required this.meal,
    required this.formattedDateTime,
  });
}
