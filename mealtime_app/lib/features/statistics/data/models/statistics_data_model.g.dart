// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatisticsDataModel _$StatisticsDataModelFromJson(Map<String, dynamic> json) =>
    StatisticsDataModel(
      totalFeedings: (json['totalFeedings'] as num).toInt(),
      averagePortion: (json['averagePortion'] as num).toDouble(),
      activeCats: (json['activeCats'] as num).toInt(),
      totalConsumption: (json['totalConsumption'] as num).toDouble(),
      dailyConsumptions: (json['dailyConsumptions'] as List<dynamic>)
          .map((e) => DailyConsumptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      catConsumptions: (json['catConsumptions'] as List<dynamic>)
          .map((e) => CatConsumptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hourlyFeedings: (json['hourlyFeedings'] as List<dynamic>)
          .map((e) => HourlyFeedingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StatisticsDataModelToJson(
  StatisticsDataModel instance,
) => <String, dynamic>{
  'totalFeedings': instance.totalFeedings,
  'averagePortion': instance.averagePortion,
  'activeCats': instance.activeCats,
  'totalConsumption': instance.totalConsumption,
  'dailyConsumptions': instance.dailyConsumptions,
  'catConsumptions': instance.catConsumptions,
  'hourlyFeedings': instance.hourlyFeedings,
};

DailyConsumptionModel _$DailyConsumptionModelFromJson(
  Map<String, dynamic> json,
) => DailyConsumptionModel(
  date: DateTime.parse(json['date'] as String),
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$DailyConsumptionModelToJson(
  DailyConsumptionModel instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'amount': instance.amount,
};

CatConsumptionModel _$CatConsumptionModelFromJson(Map<String, dynamic> json) =>
    CatConsumptionModel(
      catId: json['catId'] as String,
      catName: json['catName'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      foodType: json['foodType'] as String?,
    );

Map<String, dynamic> _$CatConsumptionModelToJson(
  CatConsumptionModel instance,
) => <String, dynamic>{
  'catId': instance.catId,
  'catName': instance.catName,
  'amount': instance.amount,
  'percentage': instance.percentage,
  'foodType': instance.foodType,
};

HourlyFeedingModel _$HourlyFeedingModelFromJson(Map<String, dynamic> json) =>
    HourlyFeedingModel(
      hour: (json['hour'] as num).toInt(),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$HourlyFeedingModelToJson(HourlyFeedingModel instance) =>
    <String, dynamic>{'hour': instance.hour, 'count': instance.count};
