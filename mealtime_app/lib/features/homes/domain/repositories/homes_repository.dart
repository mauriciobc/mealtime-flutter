import 'package:mealtime_app/features/homes/domain/entities/home.dart';

abstract class HomesRepository {
  Future<List<Home>> getHomes();
  Future<Home> createHome({required String name, String? description});
  Future<Home> updateHome({
    required String id,
    required String name,
    String? description,
  });
  Future<void> deleteHome(String id);
  Future<void> setActiveHome(String id);
  Future<Home?> getActiveHome();
}
