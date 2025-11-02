import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/services/api/cats_api_service.dart';

abstract class CatsRemoteDataSource {
  /// Obtém todos os gatos (com filtro opcional por household)
  Future<List<Cat>> getCats({String? householdId});
  
  /// Cria um novo gato
  Future<Cat> createCat(Cat cat);

  /// Atualiza um gato existente
  Future<Cat> updateCat(Cat cat);

  /// Deleta um gato
  Future<void> deleteCat(String catId);

  /// Atualiza o peso de um gato
  Future<Cat> updateCatWeight(String catId, double weight);
}

class CatsRemoteDataSourceImpl implements CatsRemoteDataSource {
  final CatsApiService apiService;

  CatsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<Cat>> getCats({String? householdId}) async {
    try {
      final apiResponse = await apiService.getCats(householdId: householdId);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao buscar gatos',
        );
      }

      return apiResponse.data!.map((catModel) => catModel.toEntity()).toList();
    } catch (e) {
      throw ServerException('Erro ao buscar gatos: ${e.toString()}');
    }
  }

  @override
  Future<Cat> createCat(Cat cat) async {
    try {
      final request = CreateCatRequestV2(
        name: cat.name,
        householdId: cat.homeId,  // mudou de homeId
        photoUrl: cat.imageUrl,    // mudou de imageUrl
        birthdate: cat.birthDate,  // mudou de birthDate
        weight: cat.currentWeight,
        feedingInterval: cat.feedingInterval,
      );
      final apiResponse = await apiService.createCat(request);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao criar gato',
        );
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      throw ServerException('Erro ao criar gato: ${e.toString()}');
    }
  }

  @override
  Future<Cat> updateCat(Cat cat) async {
    try {
      final request = UpdateCatRequestV2(
        name: cat.name,
        householdId: cat.homeId,
        photoUrl: cat.imageUrl,
        birthdate: cat.birthDate,
        weight: cat.currentWeight,
        feedingInterval: cat.feedingInterval,
      );
      final apiResponse = await apiService.updateCat(cat.id, request);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao atualizar gato',
        );
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      throw ServerException('Erro ao atualizar gato: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCat(String catId) async {
    try {
      final apiResponse = await apiService.deleteCat(catId);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao deletar gato',
        );
      }
    } catch (e) {
      throw ServerException('Erro ao deletar gato: ${e.toString()}');
    }
  }

  @override
  Future<Cat> updateCatWeight(String catId, double weight) async {
    try {
      final request = UpdateWeightRequest(weight: weight);
      final apiResponse = await apiService.updateCatWeight(catId, request);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao atualizar peso',
        );
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      throw ServerException('Erro ao atualizar peso: ${e.toString()}');
    }
  }
}
