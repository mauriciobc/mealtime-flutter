import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/features/statistics/domain/entities/statistics_data.dart';

part 'statistics_data_model.g.dart';

/// Model para serialização de StatisticsData
/// Usado principalmente para comunicação com API remota
@JsonSerializable()
class StatisticsDataModel {
  final int totalFeedings;
  final double averagePortion;
  final int activeCats;
  final double totalConsumption;
  final List<DailyConsumptionModel> dailyConsumptions;
  final List<CatConsumptionModel> catConsumptions;
  final List<HourlyFeedingModel> hourlyFeedings;

  const StatisticsDataModel({
    required this.totalFeedings,
    required this.averagePortion,
    required this.activeCats,
    required this.totalConsumption,
    required this.dailyConsumptions,
    required this.catConsumptions,
    required this.hourlyFeedings,
  });

  factory StatisticsDataModel.fromJson(Map<String, dynamic> json) =>
      _$StatisticsDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$StatisticsDataModelToJson(this);

  StatisticsData toEntity() {
    return StatisticsData(
      totalFeedings: totalFeedings,
      averagePortion: averagePortion,
      activeCats: activeCats,
      totalConsumption: totalConsumption,
      dailyConsumptions: dailyConsumptions
          .map((model) => model.toEntity())
          .toList(),
      catConsumptions: catConsumptions.map((model) => model.toEntity()).toList(),
      hourlyFeedings: hourlyFeedings.map((model) => model.toEntity()).toList(),
    );
  }

  factory StatisticsDataModel.fromEntity(StatisticsData entity) {
    return StatisticsDataModel(
      totalFeedings: entity.totalFeedings,
      averagePortion: entity.averagePortion,
      activeCats: entity.activeCats,
      totalConsumption: entity.totalConsumption,
      dailyConsumptions: entity.dailyConsumptions
          .map((d) => DailyConsumptionModel.fromEntity(d))
          .toList(),
      catConsumptions: entity.catConsumptions
          .map((c) => CatConsumptionModel.fromEntity(c))
          .toList(),
      hourlyFeedings: entity.hourlyFeedings
          .map((h) => HourlyFeedingModel.fromEntity(h))
          .toList(),
    );
  }
}

@JsonSerializable()
class DailyConsumptionModel {
  final DateTime date;
  final double amount;

  const DailyConsumptionModel({
    required this.date,
    required this.amount,
  });

  factory DailyConsumptionModel.fromJson(Map<String, dynamic> json) =>
      _$DailyConsumptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyConsumptionModelToJson(this);

  DailyConsumption toEntity() {
    return DailyConsumption(date: date, amount: amount);
  }

  factory DailyConsumptionModel.fromEntity(DailyConsumption entity) {
    return DailyConsumptionModel(
      date: entity.date,
      amount: entity.amount,
    );
  }
}

@JsonSerializable()
class CatConsumptionModel {
  final String catId;
  final String catName;
  final double amount;
  final double percentage;
  final String? foodType;

  const CatConsumptionModel({
    required this.catId,
    required this.catName,
    required this.amount,
    required this.percentage,
    this.foodType,
  });

  factory CatConsumptionModel.fromJson(Map<String, dynamic> json) =>
      _$CatConsumptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$CatConsumptionModelToJson(this);

  CatConsumption toEntity() {
    return CatConsumption(
      catId: catId,
      catName: catName,
      amount: amount,
      percentage: percentage,
      foodType: foodType,
    );
  }

  factory CatConsumptionModel.fromEntity(CatConsumption entity) {
    return CatConsumptionModel(
      catId: entity.catId,
      catName: entity.catName,
      amount: entity.amount,
      percentage: entity.percentage,
      foodType: entity.foodType,
    );
  }
}

@JsonSerializable()
class HourlyFeedingModel {
  final int hour;
  final int count;

  const HourlyFeedingModel({
    required this.hour,
    required this.count,
  });

  factory HourlyFeedingModel.fromJson(Map<String, dynamic> json) =>
      _$HourlyFeedingModelFromJson(json);

  Map<String, dynamic> toJson() => _$HourlyFeedingModelToJson(this);

  HourlyFeeding toEntity() {
    return HourlyFeeding(hour: hour, count: count);
  }

  factory HourlyFeedingModel.fromEntity(HourlyFeeding entity) {
    return HourlyFeedingModel(
      hour: entity.hour,
      count: entity.count,
    );
  }
}

