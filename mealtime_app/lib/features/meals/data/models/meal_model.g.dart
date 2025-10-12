// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealModel _$MealModelFromJson(Map<String, dynamic> json) => MealModel(
      id: json['id'] as String,
      catId: json['cat_id'] as String,
      homeId: json['home_id'] as String,
      type: json['type'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      skippedAt: json['skipped_at'] == null
          ? null
          : DateTime.parse(json['skipped_at'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      foodType: json['food_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$MealModelToJson(MealModel instance) => <String, dynamic>{
      'id': instance.id,
      'cat_id': instance.catId,
      'home_id': instance.homeId,
      'type': instance.type,
      'scheduled_at': instance.scheduledAt.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'skipped_at': instance.skippedAt?.toIso8601String(),
      'status': instance.status,
      'notes': instance.notes,
      'amount': instance.amount,
      'food_type': instance.foodType,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
