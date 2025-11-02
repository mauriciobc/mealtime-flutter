// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightGoalModel _$WeightGoalModelFromJson(Map<String, dynamic> json) =>
    WeightGoalModel(
      id: json['id'] as String,
      catId: json['cat_id'] as String,
      targetWeight: (json['target_weight'] as num).toDouble(),
      targetDate: DateTime.parse(json['target_date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$WeightGoalModelToJson(WeightGoalModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cat_id': instance.catId,
      'target_weight': instance.targetWeight,
      'target_date': instance.targetDate.toIso8601String(),
      'notes': instance.notes,
    };
