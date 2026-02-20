import 'package:flutter_test/flutter_test.dart';
import 'package:mealtime_app/features/cats/data/models/cat_model.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';

void main() {
  group('CatModel', () {
    const knownDate = '2020-05-15T00:00:00.000';
    final knownDateTime = DateTime(2020, 5, 15);

    group('toEntity', () {
      test('quando birthDate é null usa data sentinel (1970-01-01)', () {
        final model = CatModel(
          id: '1',
          name: 'Test',
          birthDate: null,
          householdId: 'h1',
          ownerId: 'u1',
          createdAt: DateTime(2021, 1, 1),
          updatedAt: DateTime(2021, 1, 1),
        );
        final entity = model.toEntity();
        expect(entity.birthDate, DateTime(1970, 1, 1));
      });

      test('quando birthDate é string vazia usa data sentinel', () {
        final model = CatModel(
          id: '1',
          name: 'Test',
          birthDate: '',
          householdId: 'h1',
          ownerId: 'u1',
          createdAt: DateTime(2021, 1, 1),
          updatedAt: DateTime(2021, 1, 1),
        );
        final entity = model.toEntity();
        expect(entity.birthDate, DateTime(1970, 1, 1));
      });

      test('quando birthDate é válido parseia corretamente', () {
        final model = CatModel(
          id: '1',
          name: 'Test',
          birthDate: knownDate,
          householdId: 'h1',
          ownerId: 'u1',
          createdAt: DateTime(2021, 1, 1),
          updatedAt: DateTime(2021, 1, 1),
        );
        final entity = model.toEntity();
        expect(entity.birthDate, knownDateTime);
      });

      test('ownerId vazio vira null na entidade', () {
        final model = CatModel(
          id: '1',
          name: 'Test',
          birthDate: knownDate,
          householdId: 'h1',
          ownerId: '',
          createdAt: DateTime(2021, 1, 1),
          updatedAt: DateTime(2021, 1, 1),
        );
        final entity = model.toEntity();
        expect(entity.ownerId, isNull);
      });

      test('ownerId não vazio é preservado', () {
        final model = CatModel(
          id: '1',
          name: 'Test',
          birthDate: knownDate,
          householdId: 'h1',
          ownerId: 'user-123',
          createdAt: DateTime(2021, 1, 1),
          updatedAt: DateTime(2021, 1, 1),
        );
        final entity = model.toEntity();
        expect(entity.ownerId, 'user-123');
      });
    });
  });
}
