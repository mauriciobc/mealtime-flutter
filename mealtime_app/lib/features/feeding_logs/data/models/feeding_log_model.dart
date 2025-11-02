import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';

part 'feeding_log_model.g.dart';

/// Conversor customizado para lidar com conversão de String para double
/// Aceita String, int, double ou null e converte adequadamente
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

/// Função helper para converter dynamic para double?
double? _doubleFromJson(dynamic json) {
  if (json == null) return null;
  if (json is double) return json;
  if (json is int) return json.toDouble();
  if (json is String) {
    return double.tryParse(json);
  }
  return null;
}

/// Função helper para converter double? para dynamic
dynamic _doubleToJson(double? object) => object;

/// Model de FeedingLog mapeado da tabela feeding_logs do Supabase
/// Usa snake_case para compatibilidade com o banco de dados
@JsonSerializable(fieldRename: FieldRename.snake)
class FeedingLogModel {
  final String id;
  final String catId;
  final String householdId;
  final String mealType;  // 'breakfast', 'lunch', 'dinner', 'snack'
  @JsonKey(name: 'food_type')
  final String? foodType;  // 'Ração Seca', 'Ração Úmida', 'Sachê', 'Petisco'
  @JsonKey(fromJson: _doubleFromJson, toJson: _doubleToJson)
  final double? amount;
  final String? unit;
  final String? notes;
  final String fedBy;
  final DateTime fedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FeedingLogModel({
    required this.id,
    required this.catId,
    required this.householdId,
    required this.mealType,
    this.foodType,
    this.amount,
    this.unit,
    this.notes,
    required this.fedBy,
    required this.fedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedingLogModel.fromJson(Map<String, dynamic> json) =>
      _$FeedingLogModelFromJson(json);
      
  Map<String, dynamic> toJson() => _$FeedingLogModelToJson(this);

  /// Cria um model a partir de uma entidade
  factory FeedingLogModel.fromEntity(FeedingLog feedingLog) {
    return FeedingLogModel(
      id: feedingLog.id,
      catId: feedingLog.catId,
      householdId: feedingLog.householdId,
      mealType: feedingLog.mealType.name,
      foodType: feedingLog.foodType,
      amount: feedingLog.amount,
      unit: feedingLog.unit,
      notes: feedingLog.notes,
      fedBy: feedingLog.fedBy,
      fedAt: feedingLog.fedAt,
      createdAt: feedingLog.createdAt,
      updatedAt: feedingLog.updatedAt,
    );
  }

  /// Converte o model para entidade de domínio
  FeedingLog toEntity() {
    return FeedingLog(
      id: id,
      catId: catId,
      householdId: householdId,
      mealType: MealType.values.firstWhere(
        (e) => e.name == mealType,
        orElse: () => MealType.snack,
      ),
      foodType: foodType,
      amount: amount,
      unit: unit,
      notes: notes,
      fedBy: fedBy,
      fedAt: fedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
