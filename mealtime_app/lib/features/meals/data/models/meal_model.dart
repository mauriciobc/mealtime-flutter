import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';

part 'meal_model.g.dart';

@JsonSerializable()
class MealModel {
  final String id;
  @JsonKey(name: 'cat_id')
  final String catId;
  @JsonKey(name: 'home_id')
  final String homeId;
  final String type;
  @JsonKey(name: 'scheduled_at')
  final DateTime scheduledAt;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'skipped_at')
  final DateTime? skippedAt;
  final String status;
  final String? notes;
  final double? amount;
  @JsonKey(name: 'food_type')
  final String? foodType;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const MealModel({
    required this.id,
    required this.catId,
    required this.homeId,
    required this.type,
    required this.scheduledAt,
    this.completedAt,
    this.skippedAt,
    required this.status,
    this.notes,
    this.amount,
    this.foodType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) =>
      _$MealModelFromJson(json);
  Map<String, dynamic> toJson() => _$MealModelToJson(this);

  factory MealModel.fromEntity(Meal meal) {
    return MealModel(
      id: meal.id,
      catId: meal.catId,
      homeId: meal.homeId,
      type: meal.type.name,
      scheduledAt: meal.scheduledAt,
      completedAt: meal.completedAt,
      skippedAt: meal.skippedAt,
      status: meal.status.name,
      notes: meal.notes,
      amount: meal.amount,
      foodType: meal.foodType,
      createdAt: meal.createdAt,
      updatedAt: meal.updatedAt,
    );
  }

  Meal toEntity() {
    return Meal(
      id: id,
      catId: catId,
      homeId: homeId,
      type: MealType.values.firstWhere((e) => e.name == type),
      scheduledAt: scheduledAt,
      completedAt: completedAt,
      skippedAt: skippedAt,
      status: MealStatus.values.firstWhere((e) => e.name == status),
      notes: notes,
      amount: amount,
      foodType: foodType,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
