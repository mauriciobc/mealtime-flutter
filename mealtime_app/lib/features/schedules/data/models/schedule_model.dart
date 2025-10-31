import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/features/schedules/domain/entities/schedule.dart';

part 'schedule_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CatBasicModel {
  final String id;
  final String name;

  const CatBasicModel({
    required this.id,
    required this.name,
  });

  factory CatBasicModel.fromJson(Map<String, dynamic> json) =>
      _$CatBasicModelFromJson(json);

  Map<String, dynamic> toJson() => _$CatBasicModelToJson(this);

  CatBasic toEntity() {
    return CatBasic(
      id: id,
      name: name,
    );
  }

  factory CatBasicModel.fromEntity(CatBasic cat) {
    return CatBasicModel(
      id: cat.id,
      name: cat.name,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ScheduleModel {
  final String id;
  final String catId;
  final String type; // 'interval' ou 'fixedTime'
  final int? interval;
  final List<String> times;
  final bool enabled;
  final CatBasicModel? cat;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScheduleModel({
    required this.id,
    required this.catId,
    required this.type,
    this.interval,
    required this.times,
    required this.enabled,
    this.cat,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleModelToJson(this);

  Schedule toEntity() {
    return Schedule(
      id: id,
      catId: catId,
      type: type == 'interval' ? ScheduleType.interval : ScheduleType.fixedTime,
      interval: interval,
      times: times,
      enabled: enabled,
      cat: cat?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ScheduleModel.fromEntity(Schedule schedule) {
    return ScheduleModel(
      id: schedule.id,
      catId: schedule.catId,
      type: schedule.type == ScheduleType.interval ? 'interval' : 'fixedTime',
      interval: schedule.interval,
      times: schedule.times,
      enabled: schedule.enabled,
      cat: schedule.cat != null
          ? CatBasicModel.fromEntity(schedule.cat!)
          : null,
      createdAt: schedule.createdAt,
      updatedAt: schedule.updatedAt,
    );
  }
}
