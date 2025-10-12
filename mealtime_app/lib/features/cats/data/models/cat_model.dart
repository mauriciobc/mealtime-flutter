import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';

part 'cat_model.g.dart';

@JsonSerializable()
class CatModel {
  final int id; // ✅ API usa int para ID do gato
  final String name;
  @JsonKey(name: 'birth_date')
  final String? birthDate; // ✅ API usa String para data
  final double? weight; // ✅ Adicionar campo weight
  @JsonKey(name: 'photo_url')
  final String? photoUrl; // ✅ Adicionar campo photo_url
  @JsonKey(name: 'household_id')
  final int householdId; // ✅ API usa int para household_id
  @JsonKey(name: 'created_at')
  final String createdAt; // ✅ API usa String para datas
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  const CatModel({
    required this.id,
    required this.name,
    this.birthDate,
    this.weight,
    this.photoUrl,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CatModel.fromJson(Map<String, dynamic> json) =>
      _$CatModelFromJson(json);
  Map<String, dynamic> toJson() => _$CatModelToJson(this);

  factory CatModel.fromEntity(Cat cat) {
    return CatModel(
      id: int.parse(cat.id),
      name: cat.name,
      birthDate: cat.birthDate.toIso8601String(),
      weight: cat.currentWeight,
      photoUrl: cat.imageUrl,
      householdId: int.parse(cat.homeId),
      createdAt: cat.createdAt.toIso8601String(),
      updatedAt: cat.updatedAt.toIso8601String(),
    );
  }

  Cat toEntity() {
    return Cat(
      id: id.toString(),
      name: name,
      breed: null,
      birthDate: birthDate != null
          ? DateTime.parse(birthDate!)
          : DateTime.now(),
      gender: null,
      color: null,
      description: null,
      imageUrl: photoUrl,
      currentWeight: weight,
      targetWeight: null,
      homeId: householdId.toString(),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isActive: true,
    );
  }
}
