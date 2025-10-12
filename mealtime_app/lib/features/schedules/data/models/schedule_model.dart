import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/features/schedules/domain/entities/schedule.dart';

part 'schedule_model.g.dart';

/// Model de Schedule mapeado da tabela schedules do Supabase
/// Usa snake_case para compatibilidade com o banco de dados
@JsonSerializable(fieldRename: FieldRename.snake)
class ScheduleModel {
  final String id;
  final String catId;
  final String type;  // 'feeding', 'weight_check'
  final int? interval;  // em horas
  final List<String>? times;  // ["08:00", "12:00", "18:00"]
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScheduleModel({
    required this.id,
    required this.catId,
    required this.type,
    this.interval,
    this.times,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleModelToJson(this);

  /// Cria um model a partir de uma entidade
  factory ScheduleModel.fromEntity(Schedule schedule) {
    return ScheduleModel(
      id: schedule.id,
      catId: schedule.catId,
      type: schedule.type == ScheduleType.feeding ? 'feeding' : 'weight_check',
      interval: schedule.interval,
      times: schedule.times,
      enabled: schedule.enabled,
      createdAt: schedule.createdAt,
      updatedAt: schedule.updatedAt,
    );
  }

  /// Converte o model para entidade de domínio
  Schedule toEntity() {
    return Schedule(
      id: id,
      catId: catId,
      type: type == 'feeding' ? ScheduleType.feeding : ScheduleType.weightCheck,
      interval: interval,
      times: times,
      enabled: enabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

