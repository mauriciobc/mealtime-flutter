// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatModel _$CatModelFromJson(Map<String, dynamic> json) => CatModel(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: json['birth_date'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      photoUrl: json['photo_url'] as String?,
      householdId: json['household_id'] as String,
      ownerId: json['owner_id'] as String,
      portionSize: (json['portion_size'] as num?)?.toDouble(),
      portionUnit: json['portion_unit'] as String?,
      feedingInterval: (json['feeding_interval'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      restrictions: json['restrictions'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CatModelToJson(CatModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'birth_date': instance.birthDate,
      'weight': instance.weight,
      'photo_url': instance.photoUrl,
      'household_id': instance.householdId,
      'owner_id': instance.ownerId,
      'portion_size': instance.portionSize,
      'portion_unit': instance.portionUnit,
      'feeding_interval': instance.feedingInterval,
      'notes': instance.notes,
      'restrictions': instance.restrictions,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
