import 'package:equatable/equatable.dart';

/// Tipos de agendamento
enum ScheduleType { feeding, weightCheck }

/// Entidade Schedule representa um agendamento de tarefa
/// Baseado na tabela schedules do Supabase
class Schedule extends Equatable {
  final String id;
  final String catId;
  final ScheduleType type;
  final int? interval;  // Intervalo em horas
  final List<String>? times;  // Horários específicos ["08:00", "12:00", "18:00"]
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Schedule({
    required this.id,
    required this.catId,
    required this.type,
    this.interval,
    this.times,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        catId,
        type,
        interval,
        times,
        enabled,
        createdAt,
        updatedAt,
      ];

  Schedule copyWith({
    String? id,
    String? catId,
    ScheduleType? type,
    int? interval,
    List<String>? times,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      type: type ?? this.type,
      interval: interval ?? this.interval,
      times: times ?? this.times,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Nome de exibição do tipo de agendamento
  String get typeDisplayName {
    switch (type) {
      case ScheduleType.feeding:
        return 'Alimentação';
      case ScheduleType.weightCheck:
        return 'Pesagem';
    }
  }

  /// Descrição do intervalo
  String get intervalDescription {
    if (interval != null) {
      if (interval == 1) {
        return 'A cada hora';
      } else if (interval! < 24) {
        return 'A cada $interval horas';
      } else {
        final days = interval! ~/ 24;
        return 'A cada $days ${days == 1 ? 'dia' : 'dias'}';
      }
    }
    return 'Horários específicos';
  }
}

