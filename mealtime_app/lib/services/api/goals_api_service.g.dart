// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals_api_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoalModel _$GoalModelFromJson(Map<String, dynamic> json) => GoalModel(
      id: json['id'] as String,
      catId: json['cat_id'] as String,
      targetWeight: GoalModel._weightFromJson(json['target_weight']),
      targetDate: DateTime.parse(json['target_date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      goalName: json['goal_name'] as String?,
      startWeight: GoalModel._nullableWeightFromJson(json['start_weight']),
      unit: json['unit'] as String?,
      status: json['status'] as String?,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$GoalModelToJson(GoalModel instance) => <String, dynamic>{
      'id': instance.id,
      'cat_id': instance.catId,
      'target_weight': instance.targetWeight,
      'target_date': instance.targetDate.toIso8601String(),
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'goal_name': instance.goalName,
      'start_weight': instance.startWeight,
      'unit': instance.unit,
      'status': instance.status,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element

class _GoalsApiService implements GoalsApiService {
  _GoalsApiService(
    this._dio, {
    this.baseUrl,
    this.errorLogger,
  }) {
    baseUrl ??= 'https://mealtime.app.br/api/v2';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<ApiResponse<List<GoalModel>>> getGoals({
    String? catId,
    String? householdId,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'catId': catId,
      r'householdId': householdId,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ApiResponse<List<GoalModel>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/goals',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<List<GoalModel>> _value;
    try {
      _value = ApiResponse<List<GoalModel>>.fromJson(
        _result.data!,
        (json) => json is List<dynamic>
            ? json
                .map<GoalModel>(
                    (i) => GoalModel.fromJson(i as Map<String, dynamic>))
                .toList()
            : List.empty(),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<GoalModel>> createGoal(CreateGoalRequest request) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<ApiResponse<GoalModel>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/goals',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<GoalModel> _value;
    try {
      _value = ApiResponse<GoalModel>.fromJson(
        _result.data!,
        (json) => GoalModel.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(
    String dioBaseUrl,
    String? baseUrl,
  ) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
