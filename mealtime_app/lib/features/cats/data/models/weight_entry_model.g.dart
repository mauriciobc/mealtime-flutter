// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightEntryModel _$WeightEntryModelFromJson(Map<String, dynamic> json) =>
    WeightEntryModel(
      id: json['id'] as String,
      catId: json['cat_id'] as String,
      weight: WeightEntryModel._weightFromJson(json['weight']),
      measuredAt: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$WeightEntryModelToJson(WeightEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cat_id': instance.catId,
      'weight': instance.weight,
      'date': instance.measuredAt.toIso8601String(),
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'measured_by': instance.measuredBy,
    };
