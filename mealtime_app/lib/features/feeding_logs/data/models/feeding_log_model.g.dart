// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feeding_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedingLogModel _$FeedingLogModelFromJson(Map<String, dynamic> json) =>
    FeedingLogModel(
      id: json['id'] as String,
      catId: json['cat_id'] as String,
      householdId: json['household_id'] as String,
      mealType: json['meal_type'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      notes: json['notes'] as String?,
      fedBy: json['fed_by'] as String,
      fedAt: DateTime.parse(json['fed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$FeedingLogModelToJson(FeedingLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cat_id': instance.catId,
      'household_id': instance.householdId,
      'meal_type': instance.mealType,
      'amount': instance.amount,
      'unit': instance.unit,
      'notes': instance.notes,
      'fed_by': instance.fedBy,
      'fed_at': instance.fedAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
