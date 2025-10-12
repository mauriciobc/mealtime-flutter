import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/services/api/cats_api_service.dart';

abstract class CatsRemoteDataSource {
  Future<List<Cat>> getCats();
  Future<Cat> getCatById(String id);
  Future<Cat> createCat(Cat cat);
  Future<Cat> updateCat(Cat cat);
  Future<void> deleteCat(String id);
  Future<List<Cat>> getCatsByHome(String homeId);
  Future<Cat> updateCatWeight(String catId, double weight);
}

class CatsRemoteDataSourceImpl implements CatsRemoteDataSource {
  final CatsApiService apiService;

  CatsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<Cat>> getCats() async {
    try {
      final apiResponse = await apiService.getCats();

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
  Future<Cat> getCatById(String id) async {
    try {
      final apiResponse = await apiService.getCatById(id);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao buscar gato',
        );
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      throw ServerException('Erro ao buscar gato: ${e.toString()}');
    }
  }

  @override
  Future<Cat> createCat(Cat cat) async {
    try {
      final request = CreateCatRequest(
        name: cat.name,
        breed: cat.breed,
        birthDate: cat.birthDate,
        gender: cat.gender,
        color: cat.color,
        description: cat.description,
        imageUrl: cat.imageUrl,
        currentWeight: cat.currentWeight,
        targetWeight: cat.targetWeight,
        homeId: cat.homeId,
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
      final request = UpdateCatRequest(
        name: cat.name,
        breed: cat.breed,
        birthDate: cat.birthDate,
        gender: cat.gender,
        color: cat.color,
        description: cat.description,
        imageUrl: cat.imageUrl,
        currentWeight: cat.currentWeight,
        targetWeight: cat.targetWeight,
        homeId: cat.homeId,
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
  Future<void> deleteCat(String id) async {
    try {
      final apiResponse = await apiService.deleteCat(id);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao excluir gato',
        );
      }
    } catch (e) {
      throw ServerException('Erro ao excluir gato: ${e.toString()}');
    }
  }

  @override
  Future<List<Cat>> getCatsByHome(String homeId) async {
    try {
      final apiResponse = await apiService.getCatsByHome(homeId);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ??
              'Erro desconhecido ao buscar gatos da residência',
        );
      }

      return apiResponse.data!.map((catModel) => catModel.toEntity()).toList();
    } catch (e) {
      throw ServerException(
        'Erro ao buscar gatos da residência: ${e.toString()}',
      );
    }
  }

  @override
  Future<Cat> updateCatWeight(String catId, double weight) async {
    try {
      final request = UpdateCatWeightRequest(weight: weight);
      final apiResponse = await apiService.updateCatWeight(catId, request);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao atualizar peso do gato',
        );
      }

      return apiResponse.data!.toEntity();
    } catch (e) {
      throw ServerException('Erro ao atualizar peso do gato: ${e.toString()}');
    }
  }
}
