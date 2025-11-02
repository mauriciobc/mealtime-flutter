import 'package:equatable/equatable.dart';

/// Tipos de refeição conforme o banco de dados
enum MealType { breakfast, lunch, dinner, snack }

/// Entidade FeedingLog representa um registro de alimentação
/// Baseado na tabela feeding_logs do Supabase
class FeedingLog extends Equatable {
  final String id;
  final String catId;
  final String householdId;  // ✅ Alterado de homeId para householdId
  final MealType mealType;  // ✅ Renomeado de type para mealType
  final String? foodType;  // 'Ração Seca', 'Ração Úmida', 'Sachê', 'Petisco'
  final double? amount;
  final String? unit;
  final String? notes;
  final String fedBy;  // ✅ NOVO: userId de quem alimentou
  final DateTime fedAt;  // ✅ NOVO: quando foi alimentado
  final DateTime createdAt;
  final DateTime updatedAt;

  const FeedingLog({
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

  @override
  List<Object?> get props => [
        id,
        catId,
        householdId,
        mealType,
        foodType,
        amount,
        unit,
        notes,
        fedBy,
        fedAt,
        createdAt,
        updatedAt,
      ];

  FeedingLog copyWith({
    String? id,
    String? catId,
    String? householdId,
    MealType? mealType,
    String? foodType,
    double? amount,
    String? unit,
    String? notes,
    String? fedBy,
    DateTime? fedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeedingLog(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      householdId: householdId ?? this.householdId,
      mealType: mealType ?? this.mealType,
      foodType: foodType ?? this.foodType,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      fedBy: fedBy ?? this.fedBy,
      fedAt: fedAt ?? this.fedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica se a alimentação foi hoje
  bool get isToday {
    final now = DateTime.now();
    return fedAt.year == now.year &&
        fedAt.month == now.month &&
        fedAt.day == now.day;
  }

  /// Nome de exibição do tipo de refeição
  String get mealTypeDisplayName {
    switch (mealType) {
      case MealType.breakfast:
        return 'Café da manhã';
      case MealType.lunch:
        return 'Almoço';
      case MealType.dinner:
        return 'Jantar';
      case MealType.snack:
        return 'Lanche';
    }
  }

  /// Formata a quantidade com unidade
  String get amountFormatted {
    if (amount == null) return 'Quantidade não especificada';
    final unitStr = unit ?? 'g';
    return '${amount!.toStringAsFixed(1)} $unitStr';
  }

  @override
  String toString() {
    return 'FeedingLog{'
        'id: $id, '
        'catId: $catId, '
        'householdId: $householdId, '
        'mealType: ${mealType.name}, '
        'amount: $amount, '
        'unit: $unit, '
        'fedBy: $fedBy, '
        'fedAt: $fedAt, '
        'notes: $notes'
        '}';
  }
}
