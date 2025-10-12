// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatModel _$CatModelFromJson(Map<String, dynamic> json) => CatModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      birthDate: json['birth_date'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      photoUrl: json['photo_url'] as String?,
      householdId: (json['household_id'] as num).toInt(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$CatModelToJson(CatModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'birth_date': instance.birthDate,
      'weight': instance.weight,
      'photo_url': instance.photoUrl,
      'household_id': instance.householdId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
