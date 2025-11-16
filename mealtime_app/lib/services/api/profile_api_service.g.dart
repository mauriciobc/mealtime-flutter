// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_api_service.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main

class _ProfileApiService implements ProfileApiService {
  _ProfileApiService(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= 'https://mealtime.app.br/api/v2';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  /// Sanitiza RequestOptions removendo PII antes de logar
  /// Substitui IDs/usernames no path por placeholders e remove headers sensíveis
  RequestOptions _sanitizeRequestOptions(RequestOptions options) {
    // Criar cópia do path para sanitizar
    String sanitizedPath = options.path;
    
    // Substituir /profile/{idOrUsername} por /profile/{idOrUsername}
    // usando regex para capturar qualquer valor após /profile/
    sanitizedPath = sanitizedPath.replaceAll(
      RegExp(r'/profile/[^/]+'),
      '/profile/{idOrUsername}',
    );
    
    // Criar cópia dos headers e sanitizar campos sensíveis
    final sanitizedHeaders = Map<String, dynamic>.from(options.headers);
    final sensitiveHeaders = [
      'authorization',
      'Authorization',
      'x-api-key',
      'X-API-Key',
      'cookie',
      'Cookie',
    ];
    
    for (final header in sensitiveHeaders) {
      if (sanitizedHeaders.containsKey(header)) {
        sanitizedHeaders[header] = '[REDACTED]';
      }
    }
    
    // Criar nova cópia do RequestOptions com dados sanitizados
    return options.copyWith(
      path: sanitizedPath,
      headers: sanitizedHeaders,
    );
  }

  @override
  Future<ApiResponse<ProfileModel>> getProfile(String idOrUsername) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ApiResponse<ProfileModel>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/profile/${idOrUsername}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ProfileModel> _value;
    try {
      _value = ApiResponse<ProfileModel>.fromJson(
        _result.data!,
        (json) => ProfileModel.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _sanitizeRequestOptions(_options));
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ProfileModel>> updateProfile(
    String idOrUsername,
    ProfileInputModel request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<ApiResponse<ProfileModel>>(
      Options(method: 'PUT', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/profile/${idOrUsername}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ProfileModel> _value;
    try {
      _value = ApiResponse<ProfileModel>.fromJson(
        _result.data!,
        (json) => ProfileModel.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _sanitizeRequestOptions(_options));
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

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
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

// dart format on
