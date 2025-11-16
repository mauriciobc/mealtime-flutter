// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatBasicModel _$CatBasicModelFromJson(Map<String, dynamic> json) =>
    CatBasicModel(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$CatBasicModelToJson(CatBasicModel instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

ScheduleModel _$ScheduleModelFromJson(Map<String, dynamic> json) =>
    ScheduleModel(
      id: json['id'] as String,
      catId: json['cat_id'] as String,
      type: json['type'] as String,
      interval: (json['interval'] as num?)?.toInt(),
      times: (json['times'] as List<dynamic>).map((e) => e as String).toList(),
      enabled: json['enabled'] as bool,
      cat: json['cat'] == null
          ? null
          : CatBasicModel.fromJson(json['cat'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ScheduleModelToJson(ScheduleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cat_id': instance.catId,
      'type': instance.type,
      'interval': instance.interval,
      'times': instance.times,
      'enabled': instance.enabled,
      'cat': instance.cat,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
