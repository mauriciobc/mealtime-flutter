import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart';

part 'weight_entry_model.g.dart';

@JsonSerializable()
class WeightEntryModel {
  final String id;
  @JsonKey(name: 'cat_id')
  final String catId;
  @JsonKey(fromJson: _weightFromJson)
  final double weight;
  @JsonKey(name: 'date') // Backend usa 'date' não 'measured_at'
  final DateTime measuredAt;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'measured_by', includeFromJson: false, includeToJson: true)
  final String? measuredBy;

  const WeightEntryModel({
    required this.id,
    required this.catId,
    required this.weight,
    required this.measuredAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.measuredBy,
  });

  factory WeightEntryModel.fromJson(Map<String, dynamic> json) =>
      _$WeightEntryModelFromJson(json);
  Map<String, dynamic> toJson() => _$WeightEntryModelToJson(this);

  /// Helper para converter weight de String para double
  static double _weightFromJson(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    throw FormatException('Cannot convert $value to double');
  }

  factory WeightEntryModel.fromEntity(WeightEntry weightEntry) {
    return WeightEntryModel(
      id: weightEntry.id,
      catId: weightEntry.catId,
      weight: weightEntry.weight,
      measuredAt: weightEntry.measuredAt,
      notes: weightEntry.notes,
      createdAt: weightEntry.createdAt,
      updatedAt: weightEntry.updatedAt,
    );
  }

  WeightEntry toEntity() {
    return WeightEntry(
      id: id,
      catId: catId,
      weight: weight,
      measuredAt: measuredAt,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
