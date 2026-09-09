import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:multitool/features/location/data/repositories/location_repository_impl.dart';
import 'package:multitool/features/location/domain/entities/location_data_entity.dart';
import 'package:multitool/features/location/domain/repositories/location_repository.dart';
import 'package:multitool/features/location/presentation/controllers/location_controller.dart';

class MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late MockLocationRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockLocationRepository();
    container = ProviderContainer(
      overrides: [
        locationRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final fakeLocation = const LocationDataEntity(
    latitude: 52.2297,
    longitude: 21.0122,
    altitude: 110.0,
    speed: 5.0, // 5 m/s = 18 km/h
    heading: 90.0,
    accuracy: 3.5,
    address: 'Warszawa, Polska',
    isLive: false,
  );

  test('Stan początkowy powinien być AsyncData(null)', () {
    final state = container.read(locationControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.value, isNull);
    expect(state, const AsyncValue<LocationDataEntity?>.data(null));
  });

  test('fetchOnce() powinien pobrać koordynaty z repozytorium', () async {
  // Arrange
  when(() => mockRepository.getCurrentLocation()).thenAnswer((_) async => fakeLocation);

  // KLUCZOWE: Podpinamy słuchacza, aby autoDispose nie zniszczył providera w trakcie `await`
  final subscription = container.listen(
    locationControllerProvider,
    (_, _) {},
  );

  // Act: Uruchamiamy pobieranie
  final future = container.read(locationControllerProvider.notifier).fetchOnce();

  // Assert 1: W trakcie pobierania stan to loading
  expect(container.read(locationControllerProvider).isLoading, isTrue);

  // Czekamy na zakończenie operacji asynchronicznej
  await future;

  // Assert 2: Po zakończeniu mamy poprawne dane
  final state = container.read(locationControllerProvider);
  expect(state.isLoading, isFalse);
  expect(state.value?.latitude, 52.2297);
  expect(state.value?.address, 'Warszawa, Polska');
  expect(state.value?.speedKmH, 18.0);

  // Sprzątamy słuchacza na koniec testu
  subscription.close();
});
}