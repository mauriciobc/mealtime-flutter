import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:mealtime_app/features/meals/presentation/widgets/date_formatter.dart';

class MealViewModel {
  final Meal meal;
  final String formattedScheduledAt;

  MealViewModel({required this.meal})
      : formattedScheduledAt = formatDateTime(meal.scheduledAt);

  // Delegate properties from Meal to MealViewModel for easy access in the UI
  String get id => meal.id;
  MealType get type => meal.type;
  String get typeDisplayName => meal.typeDisplayName;
  DateTime get scheduledAt => meal.scheduledAt;
  MealStatus get status => meal.status;
  bool get isOverdue => meal.isOverdue;
  String? get notes => meal.notes;
  double? get amount => meal.amount;
  String? get foodType => meal.foodType;
  String? get catId => meal.catId;
}
