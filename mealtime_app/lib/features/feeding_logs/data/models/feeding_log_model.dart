import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';

part 'feeding_log_model.g.dart';

/// Model de FeedingLog mapeado da tabela feeding_logs do Supabase
/// Usa snake_case para compatibilidade com o banco de dados
@JsonSerializable(fieldRename: FieldRename.snake)
class FeedingLogModel {
  final String id;
  final String catId;
  final String householdId;
  final String mealType;  // 'breakfast', 'lunch', 'dinner', 'snack'
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
