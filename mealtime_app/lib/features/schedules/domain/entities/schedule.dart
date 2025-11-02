import 'package:equatable/equatable.dart';

/// Tipos de agendamento conforme o backend
enum ScheduleType { interval, fixedTime }

/// Modelo básico de gato (usado em schedules)
class CatBasic extends Equatable {
  final String id;
  final String name;

  const CatBasic({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

/// Entidade Schedule representa um agendamento de alimentação
/// Baseado na tabela schedules do backend
class Schedule extends Equatable {
  final String id;
  final String catId;
  final ScheduleType type;
  final int? interval; // minutos entre alimentações (para type=interval)
  final List<String> times; // horários fixos HH:MM (para type=fixedTime)
  final bool enabled;
  final CatBasic? cat; // {id, name} - dados básicos do gato
  final DateTime createdAt;
  final DateTime updatedAt;

  const Schedule({
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

  @override
  List<Object?> get props => [
        id,
        catId,
        type,
        interval,
        times,
        enabled,
        cat,
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
    CatBasic? cat,
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
      cat: cat ?? this.cat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Nome de exibição do tipo de agendamento
  String get typeDisplayName {
    switch (type) {
      case ScheduleType.interval:
        return 'Intervalo de ${interval ?? 0} minutos';
      case ScheduleType.fixedTime:
        return 'Horários fixos: ${times.join(", ")}';
    }
  }

  /// Verifica se o agendamento está ativo
  bool get isActive => enabled;
}
