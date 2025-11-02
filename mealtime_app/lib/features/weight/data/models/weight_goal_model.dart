import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/features/weight/domain/entities/weight_goal.dart';

part 'weight_goal_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class WeightGoalModel {
  final String id;
  @JsonKey(name: 'cat_id')
  final String catId;
  @JsonKey(name: 'target_weight')
  final double targetWeight;
  @JsonKey(name: 'target_date')
  final DateTime targetDate;
  final String? notes;
  @JsonKey(name: 'created_at', includeFromJson: true, includeToJson: false)
  final DateTime createdAt;

  const WeightGoalModel({
    required this.id,
    required this.catId,
    required this.targetWeight,
    required this.targetDate,
    this.notes,
    required this.createdAt,
  });

  factory WeightGoalModel.fromJson(Map<String, dynamic> json) =>
      _$WeightGoalModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeightGoalModelToJson(this);

  factory WeightGoalModel.fromEntity(WeightGoal goal) {
    return WeightGoalModel(
      id: goal.id,
      catId: goal.catId,
      targetWeight: goal.targetWeight,
      targetDate: goal.targetDate,
      notes: goal.notes,
      createdAt: goal.createdAt,
    );
  }

  /// Converte para entidade, mas precisa do startWeight e startDate
  /// que podem vir do primeiro registro de peso ou do gato
  WeightGoal toEntity({
    required double startWeight,
    required DateTime startDate,
    DateTime? endDate,
    DateTime? updatedAt,
  }) {
    return WeightGoal(
      id: id,
      catId: catId,
      targetWeight: targetWeight,
      startWeight: startWeight,
      startDate: startDate,
      targetDate: targetDate,
      endDate: endDate,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? createdAt,
    );
  }
}

