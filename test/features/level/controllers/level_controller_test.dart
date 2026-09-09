import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multitool/features/level/data/reopsitories/level_repository_impl.dart';
import 'package:multitool/features/level/domain/entities/level_entity.dart';
import 'package:multitool/features/level/domain/repositories/level_repository.dart';
import 'package:multitool/features/level/presentation/controllers/level_controller.dart';

class MockLevelRepository extends Mock implements LevelRepository {}

void main() {
  group('LevelEntity - Reguły domenowe', () {
    test('isLevel powinien zwrócić true, gdy roll i pitch są mniejsze niż 1°', () {
      const entity = LevelEntity(
        x: 0.1,
        y: -0.1,
        z: 9.8,
        roll: 0.4,
        pitch: -0.7,
      );

      expect(entity.isLevel, isTrue);
    });

    test('isLevel powinien zwrócić false, gdy przechylenie przekracza 1°', () {
      const entity = LevelEntity(
        x: 1.5,
        y: 0.0,
        z: 9.6,
        roll: 2.1, // > 1.0
        pitch: 0.2,
      );

      expect(entity.isLevel, isFalse);
    });

    test('isLevel zwraca false przy ujemnym wychyleniu poniżej -1°', () {
      const entity = LevelEntity(
        x: 0.0,
        y: 2.0,
        z: 9.5,
        roll: 0.0,
        pitch: -1.5, // < -1.0
      );

      expect(entity.isLevel, isFalse);
    });
  });

  group('LevelController - Strumień Riverpod', () {
    late MockLevelRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockLevelRepository();
      container = ProviderContainer(
        overrides: [
          levelRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('levelControllerProvider poprawnie emituje stan ze strumienia repozytorium', () async {
      const sampleLevel = LevelEntity(
        x: 0.0,
        y: 0.0,
        z: 9.81,
        roll: 0.0,
        pitch: 0.0,
      );

      // Emulujemy strumień z 1 odczytem
      when(() => mockRepository.getLevelStream())
          .thenAnswer((_) => Stream.value(sampleLevel));

      // Odczytujemy pierwszą wartość ze strumienia Riverpoda
      final result = await container.read(levelControllerProvider.future);

      expect(result.isLevel, isTrue);
      expect(result.roll, 0.0);
      expect(result.pitch, 0.0);
      verify(() => mockRepository.getLevelStream()).called(1);
    });
  });
}