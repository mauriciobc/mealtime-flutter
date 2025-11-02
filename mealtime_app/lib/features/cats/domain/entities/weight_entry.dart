import 'package:equatable/equatable.dart';

class WeightEntry extends Equatable {
  final String id;
  final String catId;
  final double weight; // em kg
  final DateTime measuredAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WeightEntry({
    required this.id,
    required this.catId,
    required this.weight,
    required this.measuredAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    catId,
    weight,
    measuredAt,
    notes,
    createdAt,
    updatedAt,
  ];

  WeightEntry copyWith({
    String? id,
    String? catId,
    double? weight,
    DateTime? measuredAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      weight: weight ?? this.weight,
      measuredAt: measuredAt ?? this.measuredAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get weightInGrams => '${(weight * 1000).round()}g';
  String get weightInKg => '${weight.toStringAsFixed(2)}kg';
}
