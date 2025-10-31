import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';

part 'cat_model.g.dart';

// Custom converter to handle String to double conversion
class DoubleConverter implements JsonConverter<double?, dynamic> {
  const DoubleConverter();

  @override
  double? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is double) return json;
    if (json is int) return json.toDouble();
    if (json is String) {
      return double.tryParse(json);
    }
    return null;
  }

  @override
  dynamic toJson(double? object) => object;
}

// Custom converter to handle String to int conversion
class IntConverter implements JsonConverter<int?, dynamic> {
  const IntConverter();

  @override
  int? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is int) return json;
    if (json is double) return json.toInt();
    if (json is String) {
      return int.tryParse(json);
    }
    return null;
  }

  @override
  dynamic toJson(int? object) => object;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CatModel {
  final String id;  // UUID no banco (String)
  final String name;
  final String? birthDate;  // Data de nascimento
  @DoubleConverter()
  final double? weight;  // Peso atual
  final String? photoUrl;  // URL da foto
  final String householdId;  // ID da casa
  final String ownerId;  // ✅ NOVO: ID do dono principal
  @DoubleConverter()
  final double? portionSize;  // ✅ NOVO: Tamanho da porção
  final String? portionUnit;  // ✅ NOVO: Unidade da porção
  @IntConverter()
  final int? feedingInterval;  // ✅ NOVO: Intervalo entre alimentações (horas)
  final String? notes;  // ✅ NOVO: Notas sobre o gato
  final String? restrictions;  // ✅ NOVO: Restrições alimentares
  final DateTime createdAt;
  final DateTime updatedAt;

  const CatModel({
    required this.id,
    required this.name,
    this.birthDate,
    this.weight,
    this.photoUrl,
    required this.householdId,
    required this.ownerId,
    this.portionSize,
    this.portionUnit,
    this.feedingInterval,
    this.notes,
    this.restrictions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CatModel.fromJson(Map<String, dynamic> json) =>
      _$CatModelFromJson(json);
  Map<String, dynamic> toJson() => _$CatModelToJson(this);

  factory CatModel.fromEntity(Cat cat) {
    return CatModel(
      id: cat.id,
      name: cat.name,
      birthDate: cat.birthDate.toIso8601String(),
      weight: cat.currentWeight,
      photoUrl: cat.imageUrl,
      householdId: cat.homeId,
      ownerId: cat.ownerId ?? '',  // ✅ NOVO
      portionSize: cat.portionSize,  // ✅ NOVO
      portionUnit: cat.portionUnit,  // ✅ NOVO
      feedingInterval: cat.feedingInterval,  // ✅ NOVO
      notes: cat.description,  // Mapear description para notes
      restrictions: cat.restrictions,  // ✅ NOVO
      createdAt: cat.createdAt,
      updatedAt: cat.updatedAt,
    );
  }

  Cat toEntity() {
    return Cat(
      id: id,
      name: name,
      breed: null,  // Não está na API atual
      birthDate: birthDate != null
          ? DateTime.parse(birthDate!)
          : DateTime.now(),
      gender: null,  // Não está na API atual
      color: null,  // Não está na API atual
      description: notes,
      imageUrl: photoUrl,
      currentWeight: weight,
      targetWeight: null,  // Não está na API atual
      homeId: householdId,
      ownerId: ownerId,  // ✅ NOVO
      portionSize: portionSize,  // ✅ NOVO
      portionUnit: portionUnit,  // ✅ NOVO
      feedingInterval: feedingInterval,  // ✅ NOVO
      restrictions: restrictions,  // ✅ NOVO
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: true,
    );
  }
}
