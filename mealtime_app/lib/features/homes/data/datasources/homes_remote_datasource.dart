import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/features/homes/data/models/household_model.dart';
import 'package:mealtime_app/services/api/homes_api_service.dart';

abstract class HomesRemoteDataSource {
  Future<List<HouseholdModel>> getHomes();
  Future<HouseholdModel> createHome({
    required String name,
    String? description,
  });
  Future<HouseholdModel> updateHome({
    required String id,
    required String name,
    String? description,
  });
  Future<void> deleteHome(String id);
  Future<void> setActiveHome(String id);
}

class HomesRemoteDataSourceImpl implements HomesRemoteDataSource {
  final HomesApiService apiService;

  HomesRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<HouseholdModel>> getHomes() async {
    try {
      final apiResponse = await apiService.getHouseholds();

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao buscar residências',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      throw ServerException('Erro ao buscar residências: ${e.toString()}');
    }
  }

  @override
  Future<HouseholdModel> createHome({
    required String name,
    String? description,
  }) async {
    try {
      final apiResponse = await apiService.createHousehold(
        name: name,
        description: description,
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao criar residência',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      throw ServerException('Erro ao criar residência: ${e.toString()}');
    }
  }

  @override
  Future<HouseholdModel> updateHome({
    required String id,
    required String name,
    String? description,
  }) async {
    try {
      final apiResponse = await apiService.updateHousehold(
        id: id,
        name: name,
        description: description,
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao atualizar residência',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      throw ServerException('Erro ao atualizar residência: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteHome(String id) async {
    try {
      final apiResponse = await apiService.deleteHousehold(id);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao excluir residência',
        );
      }
    } catch (e) {
      throw ServerException('Erro ao excluir residência: ${e.toString()}');
    }
  }

  @override
  Future<void> setActiveHome(String id) async {
    try {
      final apiResponse = await apiService.setActiveHousehold(id);

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao definir residência ativa',
        );
      }
    } catch (e) {
      throw ServerException(
        'Erro ao definir residência ativa: ${e.toString()}',
      );
    }
  }
}
