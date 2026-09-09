import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

// Importy Twoich plików (dostosuj ścieżki do projektu)
import 'package:multitool/features/flashlight/data/repositories/flashlight_repository_impl.dart';
import 'package:multitool/features/flashlight/domain/repositories/flashlight_repository.dart';
import 'package:multitool/features/flashlight/presentation/controllers/flashlight_provider.dart';

// Tworzymy mock repozytorium
class MockFlashlightRepository extends Mock implements FlashlightRepository {}

void main() {
  late MockFlashlightRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockFlashlightRepository();
    
    // Tworzymy kontener Riverpoda i podmieniamy prawdziwe repozytorium na mocka
    container = ProviderContainer(
      overrides: [
        flashlightRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('Początkowy stan latarki powinien być false (wyłączona)', () {
    final state = container.read(flashlightControllerProvider);
    expect(state, false);
  });

  test('Pierwszy toggle() powinien wywołać turnOn() i ustawić stan na true', () async {
    // Arrange: Konfigurujemy mocka, by zwracał sukces
    when(() => mockRepository.turnOn()).thenAnswer((_) async {});

    // Act: Klikamy włącznik
    await container.read(flashlightControllerProvider.notifier).toggle();

    // Assert: Weryfikujemy stan i czy repozytorium zostało zawołane dokładnie 1 raz
    expect(container.read(flashlightControllerProvider), true);
    verify(() => mockRepository.turnOn()).called(1);
    verifyNever(() => mockRepository.turnOff());
  });

  test('Drugi toggle() powinien wywołać turnOff() i zmienić stan z powrotem na false', () async {
    // Arrange
    when(() => mockRepository.turnOn()).thenAnswer((_) async {});
    when(() => mockRepository.turnOff()).thenAnswer((_) async {});

    final controller = container.read(flashlightControllerProvider.notifier);

    // Act: Włączamy i wyłączamy
    await controller.toggle(); // stan: true
    await controller.toggle(); // stan: false

    // Assert
    expect(container.read(flashlightControllerProvider), false);
    verify(() => mockRepository.turnOn()).called(1);
    verify(() => mockRepository.turnOff()).called(1);
  });

  test('W razie błędu sprzętowego toggle() powinien rzucić błąd i zresetować stan na false', () async {
    // Arrange: Sprzęt rzuca wyjątek
    when(() => mockRepository.turnOn()).thenThrow(Exception('Awaria diody LED'));

    final controller = container.read(flashlightControllerProvider.notifier);

    // Act & Assert
    expect(() => controller.toggle(), throwsException);
    expect(container.read(flashlightControllerProvider), false);
  });
}