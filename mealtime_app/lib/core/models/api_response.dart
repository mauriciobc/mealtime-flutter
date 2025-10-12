import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// Modelo padrão para respostas da API Mealtime
/// Estrutura: {success: bool, data: T?, error: string?, count?: int}
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? count;
  final Map<String, dynamic>? metadata;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.count,
    this.metadata,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  /// Helper para criar resposta de sucesso
  factory ApiResponse.success(
    T data, {
    int? count,
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      count: count,
      metadata: metadata,
    );
  }

  /// Helper para criar resposta de erro
  factory ApiResponse.error(String error) {
    return ApiResponse<T>(success: false, error: error);
  }

  /// Verifica se a resposta foi bem-sucedida
  bool get isSuccess => success && error == null;

  /// Verifica se a resposta falhou
  bool get isError => !success || error != null;

  /// Converte ApiResponse para Entity (para data sources)
  T? toEntity() {
    return data;
  }

  /// Converte lista de ApiResponse para lista de entities
  static List<T> toEntityList<T>(List<ApiResponse<T>> responses) {
    return responses
        .where((response) => response.success && response.data != null)
        .map((response) => response.data!)
        .toList();
  }

  /// Verifica se a resposta é válida
  bool get isValid => success && data != null;

  /// Lança exceção se a resposta contém erro
  void throwIfError() {
    if (!success && error != null) {
      throw Exception(error);
    }
  }
}

/// Modelo específico para listas paginadas (simplificado)
class PaginatedResponse<T> {
  final bool success;
  final List<T>? data;
  final String? error;
  final int? count;
  final Map<String, dynamic>? metadata;
  final int? page;
  final int? limit;
  final int? total;
  final bool? hasMore;

  const PaginatedResponse({
    required this.success,
    this.data,
    this.error,
    this.count,
    this.metadata,
    this.page,
    this.limit,
    this.total,
    this.hasMore,
  });

  /// Helper para criar resposta paginada de sucesso
  factory PaginatedResponse.success(
    List<T> data, {
    int? page,
    int? limit,
    int? total,
    bool? hasMore,
    Map<String, dynamic>? metadata,
  }) {
    return PaginatedResponse<T>(
      success: true,
      data: data,
      count: data.length,
      page: page,
      limit: limit,
      total: total,
      hasMore: hasMore,
      metadata: metadata,
    );
  }

  /// Converte PaginatedResponse para lista de entities
  List<T> toEntityList() {
    return data ?? [];
  }

  /// Mapeia os dados paginados
  PaginatedResponse<R> map<R>(R Function(T) mapper) {
    return PaginatedResponse<R>(
      success: success,
      data: data?.map(mapper).toList(),
      error: error,
      count: count,
      metadata: metadata,
      page: page,
      limit: limit,
      total: total,
      hasMore: hasMore,
    );
  }
}
