import 'package:equatable/equatable.dart';

/// Consumo diário de ração
class DailyConsumption extends Equatable {
  final DateTime date;
  final double amount; // em g

  const DailyConsumption({
    required this.date,
    required this.amount,
  });

  @override
  List<Object?> get props => [date, amount];

  DailyConsumption copyWith({
    DateTime? date,
    double? amount,
  }) {
    return DailyConsumption(
      date: date ?? this.date,
      amount: amount ?? this.amount,
    );
  }
}

/// Consumo por gato
class CatConsumption extends Equatable {
  final String catId;
  final String catName;
  final double amount; // em g
  final double percentage; // percentual do total

  const CatConsumption({
    required this.catId,
    required this.catName,
    required this.amount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [catId, catName, amount, percentage];

  CatConsumption copyWith({
    String? catId,
    String? catName,
    double? amount,
    double? percentage,
  }) {
    return CatConsumption(
      catId: catId ?? this.catId,
      catName: catName ?? this.catName,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
    );
  }
}

/// Alimentações por hora do dia
class HourlyFeeding extends Equatable {
  final int hour; // 0-23
  final int count; // quantidade de alimentações

  const HourlyFeeding({
    required this.hour,
    required this.count,
  });

  @override
  List<Object?> get props => [hour, count];

  HourlyFeeding copyWith({
    int? hour,
    int? count,
  }) {
    return HourlyFeeding(
      hour: hour ?? this.hour,
      count: count ?? this.count,
    );
  }
}

/// Dados agregados de estatísticas
class StatisticsData extends Equatable {
  final int totalFeedings;
  final double averagePortion; // em g
  final int activeCats;
  final double totalConsumption; // consumo total no período em g
  final List<DailyConsumption> dailyConsumptions; // consumo por dia
  final List<CatConsumption> catConsumptions; // consumo por gato
  final List<HourlyFeeding> hourlyFeedings; // alimentações por hora

  const StatisticsData({
    required this.totalFeedings,
    required this.averagePortion,
    required this.activeCats,
    required this.totalConsumption,
    required this.dailyConsumptions,
    required this.catConsumptions,
    required this.hourlyFeedings,
  });

  @override
  List<Object?> get props => [
        totalFeedings,
        averagePortion,
        activeCats,
        totalConsumption,
        dailyConsumptions,
        catConsumptions,
        hourlyFeedings,
      ];

  StatisticsData copyWith({
    int? totalFeedings,
    double? averagePortion,
    int? activeCats,
    double? totalConsumption,
    List<DailyConsumption>? dailyConsumptions,
    List<CatConsumption>? catConsumptions,
    List<HourlyFeeding>? hourlyFeedings,
  }) {
    return StatisticsData(
      totalFeedings: totalFeedings ?? this.totalFeedings,
      averagePortion: averagePortion ?? this.averagePortion,
      activeCats: activeCats ?? this.activeCats,
      totalConsumption: totalConsumption ?? this.totalConsumption,
      dailyConsumptions: dailyConsumptions ?? this.dailyConsumptions,
      catConsumptions: catConsumptions ?? this.catConsumptions,
      hourlyFeedings: hourlyFeedings ?? this.hourlyFeedings,
    );
  }

  /// Verifica se há dados para exibir
  bool get hasData => totalFeedings > 0;
}

