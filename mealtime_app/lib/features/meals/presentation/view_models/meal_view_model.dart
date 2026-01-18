import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';

class MealViewModel extends Equatable {
  final String id;
  final String formattedTime;
  final String relativeDate;
  final double? amount;
  final Meal meal;

  const MealViewModel({
    required this.id,
    required this.formattedTime,
    required this.relativeDate,
    required this.amount,
    required this.meal,
  });

  @override
  List<Object?> get props => [
    id,
    formattedTime,
    relativeDate,
    amount,
    meal,
  ];
}
